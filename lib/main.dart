import 'package:flutter/widgets.dart';

import 'app.dart';
import 'core/di/service_locator.dart';
import 'features/onboarding/domain/onboarding_repository.dart';

/// Configures application services before displaying LinguaIQ.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  final onboardingComplete = await getIt<OnboardingRepository>().isComplete();
  runApp(LinguaIQApp(onboardingComplete: onboardingComplete));
}
