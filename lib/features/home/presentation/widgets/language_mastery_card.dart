import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/domain/app_types.dart';
import '../../../../shared/presentation/app_components.dart';

/// Displays the active language and the user's current CEFR mastery band.
/// Tapping it is the entry point back into language selection.
class LanguageMasteryCard extends StatelessWidget {
  const LanguageMasteryCard({
    super.key,
    required this.language,
    required this.level,
    this.onTap,
  });

  final AppLanguage language;
  final CefrLevel level;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(Icons.translate_rounded, color: theme.colorScheme.primary),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(language.label, style: theme.textTheme.titleLarge),
                Text('Current Mastery', style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: AppRadius.chip,
            ),
            child: Text(
              level.label,
              style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
