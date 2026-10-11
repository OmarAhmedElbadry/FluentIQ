import 'package:fluentiq/features/results/presentation/result_detail_page.dart';
import 'package:fluentiq/features/results/presentation/results_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/assessment/presentation/assessment_page.dart';
import '../../features/assessment/presentation/assessment_run_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/language/presentation/language_selection_page.dart';
import '../../features/onboarding/domain/onboarding_repository.dart';
import '../../features/onboarding/presentation/onboarding_cubit.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../shared/presentation/app_shell.dart';
import '../di/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Declarative application navigation with a persistent bottom shell.
GoRouter createAppRouter({required bool onboardingComplete}) => GoRouter(
  initialLocation: onboardingComplete ? '/home' : '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (_, __) => BlocProvider(
        create: (_) => OnboardingCubit(getIt<OnboardingRepository>()),
        child: const OnboardingPage(),
      ),
    ),
    GoRoute(path: '/language', builder: (_, __) => const LanguageSelectionPage()),
    GoRoute(path: '/assessment/:id', builder: (_, state) => AssessmentPage(id: state.pathParameters['id']!)),
    GoRoute(
      path: '/assessment-run/:id',
      builder: (_, state) => AssessmentRunPage(assessmentId: state.pathParameters['id']!),
    ),
    GoRoute(path: '/results/:id', builder: (_, state) => ResultDetailPage(id: state.pathParameters['id']!)),
    ShellRoute(
      builder: (_, __, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomePage()),
        GoRoute(path: '/assessments', builder: (_, __) => const AssessmentCatalogPage()),
        GoRoute(path: '/results', builder: (_, __) => const ResultsPage()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
      ],
    ),
  ],
);

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text(title)));
}
