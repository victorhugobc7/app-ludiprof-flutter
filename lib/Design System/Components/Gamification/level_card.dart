import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:app_ludiprof/Models/gamification_models.dart';
import 'package:app_ludiprof/Design System/Shared/colors.dart';

class LevelCard extends StatelessWidget {
  final UserProgress progress;

  const LevelCard({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${progress.level}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nível Atual',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    _getTitleForLevel(progress.level),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'XP Total',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  '${progress.totalXp}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  String _getTitleForLevel(int level) {
    if (level < 5) return 'Iniciante';
    if (level < 10) return 'Aprendiz';
    if (level < 20) return 'Educador Dedicado';
    if (level < 30) return 'Especialista';
    if (level < 50) return 'Mestre';
    return 'Lenda da Educação';
  }
}
