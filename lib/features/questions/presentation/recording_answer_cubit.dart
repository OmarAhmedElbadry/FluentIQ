import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluentiq/features/questions/domain/audio_recorder.dart';
import 'package:fluentiq/features/questions/domain/audio_transcriber.dart';
import 'package:fluentiq/features/questions/domain/audio_transcription_exception.dart';
import 'recording_answer_state.dart';

/// Orchestrates a single spoken answer: request permission, record,
/// stop, transcribe. Neither [QuestionAudioRecorder] nor
/// [AudioTranscriber] concerns leak into the widget — it only reacts to
/// state.
class RecordingAnswerCubit extends Cubit<RecordingAnswerState> {
  RecordingAnswerCubit(this._recorder, this._transcriber) : super(const RecordingIdle());

  final QuestionAudioRecorder _recorder;
  final AudioTranscriber _transcriber;

  Future<void> start() async {
    try {
      final granted = await _recorder.hasPermission();
      if (!granted) {
        emit(const RecordingError('Microphone permission is required to answer this question.'));
        return;
      }
      await _recorder.start();
      emit(const RecordingInProgress());
    } catch (_) {
      emit(const RecordingError('Could not start recording. Please try again.'));
    }
  }

  Future<void> stopAndTranscribe() async {
    emit(const RecordingTranscribing());
    try {
      final path = await _recorder.stop();
      if (path == null) {
        emit(const RecordingError('No audio was recorded. Please try again.'));
        return;
      }
      final transcript = await _transcriber.transcribe(path);
      emit(RecordingTranscribed(transcript));
    } on AudioTranscriptionException catch (e) {
      emit(RecordingError(e.message));
    } catch (_) {
      emit(const RecordingError('Could not transcribe your answer. Please try again.'));
    }
  }

  Future<void> reset() async {
    await _recorder.cancel();
    emit(const RecordingIdle());
  }
}
