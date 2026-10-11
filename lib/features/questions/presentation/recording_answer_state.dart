sealed class RecordingAnswerState {
  const RecordingAnswerState();
}

class RecordingIdle extends RecordingAnswerState {
  const RecordingIdle();
}

class RecordingInProgress extends RecordingAnswerState {
  const RecordingInProgress();
}

class RecordingTranscribing extends RecordingAnswerState {
  const RecordingTranscribing();
}

class RecordingTranscribed extends RecordingAnswerState {
  const RecordingTranscribed(this.transcript);
  final String transcript;
}

class RecordingError extends RecordingAnswerState {
  const RecordingError(this.message);
  final String message;
}
