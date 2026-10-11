/// Contract for turning a recorded answer into text. Implementations
/// decide *how* (Groq Whisper, another provider, on-device) — the
/// recording cubit depends only on this.
abstract interface class AudioTranscriber {
  /// [filePath] is a local audio file produced by a [QuestionAudioRecorder].
  Future<String> transcribe(String filePath);
}
