import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Wall-clock countdown for a live assessment run. Purely presentational
/// — [AssessmentRunCubit] owns the actual ticking and decides when time
/// is up; this only renders whatever [remaining] it's given.
class AssessmentTimer extends StatelessWidget {
  const AssessmentTimer({super.key, required this.remaining});

  final Duration remaining;

  /// Below this, the timer calls out that time is running low.
  static const _warningThreshold = Duration(minutes: 1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLow = remaining <= _warningThreshold;
    final color = isLow ? theme.colorScheme.error : theme.colorScheme.onSurface;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.timer_outlined, size: 18, color: color),
        SizedBox(width: AppSpacing.xs),
        Text(
          _format(remaining),
          style: theme.textTheme.labelLarge?.copyWith(color: color),
        ),
      ],
    );
  }

  String _format(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
