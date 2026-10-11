import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/onboarding_repository.dart';

/// Completes onboarding independently of its visual presentation.
class OnboardingCubit extends Cubit<bool> {
  OnboardingCubit(this._repository) : super(false);

  final OnboardingRepository _repository;

  Future<void> complete() async {
    await _repository.complete();
    emit(true);
  }
}
