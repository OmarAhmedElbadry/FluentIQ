import 'package:flutter/material.dart';

import '../../../shared/domain/app_types.dart';
import '../domain/question.dart';

/// Dynamically selects a widget renderer from the question type, keeping data and UI decoupled.
class QuestionPage extends StatelessWidget {
  const QuestionPage({super.key, required this.questionId});
  final String questionId;
  static const _example = Question(id: 'sample', type: QuestionType.mcq, title: 'Choose the correct sentence', description: 'Select the grammatically correct option.', language: AppLanguage.english, level: CefrLevel.b1, skill: LanguageSkill.grammar, options: ['She has lived here since 2020.', 'She have lived here since 2020.', 'She is lived here since 2020.']);

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Question 1 of 12')), body: SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        LinearProgressIndicator(value: .08, borderRadius: BorderRadius.circular(8)),
        const SizedBox(height: 32),
        Text(_example.skill.name.toUpperCase(), style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12), Text(_example.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10), Text(_example.description), const SizedBox(height: 24),
      ]))));
}

