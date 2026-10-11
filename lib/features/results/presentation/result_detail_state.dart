import 'package:fluentiq/features/results/domain/assessment_history_entry.dart';

sealed class ResultDetailState {
  const ResultDetailState();
}

class ResultDetailLoading extends ResultDetailState {
  const ResultDetailLoading();
}

class ResultDetailLoaded extends ResultDetailState {
  const ResultDetailLoaded(this.entry);
  final AssessmentHistoryEntry entry;
}

class ResultDetailError extends ResultDetailState {
  const ResultDetailError(this.message);
  final String message;
}
