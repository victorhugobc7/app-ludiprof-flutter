/// Anonymized study session data for analytics.
///
/// Records behavioral metrics only — no personal identifiers.
/// Captures time, clicks, and accuracy for the performance dashboard.
class StudySession {
  final String id;
  final DateTime sessionDate;
  final String deckId;
  final int cardsReviewed;
  final int correctCount; // Cards rated "Good" or "Easy"
  final int incorrectCount; // Cards rated "Again" or "Hard"
  final int totalTimeMs; // Total session duration in milliseconds
  final int avgTimePerCardMs;
  final int totalClicks;
  final Map<String, int> cardTypeBreakdown; // e.g. {'conceito': 5, 'cenario_problema': 3}
  final int tasksCompleted; // Practical tasks marked done

  StudySession({
    required this.id,
    required this.sessionDate,
    required this.deckId,
    this.cardsReviewed = 0,
    this.correctCount = 0,
    this.incorrectCount = 0,
    this.totalTimeMs = 0,
    this.avgTimePerCardMs = 0,
    this.totalClicks = 0,
    Map<String, int>? cardTypeBreakdown,
    this.tasksCompleted = 0,
  }) : cardTypeBreakdown = cardTypeBreakdown ?? {};

  /// Accuracy rate as a percentage (0.0 to 1.0).
  double get accuracyRate {
    final total = correctCount + incorrectCount;
    if (total == 0) return 0.0;
    return correctCount / total;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionDate': sessionDate.toIso8601String(),
      'deckId': deckId,
      'cardsReviewed': cardsReviewed,
      'correctCount': correctCount,
      'incorrectCount': incorrectCount,
      'totalTimeMs': totalTimeMs,
      'avgTimePerCardMs': avgTimePerCardMs,
      'totalClicks': totalClicks,
      'cardTypeBreakdown': cardTypeBreakdown,
      'tasksCompleted': tasksCompleted,
    };
  }

  factory StudySession.fromMap(Map<dynamic, dynamic> map) {
    return StudySession(
      id: map['id'] as String,
      sessionDate: DateTime.parse(map['sessionDate'] as String),
      deckId: map['deckId'] as String,
      cardsReviewed: map['cardsReviewed'] as int? ?? 0,
      correctCount: map['correctCount'] as int? ?? 0,
      incorrectCount: map['incorrectCount'] as int? ?? 0,
      totalTimeMs: map['totalTimeMs'] as int? ?? 0,
      avgTimePerCardMs: map['avgTimePerCardMs'] as int? ?? 0,
      totalClicks: map['totalClicks'] as int? ?? 0,
      cardTypeBreakdown:
          Map<String, int>.from(map['cardTypeBreakdown'] as Map? ?? {}),
      tasksCompleted: map['tasksCompleted'] as int? ?? 0,
    );
  }
}
