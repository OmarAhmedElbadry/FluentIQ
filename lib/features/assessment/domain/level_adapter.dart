import '../../../shared/domain/app_types.dart';

/// Nudges difficulty one CEFR band based on whether the last gradable
/// answer was correct. Deliberately simple — swap for a real adaptive
/// (e.g. IRT-based) algorithm later without touching any caller.
CefrLevel adjustLevel(CefrLevel current, {required bool wasCorrect}) {
  final values = CefrLevel.values;
  final index = values.indexOf(current);
  if (wasCorrect && index < values.length - 1) return values[index + 1];
  if (!wasCorrect && index > 0) return values[index - 1];
  return current;
}
