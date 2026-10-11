import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Shown on the Results tab before the user has completed anything.
class ResultsEmptyView extends StatelessWidget {
  const ResultsEmptyView({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bar_chart_rounded, size: 48, color: theme.colorScheme.outline),
                  SizedBox(height: AppSpacing.sm),
                  Text('No assessments yet', style: theme.textTheme.titleLarge),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'Complete an assessment to see your results here.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  SizedBox(height: AppSpacing.md),
                  ElevatedButton(onPressed: onStart, child: const Text('Start an assessment')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
