import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:app_ludiprof/Design System/Shared/colors.dart';
import 'package:app_ludiprof/Design System/Shared/typography.dart';
import 'package:app_ludiprof/Scenes/home/home_view_model.dart';
import 'package:app_ludiprof/Services/gamification_service.dart';
import 'package:app_ludiprof/Services/deck_repository.dart';
import 'package:app_ludiprof/Services/card_repository.dart';
import 'package:app_ludiprof/application/app_coordinator.dart';

/// Banner background image path — change this variable to swap the image.
const String kBannerBackgroundAsset = 'assets/images/banner_bg.png';

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
      deckRepo: context.read<DeckRepository>(),
      cardRepo: context.read<CardRepository>(),
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
    final progress = _viewModel.progress;
    final level = progress?.level ?? 1;
    final streakDays = progress?.streakDays ?? 0;
    final pendingCards = _viewModel.pendingCards;
    final decks = _viewModel.decksWithCounts;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Background Banner Image & Gradient ──
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  kBannerBackgroundAsset,
                  fit: BoxFit.cover,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Foreground Topics Card ──
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  // Spacer pushes the foreground down, leaving the top of the banner visible
                  const SizedBox(height: 240),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20, top: 24, bottom: 12),
                            child: Text(
                              'Revisar tópicos',
                              style: AppTypography.heading3,
                            ),
                          ),
                          Expanded(
                            child: decks.isEmpty
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(32),
                                      child: Text(
                                        'Nenhum deck ainda.\nCrie um para comecar!',
                                        textAlign: TextAlign.center,
                                        style: AppTypography.bodySmall,
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    physics: const BouncingScrollPhysics(),
                                    padding: const EdgeInsets.only(top: 4, bottom: 8),
                                    itemCount: decks.length,
                                    separatorBuilder: (_, _) => const Divider(
                                      color: Color(0xFFBDBDBD),
                                      height: 1,
                                      indent: 16,
                                      endIndent: 16,
                                    ),
                                    itemBuilder: (context, index) {
                                      final item = decks[index];
                                      return _TopicTile(
                                        name: item.deck.name,
                                        count: item.cardCount,
                                        onTap: () =>
                                            AppCoordinator().goToFlashcards(item.deck.id),
                                      );
                                    },
                                  ),
                          ),
                          
                          // ── Glass "+" button pinned at bottom ──
                          Align(
                            alignment: Alignment.center,
                            child: _buildGlassAddButton(),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Banner Content (Anchored in visible area) ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).padding.top + 240,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                // General review — study all decks
                AppCoordinator().goToFlashcards("");
              },
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: _buildBannerText(level, streakDays, pendingCards),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────
  //  BANNER — full horizontal, background image, tappable
  // ───────────────────────────────────────────────────────────

  Widget _buildBannerText(int level, int streakDays, int pendingCards) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Top Left: App name (Extrabold)
        Positioned(
          top: 0,
          left: 0,
          child: Text(
            'Ludiprof',
            style: GoogleFonts.mulish(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),

        // Top Right: Level
        Positioned(
          top: 0,
          right: 0,
          child: Text(
            'Lvl $level',
            style: GoogleFonts.mulish(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.9),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),

        // Center: Revisar + Play Icon
        Align(
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Revisar',
                style: GoogleFonts.mulish(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.play_circle_fill,
                color: Colors.white,
                size: 36,
              ),
            ],
          ),
        ),

        // Bottom Left: Streak (Larger)
        Positioned(
          bottom: 0,
          left: 0,
          child: Text(
            '$streakDays dias seguidos',
            style: GoogleFonts.mulish(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),

        // Bottom Right: Pending Cards
        if (pendingCards > 0)
          Positioned(
            bottom: 0,
            right: 0,
            child: Text(
              '$pendingCards pendentes',
              textAlign: TextAlign.right,
              style: GoogleFonts.mulish(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGlassAddButton() {
    return GestureDetector(
      onTap: () {
        AppCoordinator().goToIntegratedFlow();
      },
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          size: 28,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  TOPIC TILE
// ─────────────────────────────────────────────────────────────

class _TopicTile extends StatelessWidget {
  final String name;
  final int count;
  final VoidCallback onTap;

  const _TopicTile({
    required this.name,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            // Name — takes up to ~60% of width, auto-sizes font
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // If text would overflow at size 24, shrink to 18
                  final textPainter = TextPainter(
                    text: TextSpan(
                      text: name,
                      style: GoogleFonts.mulish(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    maxLines: 1,
                    textDirection: TextDirection.ltr,
                  )..layout(maxWidth: constraints.maxWidth * 0.5);

                  final fitsAtLarge = !textPainter.didExceedMaxLines;

                  return Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.mulish(
                      fontSize: fitsAtLarge ? 24 : 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(width: 12),

            // Card count
            Text(
              '$count',
              style: GoogleFonts.mulish(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
