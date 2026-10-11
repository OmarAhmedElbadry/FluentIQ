import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/domain/app_types.dart';

/// Progress bar + current skill/level readout for a live assessment run.
/// [trailing], when given, renders alongside the level readout — used
/// for [AssessmentTimer] without this widget needing to know timing
/// exists.
class AssessmentProgressHeader extends StatelessWidget {
  const AssessmentProgressHeader({
    super.key,
    required this.index,
    required this.total,
    required this.skill,
    required this.level,
    this.trailing,
  });

  final int index;
  final int total;
  final LanguageSkill skill;
  final CefrLevel level;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: total == 0 ? 0 : (index + 1) / total,
          borderRadius: AppRadius.card,
          minHeight: 6,
        ),
        SizedBox(height: AppSpacing.sm + AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              skill.name.toUpperCase(),
              style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Level ${level.label} · ${index + 1}/$total', style: theme.textTheme.labelMedium),
                if (trailing != null) ...[
                  SizedBox(width: AppSpacing.sm),
                  trailing!,
                ],
              ],
            ),
          ],
        ),
      ],
    );
  }
}
