import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/theme/app_theme.dart';

/// Top bar: personalized greeting plus a settings shortcut.
/// Purely presentational — navigation is decided by the caller.
class GreetingHeader extends StatelessWidget {
  const GreetingHeader({
    super.key,
    required this.userName,
    required this.onSettingsTap,
  });

  final String userName;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Lottie.asset(
              'assets/lottie/B before A.json',
              height: 50,
              repeat: !MediaQuery.of(context).disableAnimations,
            ),          ],
        ),
        IconButton(
          onPressed: onSettingsTap,
          icon: const Icon(Icons.settings_outlined),
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
            foregroundColor: theme.colorScheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
          ),
        ),
      ],
    );
  }
}
