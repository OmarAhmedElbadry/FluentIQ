import 'package:fluentiq/shared/presentation/latest_result_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/home_repository.dart';
import 'home_cubit.dart';
import 'home_state.dart';
import 'widgets/greeting_header.dart';
import 'widgets/home_empty_state.dart';
import 'widgets/home_error_view.dart';
import 'widgets/language_mastery_card.dart';
import 'widgets/quick_actions_section.dart';
import 'widgets/stat_tile.dart';

/// Personalized dashboard: mastery snapshot, latest result, and quick
/// actions into the rest of the app. Owns nothing but the cubit wiring —
/// all layout lives in `widgets/`, all data lives in [HomeCubit].
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => HomeCubit(getIt<HomeRepository>())..load(),
        child: const _HomeView(),
      );
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => context.read<HomeCubit>().load(),
            child: BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) => switch (state) {
                HomeLoading() => const Center(child: CircularProgressIndicator()),
                HomeError(:final message) => HomeErrorView(
                    message: message,
                    onRetry: () => context.read<HomeCubit>().load(),
                  ),
                HomeLoaded(:final summary) => ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: AppSpacing.screenPadding,
                    children: [
                      GreetingHeader(
                        userName: summary.userName,
                        onSettingsTap: () => context.go('/settings'),
                      ),
                      SizedBox(height: AppSpacing.lg),
                      LanguageMasteryCard(
                        language: summary.language,
                        level: summary.cefrLevel,
                        // Re-enters the existing language selection flow.
                        onTap: () => context.push('/language'),
                      ),
                      SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: StatTile(
                              icon: Icons.fact_check_outlined,
                              iconColor: Theme.of(context).colorScheme.primary,
                              label: 'TESTS TAKEN',
                              value: '${summary.testsTaken}',
                            ),
                          ),
                          SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: StatTile(
                              icon: Icons.speed_rounded,
                              iconColor: Theme.of(context).colorScheme.secondary,
                              label: 'AVG. SCORE',
                              value: '${summary.averageScorePercent}%',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.lg),
                      if (summary.testsTaken == 0)
                        HomeEmptyState(onStart: () => context.push('/assessments'))
                      else
                        LatestResultCard(
                          title: summary.latestResult.title,
                          percentile: summary.latestResult.percentile,
                          summary: summary.latestResult.summary,
                          onViewBreakdown: () => summary.latestResult.entryId != null
                              ? context.push('/results/${summary.latestResult.entryId}')
                              : context.push('/results'),
                        ),
                      SizedBox(height: AppSpacing.xl),
                      QuickActionsSection(
                        actions: [
                          QuickAction(
                            icon: Icons.bolt_rounded,
                            iconColor: Theme.of(context).colorScheme.primary,
                            title: 'Start New Test',
                            subtitle: 'Comprehensive AI evaluation',
                            // Reuses the existing assessment catalogue.
                            onTap: () => context.push('/assessments'),
                          ),
                          QuickAction(
                            icon: Icons.mic_rounded,
                            iconColor: Theme.of(context).colorScheme.secondary,
                            title: 'Speaking Practice',
                            subtitle: 'Real-time feedback session',
                            // Drops straight into a live, AI-generated quick session.
                            onTap: () => context.push('/assessment-run/quick'),
                          ),
                          QuickAction(
                            icon: Icons.bar_chart_rounded,
                            iconColor: AppColors.purple,
                            title: 'Assessment History',
                            subtitle: 'Track your progress over time',
                            onTap: () => context.push('/results'),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.lg),
                    ],
                  ),
              },
            ),
          ),
        ),
      );
}
