import 'home_summary.dart';

/// Contract separating the home dashboard from its data source.
/// Currently backed by [HistoryBackedHomeRepository]; swap for a
/// Dio-backed implementation later without touching the cubit or any
/// widget.
abstract interface class HomeRepository {
  Future<HomeSummary> getSummary();
}
