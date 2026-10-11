import '../../../shared/domain/app_types.dart';

/// Theme choices exposed to a LinguaIQ user.
enum AppThemePreference { system, light, dark }

extension AppThemePreferenceX on AppThemePreference {
  String get label => switch (this) {
        AppThemePreference.system => 'System default',
        AppThemePreference.light => 'Light',
        AppThemePreference.dark => 'Dark',
      };
}

/// Persistent, user-controlled display and assessment preferences.
class UserPreferences {
  const UserPreferences({
    required this.theme,
    required this.assessmentLanguage,
    required this.textScale,
    required this.reduceMotion,
  });

  const UserPreferences.defaults()
      : theme = AppThemePreference.system,
        assessmentLanguage = AppLanguage.english,
        textScale = 1,
        reduceMotion = false;

  final AppThemePreference theme;
  final AppLanguage assessmentLanguage;
  final double textScale;
  final bool reduceMotion;

  UserPreferences copyWith({
    AppThemePreference? theme,
    AppLanguage? assessmentLanguage,
    double? textScale,
    bool? reduceMotion,
  }) =>
      UserPreferences(
        theme: theme ?? this.theme,
        assessmentLanguage: assessmentLanguage ?? this.assessmentLanguage,
        textScale: textScale ?? this.textScale,
        reduceMotion: reduceMotion ?? this.reduceMotion,
      );
}
