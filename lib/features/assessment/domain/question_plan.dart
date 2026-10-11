import '../../../shared/domain/app_types.dart';
import '../../questions/domain/question.dart';

/// One planned step in an assessment run: which skill to probe and which
/// interaction style to render it as.
typedef QuestionSpec = ({LanguageSkill skill, QuestionType type});

/// Candidate renderer types for a skill, in rotation order. Adding
/// variety for a skill is a one-line change here — no other file needs
/// to know about it.
List<QuestionType> questionTypesFor(LanguageSkill skill) => switch (skill) {
      LanguageSkill.grammar => const [
          QuestionType.mcq,
          QuestionType.sentenceCorrection,
          QuestionType.fillBlank,
        ],
      LanguageSkill.vocabulary => const [QuestionType.mcq, QuestionType.matching, QuestionType.cloze],
      LanguageSkill.listening => const [QuestionType.listening, QuestionType.dictation],
      LanguageSkill.speaking => const [QuestionType.speaking, QuestionType.conversation],
      LanguageSkill.reading => const [QuestionType.reading, QuestionType.scenario],
      LanguageSkill.writing => const [QuestionType.writing, QuestionType.imageDescription],
    };

/// Builds the ordered sequence of (skill, type) an assessment run will
/// ask, [questionsPerSkill] each, cycling through that skill's types so
/// consecutive questions on the same skill don't share a renderer.
List<QuestionSpec> buildQuestionPlan(List<LanguageSkill> skills, {int questionsPerSkill = 2}) {
  final plan = <QuestionSpec>[];
  for (final skill in skills) {
    final types = questionTypesFor(skill);
    for (var i = 0; i < questionsPerSkill; i++) {
      plan.add((skill: skill, type: types[i % types.length]));
    }
  }
  return plan;
}
