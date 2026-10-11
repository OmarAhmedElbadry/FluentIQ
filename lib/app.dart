import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/service_locator.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/domain/preferences_repository.dart';
import 'features/settings/domain/user_preferences.dart';
import 'features/settings/presentation/settings_cubit.dart';

/// Root widget for the LinguaIQ application.
class LinguaIQApp extends StatefulWidget {
  const LinguaIQApp({super.key, required this.onboardingComplete});

  final bool onboardingComplete;

  @override
  State<LinguaIQApp> createState() => _LinguaIQAppState();
}

class _LinguaIQAppState extends State<LinguaIQApp> {
  late final _router = createAppRouter(onboardingComplete: widget.onboardingComplete);

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => SettingsCubit(getIt<PreferencesRepository>())..load(),
        child: BlocBuilder<SettingsCubit, UserPreferences>(
          builder: (context, preferences) => MaterialApp.router(
            title: 'LinguaIQ',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: _toThemeMode(preferences.theme),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(preferences.textScale),
                disableAnimations: preferences.reduceMotion,
              ),
              child: child ?? const SizedBox.shrink(),
            ),
            routerConfig: _router,
          ),
        ),
      );

  ThemeMode _toThemeMode(AppThemePreference preference) => switch (preference) {
        AppThemePreference.system => ThemeMode.system,
        AppThemePreference.light => ThemeMode.light,
        AppThemePreference.dark => ThemeMode.dark,
      };
}
