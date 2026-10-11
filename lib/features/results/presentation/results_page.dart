import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/domain/date_format.dart';
import '../../../shared/presentation/latest_result_card.dart';
import '../domain/assessment_history_repository.dart';
import 'results_cubit.dart';
import 'results_state.dart';
import 'widgets/history_entry_tile.dart';
import 'widgets/results_empty_view.dart';

/// The Results tab: highlights the most recent attempt, lists every
/// past attempt underneath. Owns cubit wiring only — data lives in
/// [ResultsCubit], rows are [HistoryEntryTile].
class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => ResultsCubit(getIt<AssessmentHistoryRepository>())..load(),
        child: const _ResultsView(),
      );
}

class _ResultsView extends StatelessWidget {
  const _ResultsView();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => context.read<ResultsCubit>().load(),
            child: BlocBuilder<ResultsCubit, ResultsState>(
              builder: (context, state) => switch (state) {
                ResultsLoading() => const Center(child: CircularProgressIndicator()),
                ResultsError(:final message) => _ErrorView(
                    message: message,
                    onRetry: () => context.read<ResultsCubit>().load(),
                  ),
                ResultsLoaded(:final entries) when entries.isEmpty =>
                  ResultsEmptyView(onStart: () => context.push('/assessments')),
                ResultsLoaded(:final entries) => ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: AppSpacing.screenPadding,
                    children: [
                      Text('Results', style: Theme.of(context).textTheme.headlineLarge),
                      SizedBox(height: AppSpacing.lg),
                      LatestResultCard(
                        title: entries.first.assessmentTitle,
                        percentile: entries.first.scorePercent,
                        summary:
                            'Completed ${formatShortDate(entries.first.completedAt)} · ${entries.first.totalQuestions} questions.',
                        onViewBreakdown: () => context.push('/results/${entries.first.id}'),
                      ),
                      SizedBox(height: AppSpacing.xl),
                      Text('HISTORY', style: Theme.of(context).textTheme.labelMedium),
                      SizedBox(height: AppSpacing.sm + AppSpacing.xs),
                      for (final entry in entries)
                        HistoryEntryTile(entry: entry, onTap: () => context.push('/results/${entry.id}')),
                    ],
                  ),
              },
            ),
          ),
        ),
      );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 40),
              SizedBox(height: AppSpacing.sm),
              Text(message, textAlign: TextAlign.center),
              SizedBox(height: AppSpacing.md),
              OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      );
}
