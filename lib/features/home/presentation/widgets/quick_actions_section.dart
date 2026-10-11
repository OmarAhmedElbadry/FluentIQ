import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import 'quick_action_tile.dart';

/// Declarative description of a single quick action entry.
/// Adding a new action to the dashboard means adding one of these to
/// the list in [HomePage] — never a new widget class.
class QuickAction {
  const QuickAction({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}

/// Renders a labeled, spaced list of [QuickAction]s.
class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key, required this.actions});

  final List<QuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('QUICK ACTIONS', style: Theme.of(context).textTheme.labelMedium),
        SizedBox(height: AppSpacing.sm + AppSpacing.xs),
        for (final action in actions)
          Padding(
            padding: EdgeInsets.only(bottom: action == actions.last ? 0 : AppSpacing.sm + AppSpacing.xs),
            child: QuickActionTile(
              icon: action.icon,
              iconColor: action.iconColor,
              title: action.title,
              subtitle: action.subtitle,
              onTap: action.onTap,
            ),
          ),
      ],
    );
  }
}
