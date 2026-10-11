import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/domain/app_types.dart';
import '../domain/preferences_repository.dart';
import '../domain/user_preferences.dart';

/// SharedPreferences adapter for lightweight, device-local user preferences.
class SharedPreferencesPreferencesRepository implements PreferencesRepository {
  SharedPreferencesPreferencesRepository(this._preferences);

  static const _storageKey = 'user_preferences';
  final SharedPreferences _preferences;

  @override
  Future<UserPreferences> load() async {
    final raw = _preferences.getString(_storageKey);
    if (raw == null) return const UserPreferences.defaults();
    try {
      final map = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      return UserPreferences(
        theme: _enumOrDefault(AppThemePreference.values, map['theme'], AppThemePreference.system),
        assessmentLanguage: _enumOrDefault(AppLanguage.values, map['language'], AppLanguage.english),
        textScale: (map['textScale'] as num?)?.toDouble() ?? 1,
        reduceMotion: map['reduceMotion'] as bool? ?? false,
      );
    } on FormatException {
      return const UserPreferences.defaults();
    } on TypeError {
      return const UserPreferences.defaults();
    }
  }

  @override
  Future<void> save(UserPreferences preferences) async {
    await _preferences.setString(
      _storageKey,
      jsonEncode({
        'theme': preferences.theme.name,
        'language': preferences.assessmentLanguage.name,
        'textScale': preferences.textScale,
        'reduceMotion': preferences.reduceMotion,
      }),
    );
  }

  T _enumOrDefault<T extends Enum>(List<T> values, Object? raw, T fallback) {
    if (raw is! String) return fallback;
    for (final value in values) {
      if (value.name == raw) return value;
    }
    return fallback;
  }
}
