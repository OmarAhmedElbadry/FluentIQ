import 'assessment_history_entry.dart';

/// Contract for persisting and reading completed assessment attempts.
/// [AssessmentRunCubit] writes through this after every completed run;
/// the results feature and the home dashboard both read through it —
/// neither one owns or duplicates the other's data.
abstract interface class AssessmentHistoryRepository {
  Future<void> save(AssessmentHistoryEntry entry);

  /// Newest-first.
  Future<List<AssessmentHistoryEntry>> getAll();

  Future<AssessmentHistoryEntry?> getById(String id);
}
