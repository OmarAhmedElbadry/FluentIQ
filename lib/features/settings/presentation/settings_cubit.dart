import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/domain/app_types.dart';
import '../domain/preferences_repository.dart';
import '../domain/user_preferences.dart';

/// Exposes persisted preferences to the root app and settings presentation.
class SettingsCubit extends Cubit<UserPreferences> {
  SettingsCubit(this._repository) : super(const UserPreferences.defaults());

  final PreferencesRepository _repository;

  Future<void> load() async => emit(await _repository.load());

  Future<void> setTheme(AppThemePreference theme) => _save(state.copyWith(theme: theme));

  Future<void> setLanguage(AppLanguage language) => _save(state.copyWith(assessmentLanguage: language));

  Future<void> setTextScale(double textScale) => _save(state.copyWith(textScale: textScale));

  Future<void> setReduceMotion(bool enabled) => _save(state.copyWith(reduceMotion: enabled));

  Future<void> _save(UserPreferences preferences) async {
    emit(preferences);
    await _repository.save(preferences);
  }
}
