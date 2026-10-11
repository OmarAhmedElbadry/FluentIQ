import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/domain/app_types.dart';
import '../../../shared/presentation/app_components.dart';
import '../../settings/presentation/settings_cubit.dart';

/// Chooses the language assessments are conducted and graded in.
/// Persists through [SettingsCubit] — the same preference Settings
/// shows and edits, so there is exactly one source of truth for it.
class LanguageSelectionPage extends StatelessWidget {
  const LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final current = context.watch<SettingsCubit>().state.assessmentLanguage;
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Which language?',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('You can change this later in settings.'),
            const SizedBox(height: 24),
            ...AppLanguage.values.map(
              (language) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  onTap: () {
                    context.read<SettingsCubit>().setLanguage(language);
                    context.go('/home');
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        child: Icon(language == current ? Icons.check : Icons.language),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: Text(language.label, style: Theme.of(context).textTheme.titleMedium)),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
