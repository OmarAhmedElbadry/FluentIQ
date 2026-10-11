/// Thrown by an [AudioTranscriber] when a recording cannot be
/// transcribed — missing configuration, network failure, or an
/// unreadable response. Kept in the domain layer so callers can show
/// [message] directly without knowing anything about Dio or HTTP.
class AudioTranscriptionException implements Exception {
  const AudioTranscriptionException(this.message);

  final String message;

  @override
  String toString() => 'AudioTranscriptionException: $message';
}
