/// Persists whether the user has completed the local, guest-first onboarding.
abstract interface class OnboardingRepository {
  Future<bool> isComplete();
  Future<void> complete();
}
