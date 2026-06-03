import 'package:flutter/foundation.dart';
import 'package:app_ludiprof/Models/gamification_models.dart';
import 'package:app_ludiprof/Services/storage_service.dart';

/// App-specific Gamification Service managing XP, levels, streaks, and badges.
class GamificationService extends ChangeNotifier {
  static const String _progressKey = 'user_progress';

  // Define our available badges
  static const List<GamificationBadge> availableBadges = [
    GamificationBadge(
      id: 'first_review',
      name: 'Primeiro Passo',
      description: 'Revisou seu primeiro card.',
      emoji: '🔰',
    ),
    GamificationBadge(
      id: 'first_creation',
      name: 'Criador',
      description: 'Criou seu primeiro card.',
      emoji: '✏️',
    ),
    GamificationBadge(
      id: 'task_master',
      name: 'Mão na Massa',
      description: 'Completou a primeira tarefa prática.',
      emoji: '🛠️',
    ),
    GamificationBadge(
      id: 'streak_3',
      name: 'No Ritmo',
      description: 'Alcançou 3 dias de ofensiva.',
      emoji: '🔥',
    ),
    GamificationBadge(
      id: 'streak_7',
      name: 'Semana Perfeita',
      description: 'Alcançou 7 dias de ofensiva.',
      emoji: '🌟',
    ),
    GamificationBadge(
      id: 'level_5',
      name: 'Especialista',
      description: 'Atingiu o Nível 5.',
      emoji: '🎓',
    ),
  ];

  UserProgress _progress = UserProgress();
  DateTime? _xpBuffEndTime;

  GamificationService() {
    _loadProgress();
  }

  void _loadProgress() {
    final raw = StorageService.gamificationBox.get(_progressKey);
    if (raw != null) {
      _progress = UserProgress.fromMap(Map<String, dynamic>.from(raw));
    } else {
      _progress = UserProgress();
    }
    _checkAndUpdateStreak();
  }

  Future<void> _saveProgress() async {
    await StorageService.gamificationBox.put(_progressKey, _progress.toMap());
    notifyListeners();
  }

  Future<UserProgress> getProgress() async {
    return _progress;
  }

  /// Ativa um multiplicador 3x de XP pelos próximos [minutes] minutos.
  void activateStudyBuff({int minutes = 10}) {
    _xpBuffEndTime = DateTime.now().add(Duration(minutes: minutes));
    notifyListeners();
  }

  bool get isBuffActive {
    if (_xpBuffEndTime == null) return false;
    return DateTime.now().isBefore(_xpBuffEndTime!);
  }

  void _checkAndUpdateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_progress.lastActiveDate == null) {
      return; // No activity yet
    }

    final lastActive = DateTime(
      _progress.lastActiveDate!.year,
      _progress.lastActiveDate!.month,
      _progress.lastActiveDate!.day,
    );

    final difference = today.difference(lastActive).inDays;

    if (difference == 1) {
      // Checked in next day, streak continues (but we don't increment until an action is performed)
    } else if (difference > 1) {
      // Streak broken, use shields if available
      int missedDays = difference - 1;
      int newShields = _progress.shields;
      int newStreak = _progress.streakDays;

      if (newShields >= missedDays) {
        newShields -= missedDays;
      } else {
        newStreak = 0;
        newShields = 0;
      }

      _progress = _progress.copyWith(
        streakDays: newStreak,
        shields: newShields,
      );
      _saveProgress();
    }
  }

  void _updateStreakOnAction() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_progress.lastActiveDate != null) {
      final lastActive = DateTime(
        _progress.lastActiveDate!.year,
        _progress.lastActiveDate!.month,
        _progress.lastActiveDate!.day,
      );

      final difference = today.difference(lastActive).inDays;

      if (difference == 1) {
        int newStreak = _progress.streakDays + 1;
        int longest = newStreak > _progress.longestStreak ? newStreak : _progress.longestStreak;
        
        // Grant a shield every 7 days
        int newShields = _progress.shields;
        if (newStreak % 7 == 0 && newShields < 3) {
          newShields++;
        }

        _progress = _progress.copyWith(
          streakDays: newStreak,
          longestStreak: longest,
          shields: newShields,
          lastActiveDate: now,
        );
      } else if (difference > 1) {
         // Should have been handled by _checkAndUpdateStreak, but just in case
        _progress = _progress.copyWith(
          streakDays: 1,
          longestStreak: _progress.longestStreak < 1 ? 1 : _progress.longestStreak,
          lastActiveDate: now,
        );
      } else {
        // Same day, just update last active time
        _progress = _progress.copyWith(lastActiveDate: now);
      }
    } else {
      // First action ever
      _progress = _progress.copyWith(
        streakDays: 1,
        longestStreak: 1,
        lastActiveDate: now,
      );
    }
  }

  Future<GamificationResult> _recordEvent(String eventType, int baseXp) async {
    _updateStreakOnAction();

    int xpAmount = baseXp;
    if (isBuffActive) {
      xpAmount *= 3;
    }

    int newTotalXp = _progress.totalXp + xpAmount;
    int newCurrentXp = _progress.currentXp + xpAmount;
    int newLevel = _progress.level;
    int newNextLevelXp = _progress.nextLevelXp;
    bool leveledUp = false;

    while (newCurrentXp >= newNextLevelXp) {
      newCurrentXp -= newNextLevelXp;
      newLevel++;
      newNextLevelXp = newLevel * 100;
      leveledUp = true;
    }

    final newEventCounts = Map<String, int>.from(_progress.eventCounts);
    newEventCounts[eventType] = (newEventCounts[eventType] ?? 0) + 1;

    _progress = _progress.copyWith(
      totalXp: newTotalXp,
      currentXp: newCurrentXp,
      level: newLevel,
      nextLevelXp: newNextLevelXp,
      eventCounts: newEventCounts,
    );

    final newBadges = _checkBadges();

    await _saveProgress();

    return GamificationResult(
      xpGained: xpAmount,
      leveledUp: leveledUp,
      hasNewBadges: newBadges.isNotEmpty,
      newBadges: newBadges,
      progress: _progress,
    );
  }

  List<GamificationBadge> _checkBadges() {
    List<GamificationBadge> newlyUnlocked = [];
    List<String> unlockedIds = List.from(_progress.unlockedBadges);

    for (var badge in availableBadges) {
      if (!unlockedIds.contains(badge.id)) {
        bool unlock = false;
        
        switch (badge.id) {
          case 'first_review':
            unlock = (_progress.eventCounts['card_reviewed'] ?? 0) > 0 || 
                     (_progress.eventCounts['card_correct'] ?? 0) > 0;
            break;
          case 'first_creation':
            unlock = (_progress.eventCounts['card_created'] ?? 0) > 0;
            break;
          case 'task_master':
            unlock = (_progress.eventCounts['task_completed'] ?? 0) > 0;
            break;
          case 'streak_3':
            unlock = _progress.streakDays >= 3;
            break;
          case 'streak_7':
            unlock = _progress.streakDays >= 7;
            break;
          case 'level_5':
            unlock = _progress.level >= 5;
            break;
        }

        if (unlock) {
          newlyUnlocked.add(badge);
          unlockedIds.add(badge.id);
        }
      }
    }

    if (newlyUnlocked.isNotEmpty) {
      _progress = _progress.copyWith(unlockedBadges: unlockedIds);
    }

    return newlyUnlocked;
  }

  // --- Public APIs matching previous interface ---

  Future<GamificationResult> recordCardReviewed({bool isCorrect = false}) async {
    return _recordEvent(isCorrect ? 'card_correct' : 'card_reviewed', isCorrect ? 15 : 10);
  }

  Future<GamificationResult> recordCardCreated() async {
    return _recordEvent('card_created', 20);
  }

  Future<GamificationResult> recordTaskCompleted() async {
    return _recordEvent('task_completed', 25);
  }

  Future<GamificationResult> recordDeckCompleted() async {
    return _recordEvent('deck_completed', 50);
  }

  Future<GamificationResult> recordSessionCompleted() async {
    return _recordEvent('session_completed', 30);
  }
}
