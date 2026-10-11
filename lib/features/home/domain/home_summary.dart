import '../../../shared/domain/app_types.dart';

/// Snapshot of the user's most recent completed assessment.
/// Kept UI-agnostic so it can back a card, a notification, or a widget.
class LatestResult {
  const LatestResult({
    required this.title,
    required this.percentile,
    required this.summary,
    this.entryId,
  });

  final String title;

  /// 0-100. Where the user's score ranks against other test takers.
  final int percentile;

  /// Short human-readable note, e.g. improvement since last attempt.
  final String summary;

  /// Id of the underlying history entry, for deep-linking straight to
  /// its detail page. Null when there's no real attempt yet.
  final String? entryId;
}

/// Aggregated data the home dashboard needs, fetched in a single request
/// so the page never has to coordinate multiple in-flight calls.
class HomeSummary {
  const HomeSummary({
    required this.userName,
    required this.language,
    required this.cefrLevel,
    required this.testsTaken,
    required this.averageScorePercent,
    required this.latestResult,
  });

  final String userName;
  final AppLanguage language;
  final CefrLevel cefrLevel;
  final int testsTaken;

  /// 0-100.
  final int averageScorePercent;
  final LatestResult latestResult;
}
