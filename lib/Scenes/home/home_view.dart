import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:provider/provider.dart';
import 'package:app_ludiprof/Design System/Components/Gamification/xp_bar.dart';
import 'package:app_ludiprof/Design System/Components/Gamification/streak_card.dart';

import 'package:app_ludiprof/Design System/Shared/colors.dart';
import 'package:app_ludiprof/Design System/Shared/typography.dart';
import 'package:app_ludiprof/Scenes/home/home_view_model.dart';
import 'package:app_ludiprof/Services/gamification_service.dart';
import 'package:app_ludiprof/application/app_coordinator.dart';

/// Main hub screen with gamification display and quick-action grid.
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel(
      gamificationService: context.read<GamificationService>(),
    );
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.refreshProgress();
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _viewModel.user;
    final displayName = user?.displayName ?? 'Professor(a)';
    final progress = _viewModel.progress;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LudiProf'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Greeting ─────────────────────────────────────
            Text(
              'Olá, $displayName!',
              style: AppTypography.heading2,
            ),
            const SizedBox(height: 8),

            // ── Gamification widgets ─────────────────────────
            if (progress != null) ...[
              StreakCard(progress: progress),
              const SizedBox(height: 12),
              XpBar(
                progress: progress,
                color: AppColors.accent,
              ),
            ],
            const SizedBox(height: 24),

            // ── Action prompt ────────────────────────────────
            Text('O que deseja fazer?', style: AppTypography.heading3),
            const SizedBox(height: 16),

            // ── 2×2 Action grid ──────────────────────────────
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _ActionCard(
                  emoji: '📚',
                  label: 'Estudar',
                  onTap: () => AppCoordinator().goToDeckSelection(),
                ),
                _ActionCard(
                  emoji: '📖',
                  label: 'Criar Deck (Leitura)',
                  onTap: () => AppCoordinator().goToIntegratedFlow(),
                ),
                _ActionCard(
                  emoji: '✏️',
                  label: 'Criar Card Rápido',
                  onTap: () => AppCoordinator().goToCardCreator(),
                ),
                _ActionCard(
                  emoji: '🗺️',
                  label: 'Roadmaps',
                  onTap: () => AppCoordinator().goToRoadmaps(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Summary stats ────────────────────────────────
            Center(
              child: Text(
                '${_viewModel.totalDecks} decks • '
                '${_viewModel.totalCards} cards • '
                '${_viewModel.totalSessions} sessões',
                style: AppTypography.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: ShadCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.heading3,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
