import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Compact metric tile used in the dashboard stats row
/// ("TESTS TAKEN", "AVG. SCORE"). Generic enough to add a third
/// stat later without touching [HomePage].
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          SizedBox(height: AppSpacing.sm + AppSpacing.xs),
          Text(label, style: theme.textTheme.labelMedium),
          SizedBox(height: AppSpacing.xs),
          Text(value, style: theme.textTheme.headlineSmall),
        ],
      ),
    );
  }
}
