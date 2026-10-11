import 'package:fluentiq/features/questions/domain/audio_recorder.dart';
import 'package:fluentiq/features/questions/domain/audio_transcriber.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../core/di/service_locator.dart';
import '../../../shared/presentation/app_components.dart';
import 'package:fluentiq/features/questions/domain/question.dart';
import 'recording_answer_cubit.dart';
import 'recording_answer_state.dart';

/// Selects a widget renderer from the question type, keeping data and UI
/// decoupled. [onAnswerChanged] fires with the current answer any time it
/// changes — an option index (`int`) for choice-based types, raw text
/// (`String`) for free-response and transcribed types.
class QuestionRenderer extends StatelessWidget {
  const QuestionRenderer({super.key, required this.question, required this.onAnswerChanged});

  final Question question;
  final ValueChanged<dynamic> onAnswerChanged;

  @override
  Widget build(BuildContext context) => switch (question.type) {
        QuestionType.writing || QuestionType.fillBlank || QuestionType.cloze =>
          _TextAnswerQuestion(onChanged: onAnswerChanged),
        // Audio is played, never shown as text — see Question.isAudioPromptOnly.
        QuestionType.listening => _ListeningQuestion(question: question, onChanged: onAnswerChanged),
        QuestionType.dictation => _DictationQuestion(prompt: question.title, onChanged: onAnswerChanged),
        QuestionType.speaking || QuestionType.conversation =>
          _RecordingQuestion(onChanged: onAnswerChanged),
        _ => _OptionsQuestion(question: question, onChanged: onAnswerChanged),
      };
}

class _OptionsQuestion extends StatefulWidget {
  const _OptionsQuestion({required this.question, required this.onChanged});

  final Question question;
  final ValueChanged<dynamic> onChanged;

  @override
  State<_OptionsQuestion> createState() => _OptionsQuestionState();
}

class _OptionsQuestionState extends State<_OptionsQuestion> {
  int? _selectedIndex;

  void _select(int? index) {
    setState(() => _selectedIndex = index);
    if (index != null) widget.onChanged(index);
  }

  @override
  Widget build(BuildContext context) => ListView.builder(
        itemCount: widget.question.options.length,
        itemBuilder: (context, index) {
          final option = widget.question.options[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              onTap: () => _select(index),
              child: Row(
                children: [
                  Expanded(child: Text(option)),
                  Radio<int>(value: index, groupValue: _selectedIndex, onChanged: _select),
                ],
              ),
            ),
          );
        },
      );
}

class _TextAnswerQuestion extends StatefulWidget {
  const _TextAnswerQuestion({required this.onChanged});

  final ValueChanged<dynamic> onChanged;

  @override
  State<_TextAnswerQuestion> createState() => _TextAnswerQuestionState();
}

class _TextAnswerQuestionState extends State<_TextAnswerQuestion> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: _controller,
        maxLines: 6,
        decoration: const InputDecoration(hintText: 'Write your answer…'),
        onChanged: widget.onChanged,
      );
}

/// Listen to the passage, then answer a comprehension MCQ — reuses
/// [_OptionsQuestion] rather than duplicating the options list.
class _ListeningQuestion extends StatelessWidget {
  const _ListeningQuestion({required this.question, required this.onChanged});

  final Question question;
  final ValueChanged<dynamic> onChanged;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          _TtsPlayButton(text: question.title),
          const SizedBox(height: 16),
          Expanded(child: _OptionsQuestion(question: question, onChanged: onChanged)),
        ],
      );
}

/// Listen to the sentence, then type exactly what was heard — reuses
/// [_TextAnswerQuestion] rather than duplicating the text field.
class _DictationQuestion extends StatelessWidget {
  const _DictationQuestion({required this.prompt, required this.onChanged});

  final String prompt;
  final ValueChanged<dynamic> onChanged;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          _TtsPlayButton(text: prompt),
          const SizedBox(height: 16),
          Expanded(child: _TextAnswerQuestion(onChanged: onChanged)),
        ],
      );
}

/// On-device text-to-speech playback. Shared by listening and dictation
/// — the only two types whose prompt text must never be shown visibly.
class _TtsPlayButton extends StatefulWidget {
  const _TtsPlayButton({required this.text});

  final String text;

  @override
  State<_TtsPlayButton> createState() => _TtsPlayButtonState();
}

class _TtsPlayButtonState extends State<_TtsPlayButton> {
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _play() async {
    setState(() => _isSpeaking = true);
    await _tts.speak(widget.text);
  }

  @override
  Widget build(BuildContext context) => AppCard(
        onTap: _isSpeaking ? null : _play,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_isSpeaking ? Icons.volume_up_rounded : Icons.play_circle_fill_rounded, size: 32),
            const SizedBox(width: 12),
            Text(_isSpeaking ? 'Playing…' : 'Play audio'),
          ],
        ),
      );
}

/// Record → stop → transcribe. Owns cubit wiring only; all recording
/// and transcription logic lives in [RecordingAnswerCubit].
class _RecordingQuestion extends StatelessWidget {
  const _RecordingQuestion({required this.onChanged});

  final ValueChanged<dynamic> onChanged;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => RecordingAnswerCubit(getIt<QuestionAudioRecorder>(), getIt<AudioTranscriber>()),
        child: _RecordingAnswerView(onChanged: onChanged),
      );
}

class _RecordingAnswerView extends StatelessWidget {
  const _RecordingAnswerView({required this.onChanged});

  final ValueChanged<dynamic> onChanged;

  @override
  Widget build(BuildContext context) => BlocConsumer<RecordingAnswerCubit, RecordingAnswerState>(
        listener: (context, state) {
          if (state is RecordingTranscribed) onChanged(state.transcript);
        },
        builder: (context, state) {
          final cubit = context.read<RecordingAnswerCubit>();
          return Center(
            child: AppCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: switch (state) {
                  RecordingIdle() => [
                      const Icon(Icons.mic_none_rounded, size: 56),
                      const SizedBox(height: 12),
                      const Text('Tap to record your answer'),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: cubit.start, child: const Text('Start recording')),
                    ],
                  RecordingInProgress() => [
                      Icon(Icons.fiber_manual_record_rounded, color: Theme.of(context).colorScheme.error, size: 56),
                      const SizedBox(height: 12),
                      const Text('Recording…'),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: cubit.stopAndTranscribe, child: const Text('Stop')),
                    ],
                  RecordingTranscribing() => const [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Transcribing…'),
                    ],
                  RecordingTranscribed(:final transcript) => [
                      const Icon(Icons.check_circle_rounded, size: 40),
                      const SizedBox(height: 12),
                      Text('"$transcript"', textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      TextButton(onPressed: cubit.reset, child: const Text('Record again')),
                    ],
                  RecordingError(:final message) => [
                      Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 40),
                      const SizedBox(height: 12),
                      Text(message, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      OutlinedButton(onPressed: cubit.reset, child: const Text('Try again')),
                    ],
                },
              ),
            ),
          );
        },
      );
}
