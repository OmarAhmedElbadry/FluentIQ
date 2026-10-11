import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/service_locator.dart';
import '../../../shared/presentation/app_components.dart';
import '../../settings/presentation/settings_cubit.dart';
import '../domain/assessment.dart';
import '../domain/assessment_repository.dart';

/// Displays either the assessment catalogue or configuration details.
class AssessmentCatalogPage extends StatelessWidget {
  const AssessmentCatalogPage({super.key});
  @override
  Widget build(BuildContext context) {
    // Rebuilds automatically when the user changes their assessment
    // language in Settings or on the language selection screen.
    final language = context.watch<SettingsCubit>().state.assessmentLanguage;
    return FutureBuilder<List<Assessment>>(
        future: getIt<AssessmentRepository>().getAvailable(language: language),
        builder: (context, snapshot) => Scaffold(body: SafeArea(child: ListView(padding: const EdgeInsets.all(20), children: [
          Text('Assessments', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8), const Text('Select the depth that fits your time today.'), const SizedBox(height: 24),
          if (!snapshot.hasData) const Center(child: Padding(padding: EdgeInsets.all(36), child: CircularProgressIndicator()))
          else ...snapshot.data!.map((a) => Padding(padding: const EdgeInsets.only(bottom: 12), child: AppCard(onTap: () => context.push('/assessment/${a.id}'), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text(a.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))), Text(a.duration)]), const SizedBox(height: 8), Text(a.description), const SizedBox(height: 16), Wrap(spacing: 8, children: a.skills.map((skill) => Chip(label: Text(skill.name))).toList())])))),
        ]))),
      );
  }
}

class AssessmentPage extends StatelessWidget {
  const AssessmentPage({super.key, required this.id});
  final String id;
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(), body: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Ready to begin?', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const Text('The assessment adapts in real time. There are no lessons or practice activities—just an accurate measure of your current ability.'),
        const SizedBox(height: 28),
        const AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Before you start', style: TextStyle(fontWeight: FontWeight.bold)), SizedBox(height: 8), Text('• Answer without outside help\n• Find a quiet place for listening and speaking\n• You can pause between sections')])),
        const Spacer(),
        AppButton(label: 'Start assessment', onPressed: () => context.go('/assessment-run/$id')),
      ])));
}
