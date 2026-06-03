import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:app_ludiprof/Design System/Shared/colors.dart';
import 'package:app_ludiprof/Design System/Shared/typography.dart';

/// Custom streak display showing current/longest streaks and shields.
///
/// Renders inside a [ShadCard] with fire emoji for the active streak,
/// a caption line for the personal best, and an optional shield row.
class StreakCounter extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final int shields;

  const StreakCounter({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
    this.shields = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Current streak ───────────────────────────────
          Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                '${currentStreak.toString()} dias',
                style: AppTypography.heading3.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // ── Longest streak ──────────────────────────────
          Text(
            'Melhor: $longestStreak dias',
            style: AppTypography.caption,
          ),

          // ── Shields (optional) ──────────────────────────
          if (shields > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('🛡️', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  '$shields escudo(s)',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primaryLight,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
