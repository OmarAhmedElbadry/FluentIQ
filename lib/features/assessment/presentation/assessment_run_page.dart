import 'package:fluentiq/features/questions/domain/question_generator.dart';
import 'package:fluentiq/features/results/domain/assessment_history_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_theme.dart';
import '../../questions/domain/question.dart';
import '../../questions/presentation/question_renderer.dart';
import '../../settings/domain/preferences_repository.dart';
import '../domain/assessment_repository.dart';
import 'assessment_run_cubit.dart';
import 'assessment_run_state.dart';
import 'widgets/assessment_progress_header.dart';
import 'widgets/assessment_result_view.dart';
import 'widgets/assessment_timer.dart';

/// Runs a full assessment: generates each question on demand, collects
/// answers, adapts difficulty, enforces the time limit, and shows a
/// summary at the end.
///
/// Purely reactive to [AssessmentRunCubit] — the current draft answer,
/// whether it's valid enough to advance, and the remaining time all
/// live in the cubit, not here, so this stays a [StatelessWidget].
/// Layout lives in `widgets/`, question rendering is delegated to the
/// `questions` feature, AI concerns live entirely behind
/// [QuestionGenerator].
class AssessmentRunPage extends StatelessWidget {
  const AssessmentRunPage({super.key, required this.assessmentId});

  final String assessmentId;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => AssessmentRunCubit(
          getIt<AssessmentRepository>(),
          getIt<QuestionGenerator>(),
          getIt<AssessmentHistoryRepository>(),
          getIt<PreferencesRepository>(),
        )..start(assessmentId: assessmentId),
        child: const _AssessmentRunView(),
      );
}

class _AssessmentRunView extends StatelessWidget {
  const _AssessmentRunView();

  String _instructionFor(Question question) {
    if (question.description.isNotEmpty) return question.description;
    return question.type.isAudioPromptOnly ? 'Listen to the audio, then answer below.' : '';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Assessment')),
        body: SafeArea(
          child: BlocBuilder<AssessmentRunCubit, AssessmentRunState>(
            builder: (context, state) => switch (state) {
              AssessmentRunLoading() => const Center(child: CircularProgressIndicator()),
              AssessmentRunError(:final message) =>
                _ErrorView(message: message, onRetry: () => context.read<AssessmentRunCubit>().retry()),
              AssessmentRunCompleted(:final result) => AssessmentResultView(
                  result: result,
                  onDone: () => context.go('/results'),
                ),
              AssessmentRunInProgress(
                :final question,
                :final index,
                :final total,
                :final level,
                :final hasAnswer,
                :final remaining,
              ) =>
                Padding(
                  padding: AppSpacing.screenPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AssessmentProgressHeader(
                        index: index,
                        total: total,
                        skill: question.skill,
                        level: level,
                        trailing: AssessmentTimer(remaining: remaining),
                      ),
                      SizedBox(height: AppSpacing.md),
                      // Listening/dictation content must only be heard, never
                      // read — showing it as text would make the check trivial.
                      if (!question.type.isAudioPromptOnly) ...[
                        Text(question.title, style: Theme.of(context).textTheme.headlineSmall),
                        SizedBox(height: AppSpacing.xs + 4),
                      ],
                      Text(_instructionFor(question), style: Theme.of(context).textTheme.bodyLarge),
                      SizedBox(height: AppSpacing.lg),
                      Expanded(
                        child: QuestionRenderer(
                          key: ValueKey(question.id),
                          question: question,
                          onAnswerChanged: (value) => context.read<AssessmentRunCubit>().updateAnswer(value),
                        ),
                      ),
                      SizedBox(height: AppSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: hasAnswer
                              ? () => context.read<AssessmentRunCubit>().submitCurrentAnswer()
                              : null,
                          child: Text(index + 1 == total ? 'Finish' : 'Continue'),
                        ),
                      ),
                    ],
                  ),
                ),
            },
          ),
        ),
      );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 40),
              SizedBox(height: AppSpacing.sm),
              Text(message, textAlign: TextAlign.center),
              SizedBox(height: AppSpacing.md),
              OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      );
}
