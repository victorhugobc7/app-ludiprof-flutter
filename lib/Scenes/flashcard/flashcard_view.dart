import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:fsrs/fsrs.dart' as fsrs;
import 'package:provider/provider.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';

import 'package:app_ludiprof/Design System/Components/Gamification/achievement_toast.dart';
import 'package:app_ludiprof/Design System/Components/Layout/lottie_progress_bar.dart';
import 'package:app_ludiprof/Design System/Shared/colors.dart';
import 'package:app_ludiprof/Design System/Shared/typography.dart';
import 'package:app_ludiprof/Services/deck_repository.dart';

import 'package:app_ludiprof/Models/card_type.dart';
import 'package:app_ludiprof/Models/flashcard_item.dart';
import 'package:app_ludiprof/Services/card_repository.dart';
import 'package:app_ludiprof/Services/analytics_service.dart';
import 'package:app_ludiprof/Services/gamification_service.dart';
import 'package:app_ludiprof/Models/gamification_models.dart';
import 'package:app_ludiprof/application/app_coordinator.dart';

import 'flashcard_view_model.dart';
import 'revision_finished_screen.dart';

/// The main flashcard study screen.
///
/// Displays cards one at a time with flip-to-reveal, FSRS rating buttons,
/// and practical-task completion support.
class FlashcardView extends StatefulWidget {
  final String deckId;

  const FlashcardView({super.key, required this.deckId});

  @override
  State<FlashcardView> createState() => _FlashcardViewState();
}

class _FlashcardViewState extends State<FlashcardView> {
  late final FlashcardViewModel _viewModel;
  final ScrollController _scrollController = ScrollController();

  bool _hasReachedBottom = false;
  int _lastIndex = -1;
  bool _isRating = false; // Prevent double-taps during async rating

  @override
  void initState() {
    super.initState();
    _viewModel = FlashcardViewModel(
      deckId: widget.deckId,
      cardRepo: context.read<CardRepository>(),
      analyticsService: context.read<AnalyticsService>(),
      gamificationService: context.read<GamificationService>(),
    );
    _viewModel.addListener(_onViewModelChanged);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      if (_scrollController.position.maxScrollExtent == 0 ||
          _scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.95) {
        if (!_hasReachedBottom) {
          setState(() {
            _hasReachedBottom = true;
          });
        }
      }
    }
  }

  void _onViewModelChanged() {
    if (!mounted) return;
    setState(() {});

    // Show achievement toasts when gamification events occur
    final result = _viewModel.lastResult;
    if (result != null && (result.leveledUp || result.hasNewBadges)) {
      AchievementToast.showResult(
        context,
        leveledUp: result.leveledUp,
        level: result.progress.level,
        newBadges: result.hasNewBadges,
        badges: result.newBadges,
      );
    }

    if (_viewModel.currentIndex != _lastIndex && !_viewModel.isFinished) {
      _lastIndex = _viewModel.currentIndex;
      _hasReachedBottom = false;
      _isRating = false;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollController.hasClients) {
          // Reset scroll position for new card
          _scrollController.jumpTo(0);
          if (_scrollController.position.maxScrollExtent == 0) {
            setState(() => _hasReachedBottom = true);
          }
        }
      });
    }

    // Unlock rating when finished
    if (_viewModel.isFinished) {
      _isRating = false;
    }
  }

  Future<void> _handleRating(fsrs.Rating rating) async {
    if (_isRating) return;
    setState(() => _isRating = true);

    // Haptic feedback
    HapticFeedback.mediumImpact();

    await _viewModel.rateCard(rating);
    // _isRating will be reset in _onViewModelChanged when the card advances
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    // End session if still active
    _viewModel.finishSession();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_viewModel.totalCards == 0) {
      return _buildEmptyScreen();
    }

    if (_viewModel.isFinished) {
      return _buildFinishedScreen();
    }

    return _buildStudyScreen();
  }

  // ─── Empty screen (no cards) ────────────────────────────────

  Widget _buildEmptyScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Nenhum card para revisar',
                style: AppTypography.heading2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Crie cards para comecar a estudar!',
                style: AppTypography.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () => AppCoordinator().goBack(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Voltar',
                    style: AppTypography.button,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Finished screen ────────────────────────────────────────

  Widget _buildFinishedScreen() {
    final progress = _viewModel.lastResult?.progress;
    return RevisionFinishedScreen(
      totalCards: _viewModel.totalCards,
      sessionXp: _viewModel.sessionXp,
      sessionBadges: _viewModel.sessionBadges,
      topicReviewCounts: _viewModel.topicReviewCounts,
      progress: progress ?? UserProgress(),
      onFinish: () => AppCoordinator().goToHome(),
      onRestart: _viewModel.reset,
    );
  }

  // ─── Active study screen ────────────────────────────────────

  Widget _buildStudyScreen() {
    final card = _viewModel.currentCard;
    final screenWidth = MediaQuery.of(context).size.width;
    final navBarWidth = screenWidth - 48;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              // Top safe area + progress bar + back button
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Column(
                    children: [
                      // Back button + title row
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              AppCoordinator().goBack();
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.textSecondary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                size: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Center(
                              child: Text(
                                'Revisão',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 36), // Balance the back button
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Progress bar
                      LottieProgressBar(
                        current: _viewModel.currentIndex,
                        total: _viewModel.totalCards,
                        height: 16,
                      ),
                    ],
                  ),
                ),
              ),

              // Card content area
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(
                    top: 24,
                    left: 24,
                    right: 24,
                    bottom: 140,
                  ),
                  child: _buildCardContent(card),
                ),
              ),
            ],
          ),

          // Rating bar fixed at bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildRatingBar(card, navBarWidth),
          ),
        ],
      ),
    );
  }

  // ─── Glass bottom rating bar ────────────────────────

  Widget _buildRatingBar(FlashcardItem card, double barWidth) {
    final bottomPadding = MediaQuery.of(context).padding.bottom + 16;
    Widget barContent;

    if (!_viewModel.isFlipped) {
      barContent = _buildSingleActionBar(
        label: 'Exibir resposta',
        icon: Icons.visibility,
        onTap: () {
          HapticFeedback.lightImpact();
          _viewModel.flipCard();
        },
      );
    } else {
      barContent = _buildRatingButtons();
    }

    return Container(
      margin: EdgeInsets.only(bottom: bottomPadding),
      width: barWidth,
      height: 64,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(50),
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
            child: Center(child: barContent),
          ),
        ),
      ),
    );
  }

  Widget _buildSingleActionBar({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _isRating ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFFE1F5FE),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.textPrimary, size: 16),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTypography.body.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ratingButton('Errei', const Color(0xFFE53935), fsrs.Rating.again),
          _ratingButton('Dificil', const Color(0xFFFF9800), fsrs.Rating.hard),
          _ratingButton('Bom', const Color(0xFF42A5F5), fsrs.Rating.good),
          _ratingButton('Facil', const Color(0xFF66BB6A), fsrs.Rating.easy),
        ],
      ),
    );
  }

  Widget _buildCardContent(FlashcardItem card) {
    return _buildStandardCard(card);
  }

  Widget _buildStandardCard(FlashcardItem card) {
    final deckRepo = context.read<DeckRepository>();
    final deckName = deckRepo.getDeck(_viewModel.deckId)?.name ?? 'Revisão';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          deckName.toUpperCase(),
          style: AppTypography.caption.copyWith(
            letterSpacing: 1.2,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          card.question,
          style: AppTypography.cardQuestion.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        if (_viewModel.isFlipped) ...[
          const SizedBox(height: 32),
          Text(
            card.answer,
            style: AppTypography.body.copyWith(
              height: 1.6,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
        ] else ...[
          const SizedBox(height: 48),
          Text(
            '...',
            style: AppTypography.heading1.copyWith(
              color: AppColors.textPrimary,
              fontSize: 32,
            ),
          ),
        ],
      ],
    );
  }

  // ─── Rating button ──────────────────────────────────────────

  Widget _ratingButton(String label, Color accentColor, fsrs.Rating rating) {
    return Expanded(
      child: GestureDetector(
        onTap: _isRating ? null : () => _handleRating(rating),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFE1F5FE), // light cyan background
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
