import 'package:flutter/material.dart';
import 'package:app_ludiprof/Models/gamification_models.dart';

class AchievementToast {
  static void showResult(
    BuildContext context, {
    required bool leveledUp,
    required int level,
    required bool newBadges,
    List<GamificationBadge>? badges,
  }) {
    if (leveledUp) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('🆙', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Subiu de Nível!', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Você alcançou o nível $level!'),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.blue.shade800,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }

    if (newBadges && badges != null && badges.isNotEmpty) {
      for (var badge in badges) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Text(badge.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nova Conquista!', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${badge.name}: ${badge.description}'),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange.shade800,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
