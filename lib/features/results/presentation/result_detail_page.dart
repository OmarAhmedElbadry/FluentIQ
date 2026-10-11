import 'package:fluentiq/features/results/domain/assessment_history_repository.dart';
import 'package:fluentiq/features/results/presentation/widgets/question_review_tile.dart';
import 'package:fluentiq/shared/domain/app_types.dart';
import 'package:fluentiq/shared/presentation/skill_score_breakdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/domain/app_types.dart';
import '../../../shared/domain/date_format.dart';
import '../../../shared/presentation/percentile_ring.dart';
import 'result_detail_cubit.dart';
import 'result_detail_state.dart';

/// Full detail for one past assessment attempt — reuses [PercentileRing]
/// and [SkillScoreBreakdown], the same shared widgets the just-finished
/// screen uses, so this never drifts visually from that screen.
class ResultDetailPage extends StatelessWidget {
  const ResultDetailPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => ResultDetailCubit(getIt<AssessmentHistoryRepository>())..load(id),
        child: const _ResultDetailView(),
      );
}

class _ResultDetailView extends StatelessWidget {
  const _ResultDetailView();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Result')),
        body: SafeArea(
          child: BlocBuilder<ResultDetailCubit, ResultDetailState>(
            builder: (context, state) => switch (state) {
              ResultDetailLoading() => const Center(child: CircularProgressIndicator()),
              ResultDetailError(:final message) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text(message, textAlign: TextAlign.center),
                  ),
                ),
              ResultDetailLoaded(:final entry) => SingleChildScrollView(
                  padding: AppSpacing.screenPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.assessmentTitle, style: Theme.of(context).textTheme.headlineLarge),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        '${formatShortDate(entry.completedAt)} · Level ${entry.level.label}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(height: AppSpacing.lg),
                      Center(child: PercentileRing(percentile: entry.scorePercent)),
                      SizedBox(height: AppSpacing.lg),
                      Text('SKILL BREAKDOWN', style: Theme.of(context).textTheme.labelMedium),
                      SizedBox(height: AppSpacing.sm + AppSpacing.xs),
                      SkillScoreBreakdown(skillBreakdown: entry.skillBreakdown),
                      SizedBox(height: AppSpacing.xl),
                      Text('QUESTIONS', style: Theme.of(context).textTheme.labelMedium),
                      SizedBox(height: AppSpacing.sm + AppSpacing.xs),
                      if (entry.questions.isEmpty)
                        Text(
                          'No detailed review is available for this attempt.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        )
                      else
                        for (var i = 0; i < entry.questions.length; i++)
                          QuestionReviewTile(record: entry.questions[i], number: i + 1),
                    ],
                  ),
                ),
            },
          ),
        ),
      );
}
