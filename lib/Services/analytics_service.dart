import 'package:flutter/foundation.dart';
import 'package:app_ludiprof/Models/study_session.dart';
import 'package:app_ludiprof/Models/card_type.dart';
import 'package:app_ludiprof/Services/storage_service.dart';
import 'package:uuid/uuid.dart';

/// Lightweight analytics service that records study session metrics.
///
/// Each study session is built up incrementally (click, review, task)
/// and committed to Hive when [endSession] is called.
class AnalyticsService extends ChangeNotifier {
  final Uuid _uuid = const Uuid();

  // ─── In-flight session state ─────────────────────────────
  String? _currentSessionId;
  String? _currentDeckId;
  DateTime? _sessionStart;
  int _clicks = 0;
  int _correct = 0;
  int _incorrect = 0;
  int _tasksCompleted = 0;
  final Map<String, int> _typeBreakdown = {};

  /// Starts a new analytics session for the given [deckId].
  void startSession(String deckId) {
    _currentSessionId = _uuid.v4();
    _currentDeckId = deckId;
    _sessionStart = DateTime.now();
    _clicks = 0;
    _correct = 0;
    _incorrect = 0;
    _tasksCompleted = 0;
    _typeBreakdown.clear();
  }

  /// Records a click interaction (e.g. flipping a card).
  void recordClick() {
    _clicks++;
  }

  /// Records a card review result.
  void recordReview({required bool isCorrect, required String cardTypeKey}) {
    if (isCorrect) {
      _correct++;
    } else {
      _incorrect++;
    }
    _typeBreakdown[cardTypeKey] = (_typeBreakdown[cardTypeKey] ?? 0) + 1;
  }

  /// Records a practical task completion.
  void recordTaskCompleted() {
    _tasksCompleted++;
  }

  /// Ends the current session, persists it, and returns the StudySession.
  Future<StudySession?> endSession() async {
    if (_currentSessionId == null || _currentDeckId == null) return null;

    final totalTimeMs =
        DateTime.now().difference(_sessionStart!).inMilliseconds;
    final cardsReviewed = _correct + _incorrect;
    final avgTime = cardsReviewed > 0 ? totalTimeMs ~/ cardsReviewed : 0;

    final session = StudySession(
      id: _currentSessionId!,
      sessionDate: _sessionStart!,
      deckId: _currentDeckId!,
      cardsReviewed: cardsReviewed,
      correctCount: _correct,
      incorrectCount: _incorrect,
      totalTimeMs: totalTimeMs,
      avgTimePerCardMs: avgTime,
      totalClicks: _clicks,
      cardTypeBreakdown: Map<String, int>.from(_typeBreakdown),
      tasksCompleted: _tasksCompleted,
    );

    await StorageService.sessionsBox.put(session.id, session.toMap());

    // Reset in-flight state
    _currentSessionId = null;
    _currentDeckId = null;
    _sessionStart = null;

    notifyListeners();
    return session;
  }

  /// Whether a session is currently active.
  bool get hasActiveSession => _currentSessionId != null;

  /// Returns all past study sessions, optionally filtered to the last [days].
  List<StudySession> getSessionHistory({int? days}) {
    final allSessions = StorageService.sessionsBox.values
        .map((raw) =>
            StudySession.fromMap(Map<dynamic, dynamic>.from(raw as Map)))
        .toList();

    if (days == null) return allSessions;

    final cutoff = DateTime.now().subtract(Duration(days: days));
    return allSessions
        .where((s) => s.sessionDate.isAfter(cutoff))
        .toList();
  }

  /// Total cards reviewed across all sessions.
  int getTotalCardsReviewed() {
    return getSessionHistory().fold<int>(
      0,
      (sum, session) => sum + session.cardsReviewed,
    );
  }

  /// Total study time in milliseconds across all sessions.
  int getTotalStudyTimeMs() {
    return getSessionHistory().fold<int>(
      0,
      (sum, session) => sum + session.totalTimeMs,
    );
  }

  /// Accuracy breakdown by card type across all sessions.
  Map<CardType, double> getAccuracyByCardType() {
    final sessions = getSessionHistory();
    final Map<String, int> totalByType = {};
    final Map<String, int> correctByType = {};

    for (final session in sessions) {
      for (final entry in session.cardTypeBreakdown.entries) {
        totalByType[entry.key] = (totalByType[entry.key] ?? 0) + entry.value;
      }
      // Approximate correct distribution proportionally
      if (session.cardsReviewed > 0) {
        final accuracy = session.accuracyRate;
        for (final entry in session.cardTypeBreakdown.entries) {
          correctByType[entry.key] =
              (correctByType[entry.key] ?? 0) + (entry.value * accuracy).round();
        }
      }
    }

    final Map<CardType, double> result = {};
    for (final type in CardType.values) {
      final key = type.jsonKey;
      final total = totalByType[key] ?? 0;
      final correct = correctByType[key] ?? 0;
      result[type] = total > 0 ? correct / total : 0.0;
    }
    return result;
  }
}
