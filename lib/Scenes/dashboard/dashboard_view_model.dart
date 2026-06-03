import 'package:flutter/material.dart';
import 'package:app_ludiprof/Models/study_session.dart';
import 'package:app_ludiprof/Models/card_type.dart';
import 'package:app_ludiprof/Services/analytics_service.dart';

/// ViewModel for the performance dashboard.
///
/// Aggregates analytics data for charts and knowledge gap analysis.
class DashboardViewModel extends ChangeNotifier {
  final AnalyticsService _analyticsService;

  DashboardViewModel({
    required AnalyticsService analyticsService,
  })  : _analyticsService = analyticsService;

  /// Session history for charts.
  List<StudySession> getRecentSessions({int days = 30}) {
    return _analyticsService.getSessionHistory(days: days);
  }

  /// Total cards reviewed across all sessions.
  int get totalCardsReviewed => _analyticsService.getTotalCardsReviewed();

  /// Total study time in minutes.
  int get totalStudyTimeMinutes =>
      (_analyticsService.getTotalStudyTimeMs() / 60000).round();

  /// Overall accuracy rate (0.0 to 1.0).
  double get overallAccuracy {
    final sessions = _analyticsService.getSessionHistory();
    if (sessions.isEmpty) return 0.0;
    int totalCorrect = 0;
    int totalReviewed = 0;
    for (final session in sessions) {
      totalCorrect += session.correctCount;
      totalReviewed += session.cardsReviewed;
    }
    if (totalReviewed == 0) return 0.0;
    return totalCorrect / totalReviewed;
  }

  /// Accuracy breakdown by card type.
  Map<CardType, double> get accuracyByCardType =>
      _analyticsService.getAccuracyByCardType();

  /// Daily session counts for the last N days (for the activity chart).
  Map<DateTime, int> getDailyActivity({int days = 30}) {
    final sessions = _analyticsService.getSessionHistory(days: days);
    final Map<DateTime, int> daily = {};
    for (final session in sessions) {
      final dateKey = DateTime(
        session.sessionDate.year,
        session.sessionDate.month,
        session.sessionDate.day,
      );
      daily[dateKey] = (daily[dateKey] ?? 0) + 1;
    }
    return daily;
  }

  /// Daily cards reviewed for chart data.
  List<MapEntry<DateTime, int>> getDailyCardsReviewed({int days = 7}) {
    final sessions = _analyticsService.getSessionHistory(days: days);
    final Map<DateTime, int> daily = {};

    // Initialize all days with 0
    final now = DateTime.now();
    for (int i = days - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      daily[date] = 0;
    }

    for (final session in sessions) {
      final dateKey = DateTime(
        session.sessionDate.year,
        session.sessionDate.month,
        session.sessionDate.day,
      );
      if (daily.containsKey(dateKey)) {
        daily[dateKey] = daily[dateKey]! + session.cardsReviewed;
      }
    }

    final entries = daily.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries;
  }

  /// Total sessions count.
  int get totalSessions => _analyticsService.getSessionHistory().length;

  /// Average accuracy per session for trend.
  List<double> getAccuracyTrend({int lastN = 10}) {
    final sessions = _analyticsService.getSessionHistory();
    final recent = sessions.length > lastN
        ? sessions.sublist(sessions.length - lastN)
        : sessions;
    return recent.map((s) => s.accuracyRate).toList();
  }
}
