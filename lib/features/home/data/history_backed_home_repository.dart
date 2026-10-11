import '../../../shared/domain/app_types.dart';
import '../../../shared/domain/date_format.dart';
import '../../results/domain/assessment_history_repository.dart';
import '../../settings/domain/preferences_repository.dart';
import '../domain/home_repository.dart';
import '../domain/home_summary.dart';

/// Derives the home dashboard from real [AssessmentHistoryRepository]
/// data instead of separate mock numbers — there is exactly one source
/// of truth for "how many tests has this user taken."
///
/// `userName` isn't backed by a profile/auth feature yet, so it stays a
/// constant here until one exists — isolated to this one file, not
/// scattered across the UI. The active language, unlike the name, has a
/// real source: [PreferencesRepository] (the same one Settings and
/// language selection write to).
class HistoryBackedHomeRepository implements HomeRepository {
  HistoryBackedHomeRepository(this._history, this._preferences);

  final AssessmentHistoryRepository _history;
  final PreferencesRepository _preferences;

  static const _userName = 'Alex';

  @override
  Future<HomeSummary> getSummary() async {
    final entries = await _history.getAll(); // newest-first

    if (entries.isEmpty) {
      final preferences = await _preferences.load();
      return HomeSummary(
        userName: _userName,
        language: preferences.assessmentLanguage,
        cefrLevel: CefrLevel.a1,
        testsTaken: 0,
        averageScorePercent: 0,
        latestResult: const LatestResult(
          title: 'No assessments yet',
          percentile: 0,
          summary: 'Take your first assessment to see results here.',
        ),
      );
    }

    final latest = entries.first;
    final averageScore =
        (entries.map((e) => e.scorePercent).reduce((a, b) => a + b) / entries.length).round();

    return HomeSummary(
      userName: _userName,
      language: latest.language,
      cefrLevel: latest.level,
      testsTaken: entries.length,
      averageScorePercent: averageScore,
      latestResult: LatestResult(
        title: latest.assessmentTitle,
        percentile: latest.scorePercent,
        summary: 'Completed ${formatShortDate(latest.completedAt)} · ${latest.totalQuestions} questions.',
        entryId: latest.id,
      ),
    );
  }
}
