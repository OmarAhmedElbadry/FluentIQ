import 'package:shared_preferences/shared_preferences.dart';

import '../domain/onboarding_repository.dart';

/// Stores the one-time onboarding completion flag on the device.
class SharedPreferencesOnboardingRepository implements OnboardingRepository {
  SharedPreferencesOnboardingRepository(this._preferences);

  static const _storageKey = 'onboarding_complete';
  final SharedPreferences _preferences;

  @override
  Future<bool> isComplete() async => _preferences.getBool(_storageKey) ?? false;

  @override
  Future<void> complete() async {
    await _preferences.setBool(_storageKey, true);
  }
}
