import 'dart:async';

import 'package:fluentiq/features/questions/domain/question_generation_exception.dart';
import 'package:fluentiq/features/questions/domain/question_generator.dart';
import 'package:fluentiq/features/results/domain/assessment_history_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/domain/app_types.dart';
import '../../questions/domain/question.dart';
import '../../results/domain/assessment_history_entry.dart';
import '../../results/domain/question_review_record.dart';
import '../../settings/domain/preferences_repository.dart';
import '../domain/assessment_repository.dart';
import '../domain/assessment_result.dart';
import '../domain/level_adapter.dart';
import '../domain/question_plan.dart';
import 'assessment_run_state.dart';

/// Orchestrates a full assessment run: builds the question plan, calls
/// [QuestionGenerator] for each step, adapts difficulty, enforces a
/// wall-clock time limit, gates advancement on [Question.accepts],
/// grades gradable answers, produces a final [AssessmentResult], and
/// persists it — including per-question review data — to
/// [AssessmentHistoryRepository] so the results screen and home
/// dashboard both see it immediately.
///
/// All AI/network concerns live behind [QuestionGenerator] — this class
/// only sequences calls and tracks session state. No widget in this
/// feature knows Groq exists, and no widget decides whether an answer
/// is valid — that rule lives in [Question.accepts].
class AssessmentRunCubit extends Cubit<AssessmentRunState> {
  AssessmentRunCubit(this._assessments, this._generator, this._history, this._preferences)
      : super(const AssessmentRunLoading());

  final AssessmentRepository _assessments;
  final QuestionGenerator _generator;
  final AssessmentHistoryRepository _history;
  final PreferencesRepository _preferences;

  /// Client-side safety net on top of prompt-level redundancy avoidance:
  /// if the model echoes a prior question's title despite being told not
  /// to, retry a few times before accepting the last attempt.
  static const _maxRegenerationAttempts = 3;
  static const _tickInterval = Duration(seconds: 1);

  List<QuestionSpec> _plan = const [];
  AppLanguage _language = AppLanguage.english;
  CefrLevel _level = CefrLevel.b1;
  String? _lastAssessmentId;
  String _assessmentTitle = '';
  Duration _remaining = Duration.zero;
  Timer? _ticker;

  /// Guards against a stale async result (a generation call or a timer
  /// tick that was already in flight) re-emitting after the run has
  /// already been finalized — by reaching the last question or by the
  /// clock running out, whichever happens first.
  bool _finished = false;

  /// The answer captured so far for the *current* question, updated on
  /// every [updateAnswer] call as the learner interacts with it, and
  /// consumed (then cleared) by [submitCurrentAnswer].
  dynamic _draftAnswer;

  final List<Question> _askedQuestions = [];
  final List<dynamic> _answers = [];
  int _index = 0;

  Future<void> start({required String assessmentId, CefrLevel startingLevel = CefrLevel.b1}) async {
    _ticker?.cancel();
    _lastAssessmentId = assessmentId;
    _plan = const [];
    _language = AppLanguage.english;
    _level = startingLevel;
    _assessmentTitle = '';
    _remaining = Duration.zero;
    _finished = false;
    _draftAnswer = null;
    _askedQuestions.clear();
    _answers.clear();
    _index = 0;
    emit(const AssessmentRunLoading());
    try {
      // Same preference the catalogue used to list this assessment in
      // the first place — resolving it independently here (rather than
      // trusting a stale value passed in) keeps this the single place
      // that decides what language an actual run is conducted in.
      final preferences = await _preferences.load();
      final available = await _assessments.getAvailable(language: preferences.assessmentLanguage);
      final assessment = available.firstWhere(
        (a) => a.id == assessmentId,
        orElse: () => throw QuestionGenerationException('Unknown assessment "$assessmentId".'),
      );
      _plan = buildQuestionPlan(assessment.skills);
      _language = assessment.language;
      _assessmentTitle = assessment.title;
      _remaining = assessment.timeLimit;
      if (_remaining <= Duration.zero) {
        // A misconfigured zero/negative time limit shouldn't hang the
        // run — finalize immediately over whatever's been answered
        // (nothing, in this case) rather than start a doomed ticker.
        await _finish();
        return;
      }
      _startTimer();
      await _loadCurrentQuestion();
    } catch (e) {
      emit(AssessmentRunError(_describeError(e)));
    }
  }

  /// Restarts the same assessment from the last known level — used by
  /// the error view's retry button.
  Future<void> retry() async {
    final id = _lastAssessmentId;
    if (id != null) await start(assessmentId: id, startingLevel: _level);
  }

  void _startTimer() {
    _ticker?.cancel();
    _ticker = Timer.periodic(_tickInterval, (_) => _tick());
  }

  void _tick() {
    if (_finished) {
      _ticker?.cancel();
      return;
    }
    _remaining -= _tickInterval;
    if (_remaining <= Duration.zero) {
      _remaining = Duration.zero;
      _ticker?.cancel();
      unawaited(_finish());
      return;
    }
    // The clock runs continuously, including while the next question is
    // still generating — only re-emit when there's an in-progress
    // question on screen to update; a Loading/Error state has nothing
    // showing the timer, so there's nothing to refresh.
    final current = state;
    if (current is AssessmentRunInProgress) {
      emit(
        AssessmentRunInProgress(
          question: current.question,
          index: current.index,
          total: current.total,
          level: current.level,
          hasAnswer: current.hasAnswer,
          remaining: _remaining,
        ),
      );
    }
  }

  Future<void> _loadCurrentQuestion() async {
    final spec = _plan[_index];
    final question = await _generateUnique(spec);
    if (_finished) return; // the clock ran out while this was generating
    _askedQuestions.add(question);
    _draftAnswer = null;
    emit(
      AssessmentRunInProgress(
        question: question,
        index: _index,
        total: _plan.length,
        level: _level,
        hasAnswer: false,
        remaining: _remaining,
      ),
    );
  }

  Future<Question> _generateUnique(QuestionSpec spec) async {
    Question question;
    var attempt = 0;
    do {
      question = await _generator.generateNext(
        language: _language,
        level: _level,
        skill: spec.skill,
        type: spec.type,
        previousPrompts: _askedQuestions.map((q) => q.title).toList(),
      );
      attempt++;
    } while (_isDuplicate(question) && attempt < _maxRegenerationAttempts);
    return question;
  }

  bool _isDuplicate(Question candidate) => _askedQuestions.any(
        (asked) => asked.title.trim().toLowerCase() == candidate.title.trim().toLowerCase(),
      );

  /// Tracks the answer as the learner interacts with the current
  /// question and re-emits so the view can reactively enable or disable
  /// its continue control — the validity rule itself is
  /// [Question.accepts], never duplicated here.
  void updateAnswer(dynamic answer) {
    _draftAnswer = answer;
    final current = state;
    if (current is AssessmentRunInProgress) {
      emit(
        AssessmentRunInProgress(
          question: current.question,
          index: current.index,
          total: current.total,
          level: current.level,
          hasAnswer: current.question.accepts(answer),
          remaining: current.remaining,
        ),
      );
    }
  }

  /// Submits the tracked draft answer and advances — or finalizes if
  /// this was the last question. A no-op unless the current state
  /// already reports [AssessmentRunInProgress.hasAnswer]; the view
  /// disables its control on the same condition, this is the
  /// domain-side guarantee behind that.
  Future<void> submitCurrentAnswer() async {
    final current = state;
    if (current is! AssessmentRunInProgress || !current.hasAnswer) return;
    _recordAnswer(_draftAnswer);
    _draftAnswer = null;
    if (_index >= _plan.length - 1) {
      await _finish();
      return;
    }
    _index++;
    emit(const AssessmentRunLoading());
    try {
      await _loadCurrentQuestion();
    } catch (e) {
      if (!_finished) emit(AssessmentRunError(_describeError(e)));
    }
  }

  /// Records the answer for the current question and, if it was
  /// auto-gradable, nudges difficulty for the next one.
  void _recordAnswer(dynamic answer) {
    _answers.add(answer);
    final question = _askedQuestions[_index];
    if (question.type.isAutoGradable && question.correctAnswerIndex != null) {
      final wasCorrect = answer is int && answer == question.correctAnswerIndex;
      _level = adjustLevel(_level, wasCorrect: wasCorrect);
    }
  }

  Future<void> _finish() async {
    if (_finished) return;
    _finished = true;
    _ticker?.cancel();
    final result = _buildResult();
    await _saveToHistory(result);
    emit(AssessmentRunCompleted(result));
  }

  /// Best-effort: a failed history write shouldn't block the user from
  /// seeing the result they just earned.
  Future<void> _saveToHistory(AssessmentResult result) async {
    try {
      await _history.save(
        AssessmentHistoryEntry(
          id: '${_lastAssessmentId}_${DateTime.now().microsecondsSinceEpoch}',
          assessmentId: _lastAssessmentId ?? '',
          assessmentTitle: _assessmentTitle,
          language: _language,
          level: _level,
          scorePercent: result.scorePercent,
          totalQuestions: result.totalQuestions,
          skillBreakdown: result.skillBreakdown,
          completedAt: DateTime.now(),
          questions: _buildReviewRecords(),
        ),
      );
    } catch (_) {
      // Swallow: history is a nice-to-have record of a result the user
      // has already seen, not a precondition for seeing it.
    }
  }

  List<QuestionReviewRecord> _buildReviewRecords() => [
        for (var i = 0; i < _askedQuestions.length; i++)
          _toReviewRecord(_askedQuestions[i], i < _answers.length ? _answers[i] : null),
      ];

  QuestionReviewRecord _toReviewRecord(Question question, dynamic answer) {
    final isGradable = question.type.isAutoGradable && question.correctAnswerIndex != null;
    return QuestionReviewRecord(
      prompt: question.description.isEmpty ? question.title : '${question.title}\n${question.description}',
      skill: question.skill,
      options: question.options,
      selectedIndex: answer is int ? answer : null,
      correctIndex: question.correctAnswerIndex,
      responseText: answer is String ? answer : null,
      wasCorrect: isGradable ? (answer is int && answer == question.correctAnswerIndex) : null,
      explanation: question.explanation,
    );
  }

  AssessmentResult _buildResult() {
    var correct = 0;
    var gradable = 0;
    final bySkillCorrect = <LanguageSkill, int>{};
    final bySkillTotal = <LanguageSkill, int>{};

    for (var i = 0; i < _askedQuestions.length; i++) {
      final question = _askedQuestions[i];
      final answer = i < _answers.length ? _answers[i] : null;
      bySkillTotal[question.skill] = (bySkillTotal[question.skill] ?? 0) + 1;
      if (question.type.isAutoGradable && question.correctAnswerIndex != null) {
        gradable++;
        if (answer is int && answer == question.correctAnswerIndex) {
          correct++;
          bySkillCorrect[question.skill] = (bySkillCorrect[question.skill] ?? 0) + 1;
        }
      }
    }

    final breakdown = <LanguageSkill, double>{
      for (final skill in bySkillTotal.keys)
        skill: bySkillTotal[skill] == 0 ? 0 : (bySkillCorrect[skill] ?? 0) / bySkillTotal[skill]!,
    };

    return AssessmentResult(
      totalQuestions: _askedQuestions.length,
      correctCount: correct,
      scorePercent: gradable == 0 ? 0 : ((correct / gradable) * 100).round(),
      skillBreakdown: breakdown,
    );
  }

  String _describeError(Object e) => e is QuestionGenerationException
      ? e.message
      : 'Something went wrong generating your assessment. Please try again.';

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
