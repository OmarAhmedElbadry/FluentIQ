import 'package:flutter/material.dart';

import 'package:fluentiq/core/theme/app_theme.dart';
import 'package:fluentiq/shared/domain/app_types.dart';
import 'package:fluentiq/shared/presentation/app_components.dart';

/// Per-skill accuracy list. Takes a plain `Map<LanguageSkill, double>` so
/// it works for a just-finished [AssessmentResult] and a persisted
/// [AssessmentHistoryEntry] alike — neither feature needs to know about
/// the other's domain types.
class SkillScoreBreakdown extends StatelessWidget {
  const SkillScoreBreakdown({super.key, required this.skillBreakdown});

  final Map<LanguageSkill, double> skillBreakdown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        for (final entry in skillBreakdown.entries)
          Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.sm),
            child: AppCard(
              child: Row(
                children: [
                  Expanded(child: Text(entry.key.name, style: theme.textTheme.titleMedium)),
                  Text(
                    '${(entry.value * 100).round()}%',
                    style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
