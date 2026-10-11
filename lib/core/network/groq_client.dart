import 'package:dio/dio.dart';
import 'package:fluentiq/core/config/env.dart';

/// Single place that knows how to reach Groq's OpenAI-compatible API.
/// Swapping providers later — or pointing this at your own backend
/// proxy instead of calling Groq directly from the client — means
/// changing this file only.
class GroqClient {
  GroqClient._();

  static Dio create() => Dio(
        BaseOptions(
          baseUrl: 'https://api.groq.com/openai/v1',
          headers: {
            'Authorization': 'Bearer ${Env.groqApiKey}',
            'Content-Type': 'application/json',
          },
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
}
