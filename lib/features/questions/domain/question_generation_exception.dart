/// Thrown by a [QuestionGenerator] when a question cannot be produced —
/// missing configuration, network failure, or malformed model output.
/// Kept in the domain layer so callers can display [message] directly
/// without knowing anything about Dio, HTTP, or JSON.
class QuestionGenerationException implements Exception {
  const QuestionGenerationException(this.message);

  final String message;

  @override
  String toString() => 'QuestionGenerationException: $message';
}
