import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/presentation/app_components.dart';
import 'onboarding_cubit.dart';

/// Guest-first introduction to the adaptive assessment experience.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                const Spacer(),
                Lottie.asset(
                  'assets/lottie/language_assessment.json',
                  height: 240,
                  repeat: !MediaQuery.of(context).disableAnimations,
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('Find your real\nlanguage level.',
                    textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Take adaptive assessments, receive clear AI feedback, and track your CEFR progress—all without an account.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const Spacer(),
                AppButton(
                  label: 'Get Started',
                  onPressed: () async {
                    await context.read<OnboardingCubit>().complete();
                    if (context.mounted) context.go('/home');
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Your progress is saved privately on this device.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ),
      );}