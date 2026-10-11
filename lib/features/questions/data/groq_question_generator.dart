import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fluentiq/core/config/env.dart';
import 'package:fluentiq/features/questions/domain/question_generation_exception.dart';
import 'package:fluentiq/features/questions/domain/question_generator.dart';
import 'package:fluentiq/features/questions/domain/question.dart';
import 'package:fluentiq/shared/domain/app_types.dart';

/// Generates assessment questions on demand via Groq's OpenAI-compatible
/// chat completions API. Structured JSON output keeps parsing simple and
/// decoupled from prompt wording — swap the prompt or the model without
/// touching any caller.
class GroqQuestionGenerator implements QuestionGenerator {
  GroqQuestionGenerator(this._dio);

  final Dio _dio;

  static const _systemPrompt =
      'You are an assessment item writer for a CEFR-aligned language '
      'learning app. You always respond with a single, strictly valid '
      'JSON object and nothing else — no markdown, no commentary.';

  @override
  Future<Question> generateNext({
    required AppLanguage language,
    required CefrLevel level,
    required LanguageSkill skill,
    required QuestionType type,
    required List<String> previousPrompts,
  }) async {
    if (!Env.hasGroqApiKey) {
      throw const QuestionGenerationException(
        'No Groq API key configured. Run with --dart-define=GROQ_API_KEY=your_key.',
      );
    }

    try {
      for (final model in Env.groqModels) {
        try {
          final response = await _dio.post<Map<String, dynamic>>(
            '/chat/completions',
            data: {
              'model': model,
              'temperature': 0.9,
              'response_format': {'type': 'json_object'},
              'messages': [
                {'role': 'system', 'content': _systemPrompt},
                {
                  'role': 'user',
                  'content': _userPrompt(
                    language: language,
                    level: level,
                    skill: skill,
                    type: type,
                    previousPrompts: previousPrompts,
                  ),
                },
              ],
            },
          );

          final content = _contentFrom(response.data);
          if (content == null || content.isEmpty) {
            throw const QuestionGenerationException('The model returned an empty response.');
          }

          final payload = jsonDecode(content);
          if (payload is! Map<String, dynamic>) {
            throw const QuestionGenerationException(
              'The model returned an invalid question payload. Please try again.',
            );
          }
          return _toQuestion(
            payload,
            language: language,
            level: level,
            skill: skill,
            type: type,
          );
        } on DioException catch (error) {
          if (_isModelUnavailable(error) && model != Env.groqModels.last) continue;
          rethrow;
        }
      }
      throw const QuestionGenerationException('No configured Groq model is currently available.');
    } on DioException catch (e) {
      throw QuestionGenerationException(_describeDioError(e));
    } on FormatException {
      throw const QuestionGenerationException('Could not parse the generated question. Please try again.');
    } on TypeError {
      throw const QuestionGenerationException('The model returned an unexpected shape. Please try again.');
    }
  }

  String _userPrompt({
    required AppLanguage language,
    required CefrLevel level,
    required LanguageSkill skill,
    required QuestionType type,
    required List<String> previousPrompts,
  }) {
    final avoidBlock =
        previousPrompts.isEmpty ? 'None yet.' : previousPrompts.map((p) => '- $p').join('\n');

    return '''
Generate ONE ${type.name} question that assesses the "${skill.name}" skill
in ${language.label}, targeting CEFR level ${level.label}.

Do not repeat, paraphrase, or closely resemble any of these questions
already used in this session:
$avoidBlock

Use a fresh topic, scenario, and vocabulary each time.

Respond with exactly this JSON shape:
{
  "prompt": "the actual question content the learner reads and answers",
  "instruction": "one short sentence telling the learner what to do",
  "options": ["option A", "option B", "option C", "option D"],
  "correctAnswerIndex": 0,
  "explanation": "one sentence explaining why that option is correct"
}

CRITICAL — "prompt" must be the real, complete content the learner
needs, never a generic label or category name. It is the single most
important field: if you leave it generic, the learner has nothing to
answer.
- sentenceCorrection, errorIdentification, punctuation, wordOrder,
  fillBlank, cloze: "prompt" MUST be a complete sentence in
  ${language.label} containing the gap, error, or scrambled words (use
  "___" for a blank). Example: "She ___ to school every day."
  NOT "Choose the correct verb form." — that belongs in "instruction".
- mcq, matching: "prompt" is the actual question or word/phrase being
  tested, not a category name.
- reading, scenario: "prompt" is a short passage or scenario (2-4
  sentences) the question is based on.
- listening: "prompt" is the exact sentence or short passage the
  learner will hear read aloud (never shown as text). "options" and
  "correctAnswerIndex" MUST be a comprehension question about that
  passage — e.g. a detail, inference, or "what did the speaker say"
  check with 3-5 answer choices, exactly like an mcq question.
- dictation: "prompt" is the exact sentence or short passage the
  learner will hear read aloud and must transcribe. Return
  "options": [] and "correctAnswerIndex": null for this type only.
- writing, speaking, conversation, imageDescription: "prompt" is the
  full concrete task itself (the essay topic, the conversation opener,
  the image scenario) — specific, never generic.

"instruction" is ONLY the short action line ("Choose the correct
option.", "Correct the error above.") — never repeat "prompt"'s
content there.

Rules:
- If this question type naturally has no discrete answer choices (e.g.
  a writing, speaking, dictation, conversation, or image description
  prompt), return "options": [] and "correctAnswerIndex": null.
- Otherwise (including listening) return 3 to 5 concise options and
  the 0-based index of the single correct one.
- Keep "prompt" under 50 words (short passages may run longer, up to
  about 60 words).
''';
  }

  String? _contentFrom(Map<String, dynamic>? data) {
    final choices = data?['choices'];
    if (choices is! List || choices.isEmpty) return null;

    final choice = choices.first;
    if (choice is! Map) return null;
    final message = choice['message'];
    if (message is! Map) return null;
    final content = message['content'];
    return content is String ? content : null;
  }

  Question _toQuestion(
    Map<String, dynamic> json, {
    required AppLanguage language,
    required CefrLevel level,
    required LanguageSkill skill,
    required QuestionType type,
  }) {
    final prompt = json['prompt'];
    if (prompt is! String || prompt.trim().isEmpty) {
      throw const QuestionGenerationException(
        'The generated question is missing its question content. Please try again.',
      );
    }

    final rawOptions = json['options'];
    if (rawOptions is! List || rawOptions.any((option) => option is! String)) {
      throw const QuestionGenerationException(
        'The generated question has invalid answer options. Please try again.',
      );
    }
    final options = rawOptions.cast<String>().map((option) => option.trim()).toList();
    final rawIndex = json['correctAnswerIndex'];
    final correctAnswerIndex =
        rawIndex is int && rawIndex >= 0 && rawIndex < options.length ? rawIndex : null;

    if (type.isAutoGradable &&
        (options.length < 3 || options.length > 5 || correctAnswerIndex == null)) {
      throw const QuestionGenerationException(
        'The generated question cannot be scored. Please try again.',
      );
    }

    return Question(
      id: '${skill.name}-${type.name}-${DateTime.now().microsecondsSinceEpoch}',
      type: type,
      title: prompt.trim(),
      description: (json['instruction'] as String?)?.trim() ?? '',
      language: language,
      level: level,
      skill: skill,
      options: options,
      correctAnswerIndex: correctAnswerIndex,
      explanation: (json['explanation'] as String?)?.trim(),
    );
  }

  String _describeDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'The question generator timed out. Check your connection and try again.';
    }
    if (error.type != DioExceptionType.badResponse) {
      return 'Could not reach the question generator. Check your connection.';
    }

    return switch (statusCode) {
      400 => _apiMessage(error.response?.data) ??
          'Groq rejected this request. Check the selected model and request format.',
      401 || 403 => 'Groq rejected the API key. Create a new key and rerun with GROQ_API_KEY.',
      404 => 'The configured Groq model is unavailable. Set GROQ_MODEL to a model available to your account.',
      429 => 'Groq rate limit reached. Please wait a moment and try again.',
      _ => _apiMessage(error.response?.data) ??
          'The question generator returned an error${statusCode == null ? '' : ' ($statusCode)'}.',
    };
  }

  String? _apiMessage(Object? data) {
    if (data is! Map) return null;
    final error = data['error'];
    if (error is Map && error['message'] is String) return error['message'] as String;
    return data['message'] is String ? data['message'] as String : null;
  }

  bool _isModelUnavailable(DioException error) {
    if (error.response?.statusCode == 404) return true;
    final message = _apiMessage(error.response?.data)?.toLowerCase();
    if (message == null || !message.contains('model')) return false;
    return message.contains('not found') ||
        message.contains('not available') ||
        message.contains('decommissioned');
  }
}

//