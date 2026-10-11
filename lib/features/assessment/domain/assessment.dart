import '../../../shared/domain/app_types.dart';

/// A selectable assessment configuration.
class Assessment {
  const Assessment({
    required this.id,
    required this.title,
    required this.duration,
    required this.description,
    required this.language,
    required this.skills,
    required this.timeLimit,
  });
  final String id;
  final String title;

  /// Human-readable duration for the catalogue card (e.g. '5–10 min').
  final String duration;
  final String description;
  final AppLanguage language;
  final List<LanguageSkill> skills;

  /// Enforced wall-clock limit for a run. When it elapses, the cubit
  /// finalizes the result over the questions answered so far.
  final Duration timeLimit;
}
