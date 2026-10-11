import 'package:fluentiq/features/assessment/data/mock_assessment_repository.dart';
import 'package:fluentiq/features/assessment/domain/assessment_repository.dart';
import 'package:fluentiq/features/home/data/history_backed_home_repository.dart';
import 'package:fluentiq/features/home/domain/home_repository.dart';
import 'package:fluentiq/features/onboarding/data/shared_preferences_onboarding_repository.dart';
import 'package:fluentiq/features/onboarding/domain/onboarding_repository.dart';
import 'package:fluentiq/features/questions/data/groq_audio_transcriber.dart';
import 'package:fluentiq/features/questions/data/groq_question_generator.dart';
import 'package:fluentiq/features/questions/data/record_package_audio_recorder.dart';
import 'package:fluentiq/features/questions/domain/audio_recorder.dart';
import 'package:fluentiq/features/questions/domain/audio_transcriber.dart';
import 'package:fluentiq/features/questions/domain/question_generator.dart';
import 'package:fluentiq/features/results/data/shared_preferences_assessment_history_repository.dart';
import 'package:fluentiq/features/results/domain/assessment_history_repository.dart';
import 'package:fluentiq/features/settings/data/shared_preferences_preferences_repository.dart';
import 'package:fluentiq/features/settings/domain/preferences_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/groq_client.dart';

/// The application's composition root for local and API-backed services.
final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  final preferences = await SharedPreferences.getInstance();

  getIt.registerLazySingleton<AssessmentRepository>(MockAssessmentRepository.new);
  getIt.registerLazySingleton<AssessmentHistoryRepository>(
    () => SharedPreferencesAssessmentHistoryRepository(preferences),
  );
  getIt.registerLazySingleton<PreferencesRepository>(
    () => SharedPreferencesPreferencesRepository(preferences),
  );
  getIt.registerLazySingleton<HomeRepository>(
    () => HistoryBackedHomeRepository(
      getIt<AssessmentHistoryRepository>(),
      getIt<PreferencesRepository>(),
    ),
  );
  getIt.registerLazySingleton<QuestionGenerator>(() => GroqQuestionGenerator(GroqClient.create()));
  getIt.registerLazySingleton<AudioTranscriber>(() => GroqAudioTranscriber(GroqClient.create()));
  getIt.registerLazySingleton<QuestionAudioRecorder>(RecordPackageAudioRecorder.new);
  getIt.registerLazySingleton<OnboardingRepository>(
    () => SharedPreferencesOnboardingRepository(preferences),
  );
}
