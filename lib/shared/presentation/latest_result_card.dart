import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'percentile_ring.dart';

/// Hero card summarizing a highlighted assessment result. Takes plain
/// values so it works for "your latest result" on both the home
/// dashboard and the results screen without depending on either
/// feature's domain types.
class LatestResultCard extends StatelessWidget {
  const LatestResultCard({
    super.key,
    required this.title,
    required this.percentile,
    required this.summary,
    required this.onViewBreakdown,
  });

  final String title;
  final int percentile;
  final String summary;
  final VoidCallback onViewBreakdown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: AppRadius.heroCard,
      ),
      child: Column(
        children: [
          PercentileRing(percentile: percentile),
          SizedBox(height: AppSpacing.lg - AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withValues(alpha: 0.15),
              borderRadius: AppRadius.chip,
            ),
            child: Text(
              'Latest Result',
              style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.secondary),
            ),
          ),
          SizedBox(height: AppSpacing.sm + AppSpacing.xs),
          Text(title, style: theme.textTheme.headlineLarge, textAlign: TextAlign.center),
          SizedBox(height: AppSpacing.xs + 4),
          Text(summary, style: theme.textTheme.bodyLarge, textAlign: TextAlign.center),
          SizedBox(height: AppSpacing.md + AppSpacing.xs),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onViewBreakdown,
              child: const Text('View Detailed Breakdown'),
            ),
          ),
        ],
      ),
    );
  }
}
