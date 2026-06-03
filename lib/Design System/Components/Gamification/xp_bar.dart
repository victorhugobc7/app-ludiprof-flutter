import 'package:flutter/material.dart';
import 'package:app_ludiprof/Models/gamification_models.dart';
import 'package:app_ludiprof/Design System/Shared/colors.dart';

class XpBar extends StatelessWidget {
  final UserProgress progress;
  final Color? color;

  const XpBar({
    super.key,
    required this.progress,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final barColor = color ?? AppColors.accent;
    final ratio = progress.currentXp / progress.nextLevelXp;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Nível ${progress.level}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              '${progress.currentXp} / ${progress.nextLevelXp} XP',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 12,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }
}
