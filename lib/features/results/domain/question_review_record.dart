import '../../../shared/domain/app_types.dart';

/// Review data for a single question within a saved attempt — enough for
/// the learner to replay what was asked, what they chose, and what was
/// right. Written by the assessment feature at save time; kept free of
/// any dependency on live [Question] objects so stored history stays
/// decoupled from future question-model changes.
class QuestionReviewRecord {
  const QuestionReviewRecord({
    required this.prompt,
    required this.skill,
    this.options = const [],
    this.selectedIndex,
    this.correctIndex,
    this.responseText,
    this.wasCorrect,
    this.explanation,
  });

  /// The question as it was presented (title/description combined source).
  final String prompt;
  final LanguageSkill skill;

  /// Choice options, empty for free-response types.
  final List<String> options;

  /// Option the learner picked; null for free-response answers.
  final int? selectedIndex;

  /// Correct option; null when the type is not auto-gradable.
  final int? correctIndex;

  /// Typed or transcribed answer; null for choice-based answers.
  final String? responseText;

  /// Null when the answer could not be graded automatically.
  final bool? wasCorrect;
  final String? explanation;
}
