import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/presentation/app_components.dart';
import '../../domain/question_review_record.dart';

/// Full review of one answered question: what was asked, what the
/// learner picked or wrote, and — for gradable types — which option
/// was actually correct.
class QuestionReviewTile extends StatelessWidget {
  const QuestionReviewTile({super.key, required this.record, required this.number});

  final QuestionReviewRecord record;
  final int number;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm + AppSpacing.xs),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Q$number · ${record.skill.name}',
                    style: theme.textTheme.labelMedium,
                  ),
                ),
                if (record.wasCorrect != null)
                  Icon(
                    record.wasCorrect! ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    color: record.wasCorrect! ? theme.colorScheme.primary : theme.colorScheme.error,
                    size: 20,
                  ),
              ],
            ),
            SizedBox(height: AppSpacing.xs),
            Text(record.prompt, style: theme.textTheme.titleMedium),
            SizedBox(height: AppSpacing.sm),
            if (record.options.isNotEmpty)
              for (var i = 0; i < record.options.length; i++)
                _OptionRow(record: record, optionIndex: i)
            else
              Text(
                (record.responseText?.isNotEmpty ?? false) ? '"${record.responseText}"' : 'No answer recorded.',
                style: theme.textTheme.bodyLarge,
              ),
            if ((record.explanation ?? '').isNotEmpty) ...[
              SizedBox(height: AppSpacing.sm),
              Text(record.explanation!, style: theme.textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({required this.record, required this.optionIndex});

  final QuestionReviewRecord record;
  final int optionIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = record.selectedIndex == optionIndex;
    final isCorrect = record.correctIndex == optionIndex;

    Color? background;
    IconData? icon;
    Color? iconColor;
    if (isCorrect) {
      background = theme.colorScheme.primary.withValues(alpha: 0.12);
      icon = Icons.check_circle_rounded;
      iconColor = theme.colorScheme.primary;
    } else if (isSelected) {
      background = theme.colorScheme.error.withValues(alpha: 0.12);
      icon = Icons.cancel_rounded;
      iconColor = theme.colorScheme.error;
    }

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.chip,
        border: Border.all(color: background == null ? theme.colorScheme.outline : Colors.transparent),
      ),
      child: Row(
        children: [
          Expanded(child: Text(record.options[optionIndex], style: theme.textTheme.bodyMedium)),
          if (icon != null) Icon(icon, color: iconColor, size: 18),
        ],
      ),
    );
  }
}
