import 'package:dio/dio.dart';

import 'package:fluentiq/core/config/env.dart';
import 'package:fluentiq/features/questions/domain/audio_transcriber.dart';
import 'package:fluentiq/features/questions/domain/audio_transcription_exception.dart';

/// Transcribes recorded answers via Groq's Whisper-compatible
/// transcription endpoint. Reuses the same [Dio] client (base URL, auth
/// header) as [GroqQuestionGenerator] — same API key, no new secrets.
class GroqAudioTranscriber implements AudioTranscriber {
  GroqAudioTranscriber(this._dio);

  final Dio _dio;

  static const _model = 'whisper-large-v3-turbo';

  @override
  Future<String> transcribe(String filePath) async {
    if (!Env.hasGroqApiKey) {
      throw const AudioTranscriptionException(
        'No Groq API key configured. Run with --dart-define=GROQ_API_KEY=your_key.',
      );
    }

    try {
      final formData = FormData.fromMap({
        'model': _model,
        'file': await MultipartFile.fromFile(filePath, filename: 'answer.m4a'),
      });
      final response = await _dio.post<Map<String, dynamic>>('/audio/transcriptions', data: formData);
      final text = response.data?['text'] as String?;
      if (text == null || text.trim().isEmpty) {
        throw const AudioTranscriptionException(
          'Could not make out any speech in that recording. Please try again.',
        );
      }
      return text.trim();
    } on DioException catch (e) {
      throw AudioTranscriptionException(_describeDioError(e));
    }
  }

  String _describeDioError(DioException e) => switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.sendTimeout =>
          'Transcription timed out. Check your connection and try again.',
        DioExceptionType.badResponse => e.response?.statusCode == 401
            ? 'Groq rejected the API key. Double-check GROQ_API_KEY.'
            : 'Transcription failed (${e.response?.statusCode}).',
        _ => 'Could not reach the transcription service. Check your connection.',
      };
}
