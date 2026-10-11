/// Contract for capturing a spoken answer to a local audio file.
/// Implementations decide *how* (the `record` package, a native
/// channel, ...) — [RecordingAnswerCubit] depends only on this, never
/// on a specific recording package.
abstract interface class QuestionAudioRecorder {
  Future<bool> hasPermission();

  Future<void> start();

  /// Stops recording and returns the local file path, or null if
  /// nothing was captured.
  Future<String?> stop();

  /// Discards the in-progress recording without producing a file.
  Future<void> cancel();
}
