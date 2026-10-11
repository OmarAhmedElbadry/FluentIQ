import '../../../shared/domain/app_types.dart';
import '../../questions/domain/question.dart';
import '../domain/assessment_result.dart';

/// Sealed so `switch` in the view is exhaustive at compile time.
sealed class AssessmentRunState {
  const AssessmentRunState();
}

class AssessmentRunLoading extends AssessmentRunState {
  const AssessmentRunLoading();
}

class AssessmentRunInProgress extends AssessmentRunState {
  const AssessmentRunInProgress({
    required this.question,
    required this.index,
    required this.total,
    required this.level,
    required this.hasAnswer,
    required this.remaining,
  });

  final Question question;
  final int index;
  final int total;
  final CefrLevel level;

  /// Whether the current answer satisfies [Question.accepts] — the view
  /// gates its continue button on this; the rule lives in the domain.
  final bool hasAnswer;

  /// Wall clock left before the run is finalized automatically.
  final Duration remaining;
}

class AssessmentRunCompleted extends AssessmentRunState {
  const AssessmentRunCompleted(this.result);
  final AssessmentResult result;
}

class AssessmentRunError extends AssessmentRunState {
  const AssessmentRunError(this.message);
  final String message;
}
