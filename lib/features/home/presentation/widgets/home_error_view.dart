import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Centered error message with a retry action. Kept scrollable and
/// pull-to-refresh compatible via [AlwaysScrollableScrollPhysics].
class HomeErrorView extends StatelessWidget {
  const HomeErrorView({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

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
                  Icon(Icons.error_outline, color: theme.colorScheme.error, size: 40),
                  SizedBox(height: AppSpacing.sm),
                  Text(message, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
                  SizedBox(height: AppSpacing.md),
                  OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
