import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/domain/app_types.dart';
import '../../../../shared/domain/date_format.dart';
import '../../../../shared/presentation/app_components.dart';
import '../../domain/assessment_history_entry.dart';

/// Single row in the results history list.
class HistoryEntryTile extends StatelessWidget {
  const HistoryEntryTile({super.key, required this.entry, required this.onTap});

  final AssessmentHistoryEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Text(
                entry.level.label,
                style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.assessmentTitle, style: theme.textTheme.titleMedium),
                  Text(formatShortDate(entry.completedAt), style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              '${entry.scorePercent}%',
              style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary),
            ),
            Icon(Icons.chevron_right, color: theme.colorScheme.outline),
          ],
        ),
      ),
    );
  }
}
