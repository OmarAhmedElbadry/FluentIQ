import 'package:fluentiq/features/results/domain/assessment_history_entry.dart';

sealed class ResultsState {
  const ResultsState();
}

class ResultsLoading extends ResultsState {
  const ResultsLoading();
}

class ResultsLoaded extends ResultsState {
  const ResultsLoaded(this.entries);
  final List<AssessmentHistoryEntry> entries;
}

class ResultsError extends ResultsState {
  const ResultsError(this.message);
  final String message;
}
