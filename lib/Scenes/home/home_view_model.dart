import 'package:flutter/foundation.dart';
import 'package:app_ludiprof/Models/gamification_models.dart';

import 'package:app_ludiprof/Models/user_profile.dart';
import 'package:app_ludiprof/Services/storage_service.dart';
import 'package:app_ludiprof/Services/gamification_service.dart';

/// ViewModel for the home / hub screen.
///
/// Aggregates user profile data, deck/card/session counts, and
/// gamification progress into a single reactive interface.
class HomeViewModel extends ChangeNotifier {
  final GamificationService? _gamificationService;

  // ── State ─────────────────────────────────────────────────
  UserProgress? _progress;

  HomeViewModel({GamificationService? gamificationService})
      : _gamificationService = gamificationService;

  // ── Public getters ────────────────────────────────────────

  UserProgress? get progress => _progress;

  /// Returns the current user profile, or `null` if not yet created.
  UserProfile? get user {
    final map = StorageService.userBox.get('current');
    if (map == null) return null;
    return UserProfile.fromMap(Map<dynamic, dynamic>.from(map));
  }

  /// Total number of decks stored locally.
  int get totalDecks => StorageService.decksBox.length;

  /// Total number of flashcards stored locally.
  int get totalCards => StorageService.cardsBox.length;

  /// Total number of study sessions recorded.
  int get totalSessions => StorageService.sessionsBox.length;

  // ── Gamification ──────────────────────────────────────────

  /// Refreshes the gamification progress from the service.
  Future<void> refreshProgress() async {
    if (_gamificationService != null) {
      _progress = await _gamificationService.getProgress();
    }
    notifyListeners();
  }
}
