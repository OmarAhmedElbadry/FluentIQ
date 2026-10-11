import '../../../shared/domain/app_types.dart';
import '../domain/assessment.dart';
import '../domain/assessment_repository.dart';

/// Temporary API-shaped source that can be replaced by a Dio implementation.
class MockAssessmentRepository implements AssessmentRepository {
  @override
  Future<List<Assessment>> getAvailable({AppLanguage? language}) async {
    final resolvedLanguage = language ?? AppLanguage.english;
    return [
      Assessment(
        id: 'quick',
        title: 'Quick assessment',
        duration: '5–10 min',
        description: 'A smart snapshot of your current level.',
        language: resolvedLanguage,
        skills: const [LanguageSkill.grammar, LanguageSkill.vocabulary, LanguageSkill.reading],
        timeLimit: const Duration(minutes: 10),
      ),
      Assessment(
        id: 'standard',
        title: 'Standard assessment',
        duration: '20 min',
        description: 'A balanced adaptive proficiency assessment.',
        language: resolvedLanguage,
        skills: const [
          LanguageSkill.grammar,
          LanguageSkill.vocabulary,
          LanguageSkill.listening,
          LanguageSkill.reading,
          LanguageSkill.writing,
        ],
        timeLimit: const Duration(minutes: 20),
      ),
      Assessment(
        id: 'full',
        title: 'Full assessment',
        duration: '40–60 min',
        description: 'The most complete AI-powered language profile.',
        language: resolvedLanguage,
        skills: const [
          LanguageSkill.grammar,
          LanguageSkill.vocabulary,
          LanguageSkill.listening,
          LanguageSkill.speaking,
          LanguageSkill.reading,
          LanguageSkill.writing,
        ],
        timeLimit: const Duration(minutes: 45),
      ),
    ];
  }
}
