import 'package:fluentiq/shared/domain/app_types.dart';
import 'question_review_record.dart';

/// A single completed assessment attempt, persisted for the history list
/// and the home dashboard's "latest result" — the durable record an
/// [AssessmentResult] (transient, just-finished-screen data) becomes
/// once saved.
class AssessmentHistoryEntry {
  const AssessmentHistoryEntry({
    required this.id,
    required this.assessmentId,
    required this.assessmentTitle,
    required this.language,
    required this.level,
    required this.scorePercent,
    required this.totalQuestions,
    required this.skillBreakdown,
    required this.completedAt,
    this.questions = const [],
  });

  final String id;

  /// Which catalogue [Assessment] this attempt was based on.
  final String assessmentId;
  final String assessmentTitle;
  final AppLanguage language;

  /// CEFR level reached by the end of this run (after adaptation).
  final CefrLevel level;

  /// 0-100, computed only over auto-gradable questions.
  final int scorePercent;
  final int totalQuestions;

  /// Per-skill accuracy, 0.0-1.0.
  final Map<LanguageSkill, double> skillBreakdown;
  final DateTime completedAt;

  /// Per-question review data. Empty for entries saved before review
  /// capture existed — the UI treats that as "no breakdown available".
  final List<QuestionReviewRecord> questions;
}
