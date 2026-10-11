import 'package:fluentiq/shared/presentation/skill_score_breakdown.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/presentation/app_components.dart';
import '../../domain/assessment_result.dart';

/// Score + per-skill breakdown shown when an assessment run completes.
/// The breakdown itself is [SkillScoreBreakdown] — shared with the
/// results history detail screen so the two never drift apart.
class AssessmentResultView extends StatelessWidget {
  const AssessmentResultView({super.key, required this.result, required this.onDone});

  final AssessmentResult result;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Assessment complete', style: theme.textTheme.headlineLarge),
          SizedBox(height: AppSpacing.sm),
          Text(
            'You scored ${result.scorePercent}% across ${result.totalQuestions} questions.',
            style: theme.textTheme.bodyLarge,
          ),
          SizedBox(height: AppSpacing.lg),
          SkillScoreBreakdown(skillBreakdown: result.skillBreakdown),
          SizedBox(height: AppSpacing.lg),
          AppButton(label: 'Done', onPressed: onDone),
        ],
      ),
    );
  }
}
