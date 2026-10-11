import '../domain/home_summary.dart';

/// Sealed so `switch` in the view is exhaustive at compile time —
/// adding a new state forces every consumer to handle it.
sealed class HomeState {
  const HomeState();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  const HomeLoaded(this.summary);
  final HomeSummary summary;
}

class HomeError extends HomeState {
  const HomeError(this.message);
  final String message;
}
