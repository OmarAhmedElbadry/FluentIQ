import 'user_preferences.dart';

/// Contract for storing and retrieving user-controlled app preferences.
abstract interface class PreferencesRepository {
  Future<UserPreferences> load();
  Future<void> save(UserPreferences preferences);
}
