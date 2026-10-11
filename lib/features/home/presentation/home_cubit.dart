import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/home_repository.dart';
import 'home_state.dart';

/// Loads and holds the dashboard summary shown on [HomePage].
/// All business logic (loading, error handling, retry) lives here —
/// the view only ever reacts to state.
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repository) : super(const HomeLoading());

  final HomeRepository _repository;

  Future<void> load() async {
    emit(const HomeLoading());
    try {
      final summary = await _repository.getSummary();
      emit(HomeLoaded(summary));
    } catch (_) {
      emit(const HomeError('Could not load your dashboard. Pull to retry.'));
    }
  }
}
