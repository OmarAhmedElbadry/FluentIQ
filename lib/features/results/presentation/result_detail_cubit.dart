import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fluentiq/features/results/domain/assessment_history_repository.dart';
import 'result_detail_state.dart';

class ResultDetailCubit extends Cubit<ResultDetailState> {
  ResultDetailCubit(this._history) : super(const ResultDetailLoading());

  final AssessmentHistoryRepository _history;

  Future<void> load(String id) async {
    emit(const ResultDetailLoading());
    try {
      final entry = await _history.getById(id);
      if (entry == null) {
        emit(const ResultDetailError('That result could not be found.'));
      } else {
        emit(ResultDetailLoaded(entry));
      }
    } catch (_) {
      emit(const ResultDetailError('Could not load this result.'));
    }
  }
}
