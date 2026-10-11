import '../../../shared/domain/app_types.dart';

/// Outcome of a completed assessment run.
class AssessmentResult {
  const AssessmentResult({
    required this.totalQuestions,
    required this.correctCount,
    required this.scorePercent,
    required this.skillBreakdown,
  });

  final int totalQuestions;
  final int correctCount;

  /// 0-100, computed only over auto-gradable questions.
  final int scorePercent;

  /// Per-skill accuracy, 0.0-1.0, over that skill's gradable questions.
  final Map<LanguageSkill, double> skillBreakdown;
}
