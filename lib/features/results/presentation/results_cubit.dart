import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/assessment_history_repository.dart';
import 'results_state.dart';

class ResultsCubit extends Cubit<ResultsState> {
  ResultsCubit(this._history) : super(const ResultsLoading());

  final AssessmentHistoryRepository _history;

  Future<void> load() async {
    emit(const ResultsLoading());
    try {
      final entries = await _history.getAll();
      emit(ResultsLoaded(entries));
    } catch (_) {
      emit(const ResultsError('Could not load your assessment history.'));
    }
  }
}
