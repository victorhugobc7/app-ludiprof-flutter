import 'dart:convert';

/// Represents a badge/achievement in the gamification system.
class GamificationBadge {
  final String id;
  final String name;
  final String description;
  final String emoji;

  const GamificationBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
  });
}

/// Represents the current gamification progress of the user.
class UserProgress {
  final int level;
  final int currentXp;
  final int nextLevelXp;
  final int totalXp;
  final int streakDays;
  final int longestStreak;
  final int shields;
  final DateTime? lastActiveDate;
  final Map<String, int> eventCounts;
  final List<String> unlockedBadges;

  UserProgress({
    this.level = 1,
    this.currentXp = 0,
    this.nextLevelXp = 100,
    this.totalXp = 0,
    this.streakDays = 0,
    this.longestStreak = 0,
    this.shields = 0,
    this.lastActiveDate,
    this.eventCounts = const {},
    this.unlockedBadges = const [],
  });

  UserProgress copyWith({
    int? level,
    int? currentXp,
    int? nextLevelXp,
    int? totalXp,
    int? streakDays,
    int? longestStreak,
    int? shields,
    DateTime? lastActiveDate,
    Map<String, int>? eventCounts,
    List<String>? unlockedBadges,
  }) {
    return UserProgress(
      level: level ?? this.level,
      currentXp: currentXp ?? this.currentXp,
      nextLevelXp: nextLevelXp ?? this.nextLevelXp,
      totalXp: totalXp ?? this.totalXp,
      streakDays: streakDays ?? this.streakDays,
      longestStreak: longestStreak ?? this.longestStreak,
      shields: shields ?? this.shields,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      eventCounts: eventCounts ?? this.eventCounts,
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'level': level,
      'currentXp': currentXp,
      'nextLevelXp': nextLevelXp,
      'totalXp': totalXp,
      'streakDays': streakDays,
      'longestStreak': longestStreak,
      'shields': shields,
      'lastActiveDate': lastActiveDate?.toIso8601String(),
      'eventCounts': eventCounts,
      'unlockedBadges': unlockedBadges,
    };
  }

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      level: map['level']?.toInt() ?? 1,
      currentXp: map['currentXp']?.toInt() ?? 0,
      nextLevelXp: map['nextLevelXp']?.toInt() ?? 100,
      totalXp: map['totalXp']?.toInt() ?? 0,
      streakDays: map['streakDays']?.toInt() ?? 0,
      longestStreak: map['longestStreak']?.toInt() ?? 0,
      shields: map['shields']?.toInt() ?? 0,
      lastActiveDate: map['lastActiveDate'] != null
          ? DateTime.parse(map['lastActiveDate'])
          : null,
      eventCounts: Map<String, int>.from(map['eventCounts'] ?? {}),
      unlockedBadges: List<String>.from(map['unlockedBadges'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProgress.fromJson(String source) =>
      UserProgress.fromMap(json.decode(source));
}

/// Represents the result of a gamification action (e.g., earning XP).
class GamificationResult {
  final int xpGained;
  final bool leveledUp;
  final bool hasNewBadges;
  final List<GamificationBadge> newBadges;
  final UserProgress progress;

  const GamificationResult({
    required this.xpGained,
    required this.leveledUp,
    required this.hasNewBadges,
    required this.newBadges,
    required this.progress,
  });
}
