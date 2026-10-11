import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Replaces the hero result card when the user hasn't completed an
/// assessment yet — a 0% ring here would read as "you scored zero,"
/// which isn't what an empty state should say.
class HomeEmptyState extends StatelessWidget {
  const HomeEmptyState({super.key, required this.onStart});

  final VoidCallback onStart;

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
          Icon(Icons.auto_awesome_rounded, size: 40, color: theme.colorScheme.primary),
          SizedBox(height: AppSpacing.sm),
          Text('No assessments yet', style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Take your first AI-generated assessment to see your CEFR level and score here.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(onPressed: onStart, child: const Text('Start an assessment')),
          ),
        ],
      ),
    );
  }
}
