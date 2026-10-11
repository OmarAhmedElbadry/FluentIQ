import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/domain/app_types.dart';
import '../domain/assessment_history_entry.dart';
import '../domain/assessment_history_repository.dart';
import '../domain/question_review_record.dart';

/// SharedPreferences implementation of the local assessment history store.
///
/// Entries are encoded as a single JSON list, which keeps the repository
/// interface independent from the underlying key-value storage mechanism.
class SharedPreferencesAssessmentHistoryRepository implements AssessmentHistoryRepository {
  SharedPreferencesAssessmentHistoryRepository(this._preferences);

  static const _storageKey = 'assessment_history_entries';
  final SharedPreferences _preferences;

  @override
  Future<void> save(AssessmentHistoryEntry entry) async {
    final entries = await getAll();
    entries.removeWhere((item) => item.id == entry.id);
    entries.add(entry);
    await _preferences.setString(_storageKey, jsonEncode(entries.map(_toMap).toList()));
  }

  @override
  Future<List<AssessmentHistoryEntry>> getAll() async {
    final raw = _preferences.getString(_storageKey);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      final entries = decoded
          .whereType<Map>()
          .map((value) => _fromMap(Map<String, dynamic>.from(value)))
          .toList()
        ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
      return entries;
    } on FormatException {
      return [];
    } on TypeError {
      return [];
    }
  }

  @override
  Future<AssessmentHistoryEntry?> getById(String id) async {
    final entries = await getAll();
    for (final entry in entries) {
      if (entry.id == id) return entry;
    }
    return null;
  }

  Map<String, Object> _toMap(AssessmentHistoryEntry entry) => {
        'id': entry.id,
        'assessmentId': entry.assessmentId,
        'assessmentTitle': entry.assessmentTitle,
        'language': entry.language.name,
        'level': entry.level.name,
        'scorePercent': entry.scorePercent,
        'totalQuestions': entry.totalQuestions,
        'skillBreakdown': entry.skillBreakdown.map((skill, score) => MapEntry(skill.name, score)),
        'completedAt': entry.completedAt.toIso8601String(),
        'questions': entry.questions.map(_reviewToMap).toList(),
      };

  AssessmentHistoryEntry _fromMap(Map<String, dynamic> map) {
    final rawBreakdown = Map<String, dynamic>.from(map['skillBreakdown'] as Map? ?? const {});
    return AssessmentHistoryEntry(
      id: map['id'] as String,
      assessmentId: map['assessmentId'] as String,
      assessmentTitle: map['assessmentTitle'] as String,
      language: AppLanguage.values.byName(map['language'] as String),
      level: CefrLevel.values.byName(map['level'] as String),
      scorePercent: map['scorePercent'] as int,
      totalQuestions: map['totalQuestions'] as int,
      skillBreakdown: rawBreakdown.map(
        (skill, score) => MapEntry(LanguageSkill.values.byName(skill), (score as num).toDouble()),
      ),
      completedAt: DateTime.parse(map['completedAt'] as String),
      questions: _decodeReviews(map['questions']),
    );
  }

  /// Entries saved before review capture existed have no key; malformed
  /// content degrades to an empty list rather than losing the whole entry.
  List<QuestionReviewRecord> _decodeReviews(Object? raw) {
    if (raw is! List) return const [];
    return raw.whereType<Map>().map((value) {
      final map = Map<String, dynamic>.from(value);
      final options = (map['options'] as List? ?? const []).whereType<String>().toList();
      return QuestionReviewRecord(
        prompt: map['prompt'] as String? ?? '',
        skill: LanguageSkill.values.byName(map['skill'] as String),
        options: options,
        selectedIndex: map['selectedIndex'] as int?,
        correctIndex: map['correctIndex'] as int?,
        responseText: map['responseText'] as String?,
        wasCorrect: map['wasCorrect'] as bool?,
        explanation: map['explanation'] as String?,
      );
    }).toList();
  }

  Map<String, Object> _reviewToMap(QuestionReviewRecord record) => {
        'prompt': record.prompt,
        'skill': record.skill.name,
        'options': record.options,
        'selectedIndex': ?record.selectedIndex,
        'correctIndex': ?record.correctIndex,
        'responseText': ?record.responseText,
        'wasCorrect': ?record.wasCorrect,
        'explanation': ?record.explanation,
      };
}
