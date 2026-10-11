import 'package:fluentiq/features/questions/domain/question.dart';
import 'package:fluentiq/shared/domain/app_types.dart';

/// Contract for producing a single, fresh assessment question.
/// Implementations decide *how* (Groq, another model, a local bank) —
/// every caller (the assessment run cubit) depends only on this.
abstract interface class QuestionGenerator {
  Future<Question> generateNext({
    required AppLanguage language,
    required CefrLevel level,
    required LanguageSkill skill,
    required QuestionType type,

    /// Titles of questions already asked in this session, so the
    /// implementation can steer generation away from repeating them.
    required List<String> previousPrompts,
  });
}
