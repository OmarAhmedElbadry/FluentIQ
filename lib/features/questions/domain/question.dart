import 'package:fluentiq/shared/domain/app_types.dart';

/// Supported renderers. New types require only a renderer registration.
enum QuestionType { mcq, writing, speaking, listening, reading, matching, fillBlank, sentenceCorrection, punctuation, dictation, conversation, imageDescription, wordOrder, errorIdentification, scenario, cloze }

/// Whether a [QuestionType] can be scored automatically against a stored
/// correct answer, vs. requiring human/AI review (writing, speaking, ...).
extension QuestionTypeX on QuestionType {
  bool get isAutoGradable => switch (this) {
        QuestionType.mcq ||
        QuestionType.matching ||
        QuestionType.fillBlank ||
        QuestionType.sentenceCorrection ||
        QuestionType.punctuation ||
        QuestionType.wordOrder ||
        QuestionType.errorIdentification ||
        QuestionType.cloze ||
        QuestionType.reading ||
        QuestionType.scenario ||
        // Now a real audio+comprehension-MCQ check, not a placeholder.
        QuestionType.listening => true,
        QuestionType.writing ||
        QuestionType.speaking ||
        QuestionType.dictation ||
        QuestionType.conversation ||
        QuestionType.imageDescription => false,
      };

  /// Whether [Question.title] is content that must be conveyed only
  /// through audio (listening/dictation) rather than shown as readable
  /// text — showing it as text would make listening comprehension or
  /// dictation trivial, since the learner could just read it instead.
  bool get isAudioPromptOnly => this == QuestionType.listening || this == QuestionType.dictation;

  /// Whether answering this type requires capturing the learner's voice
  /// (as opposed to typing or selecting an option).
  bool get requiresRecording => this == QuestionType.speaking || this == QuestionType.conversation;

  /// Whether answering this type means typing free text rather than
  /// selecting an option — mirrors [QuestionRenderer]'s text group.
  bool get isTextEntry =>
      this == QuestionType.writing ||
      this == QuestionType.fillBlank ||
      this == QuestionType.cloze ||
      this == QuestionType.dictation;
}

/// UI-agnostic assessment prompt.
class Question {
  const Question({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.language,
    required this.level,
    required this.skill,
    this.options = const [],
    this.correctAnswerIndex,
    this.explanation,
  });

  final String id;
  final QuestionType type;
  final String title;
  final String description;
  final AppLanguage language;
  final CefrLevel level;
  final LanguageSkill skill;
  final List<String> options;

  /// Index into [options]. Only meaningful when [isAutoGradable] is true —
  /// null for free-response types (writing, speaking, ...).
  final int? correctAnswerIndex;

  /// Optional short rationale, shown after grading if available.
  final String? explanation;

  /// Whether [answer] is complete enough to advance past this question:
  /// a selected option index for choice types, non-blank text for typed
  /// or transcribed answers. The run gate and any future validation must
  /// share this single definition.
  bool accepts(dynamic answer) {
    if (type.requiresRecording || type.isTextEntry) {
      return answer is String && answer.trim().isNotEmpty;
    }
    return answer is int && answer >= 0 && answer < options.length;
  }
}
