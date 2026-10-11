/// Build-time configuration, injected via `--dart-define` and never
/// committed to source control or bundled as a literal.
///
/// Run with:
///   flutter run --dart-define=GROQ_API_KEY=your_key_here
/// Build with:
///   flutter build apk --dart-define=GROQ_API_KEY=your_key_here
///
/// Note: any key baked into a shipped mobile client — by this method or
/// any other — can in principle be extracted from the compiled binary.
/// For a production release, proxy AI calls through your own backend
/// instead of calling Groq directly from the app.
class Env {
  Env._();

  static const String groqApiKey = String.fromEnvironment('GROQ_API_KEY');
  /// Comma-separated, ordered model candidates. Override with
  /// `--dart-define=GROQ_MODELS=model-a,model-b` when needed.
  static const String _groqModels = String.fromEnvironment(
    'GROQ_MODELS',
    defaultValue: 'openai/gpt-oss-20b,openai/gpt-oss-120b,llama-3.1-8b-instant',
  );

  /// The first configured model, retained for diagnostics and simple clients.
  static String get groqModel => groqModels.first;

  /// Ordered fallback candidates with blank values removed.
  static List<String> get groqModels => _groqModels
      .split(',')
      .map((model) => model.trim())
      .where((model) => model.isNotEmpty)
      .toList(growable: false);

  static bool get hasGroqApiKey => groqApiKey.isNotEmpty;
}
