import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import 'package:app_ludiprof/Design System/Shared/colors.dart';
import 'package:app_ludiprof/Design System/Shared/typography.dart';
import 'package:app_ludiprof/Design System/Components/Layout/study_progress_bar.dart';
import 'package:app_ludiprof/Models/gamification_models.dart';
import 'package:app_ludiprof/Services/deck_repository.dart';


/// Data for each topic row in the breakdown.
class _TopicStat {
  final String name;
  final int count;
  final int total;

  const _TopicStat({
    required this.name,
    required this.count,
    required this.total,
  });

  double get fraction => total > 0 ? count / total : 0;
}

/// Full-screen animated results overlay shown after finishing a revision.
///
/// Phase 1 (initial): Checkmark centered + "Parabens! X cards revisados" + XP + "Continuar"
/// Phase 2 (after tap): Checkmark slides up, stats fade in from top in succession, button becomes "Finalizar"
class RevisionFinishedScreen extends StatefulWidget {
  final int totalCards;
  final int sessionXp;
  final List<GamificationBadge> sessionBadges;
  final Map<String, int> topicReviewCounts;
  final UserProgress progress;
  final VoidCallback onFinish;
  final VoidCallback onRestart;

  const RevisionFinishedScreen({
    super.key,
    required this.totalCards,
    required this.sessionXp,
    required this.sessionBadges,
    required this.topicReviewCounts,
    required this.progress,
    required this.onFinish,
    required this.onRestart,
  });

  @override
  State<RevisionFinishedScreen> createState() => _RevisionFinishedScreenState();
}

class _RevisionFinishedScreenState extends State<RevisionFinishedScreen>
    with TickerProviderStateMixin {
  bool _showStats = false;

  // Animation controllers for staggered fade-in
  late final AnimationController _checkController;
  late final Animation<Offset> _checkSlide;

  late final AnimationController _statsController;
  late final List<Animation<double>> _fadeAnimations;
  late final List<Animation<Offset>> _slideAnimations;

  // XP bar animation (separate delayed controller)
  late final AnimationController _xpController;
  late final Animation<double> _xpFill;

  // Build topic data
  late final List<_TopicStat> _topics;

  // How many animated rows: topics + divider + badges + xp
  int get _animatedItemCount {
    // topics + 1 divider + badges count + 1 xp section
    return _topics.length + 1 + widget.sessionBadges.length + 1;
  }

  @override
  void initState() {
    super.initState();

    _buildTopicData();

    // Checkmark slide-up animation
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _checkSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.3),
    ).animate(CurvedAnimation(
      parent: _checkController,
      curve: Curves.easeOutCubic,
    ));

    // Stats stagger animation
    final totalItems = _animatedItemCount;
    _statsController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300 + totalItems * 150),
    );

    _fadeAnimations = [];
    _slideAnimations = [];
    for (int i = 0; i < totalItems; i++) {
      final start = (i * 0.12).clamp(0.0, 0.8);
      final end = (start + 0.3).clamp(start + 0.1, 1.0);
      _fadeAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _statsController,
            curve: Interval(start, end, curve: Curves.easeOut),
          ),
        ),
      );
      _slideAnimations.add(
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _statsController,
            curve: Interval(start, end, curve: Curves.easeOutCubic),
          ),
        ),
      );
    }

    // XP bar fill animation (delayed)
    _xpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    final prevXp = (widget.progress.currentXp - widget.sessionXp)
        .clamp(0, widget.progress.nextLevelXp);
    final currentXp = widget.progress.currentXp;
    final nextLevelXp = widget.progress.nextLevelXp;
    _xpFill = Tween<double>(
      begin: prevXp / nextLevelXp,
      end: currentXp / nextLevelXp,
    ).animate(CurvedAnimation(
      parent: _xpController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _buildTopicData() {
    final deckRepo = context.read<DeckRepository>();
    _topics = [];

    for (final entry in widget.topicReviewCounts.entries) {
      final deckId = entry.key;
      final count = entry.value;
      final deck = deckRepo.getDeck(deckId);
      final name = deck?.name ?? deckId;
      _topics.add(_TopicStat(
        name: name,
        count: count,
        total: widget.totalCards,
      ));
    }

    // Sort by count descending
    _topics.sort((a, b) => b.count.compareTo(a.count));
  }

  void _onContinue() {
    HapticFeedback.lightImpact();
    setState(() => _showStats = true);

    // Slide checkmark up
    _checkController.forward();

    // Start stats stagger after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _statsController.forward();
    });

    // Start XP bar animation with extra delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _xpController.forward();
    });
  }

  @override
  void dispose() {
    _checkController.dispose();
    _statsController.dispose();
    _xpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Checkmark section (slides up when stats show)
              SlideTransition(
                position: _checkSlide,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Checkmark Lottie animation
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Lottie.asset(
                        'assets/lottie/checkmark_success.json',
                        repeat: false,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Parabens!',
                      style: AppTypography.heading1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.totalCards} cards revisados',
                      style: AppTypography.body,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${widget.sessionXp} xp',
                      style: AppTypography.heading3.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Stats section (only visible after "Continuar")
              if (_showStats) ...[
                const SizedBox(height: 16),
                Expanded(
                  flex: 3,
                  child: AnimatedBuilder(
                    animation: _statsController,
                    builder: (context, _) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: _buildStatsContent(),
                      );
                    },
                  ),
                ),
              ] else
                const Spacer(flex: 2),

              // Button
              Padding(
                padding: const EdgeInsets.only(bottom: 32, top: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: _showStats ? widget.onFinish : _onContinue,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.textSecondary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        _showStats ? 'Finalizar' : 'Continuar',
                        textAlign: TextAlign.center,
                        style: AppTypography.heading3,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsContent() {
    int animIdx = 0;
    final children = <Widget>[];

    // Topic breakdown rows
    for (final topic in _topics) {
      final idx = animIdx++;
      children.add(
        _animatedRow(
          idx,
          child: _buildTopicRow(topic),
        ),
      );
    }

    // Divider
    final dividerIdx = animIdx++;
    children.add(
      _animatedRow(
        dividerIdx,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Divider(
            color: const Color(0xFFBDBDBD).withValues(alpha: 0.5),
            height: 1,
          ),
        ),
      ),
    );

    // Badges
    if (widget.sessionBadges.isNotEmpty) {
      for (final badge in widget.sessionBadges) {
        final idx = animIdx++;
        children.add(
          _animatedRow(
            idx,
            child: _buildBadgeRow(badge),
          ),
        );
      }
    } else {
      // No badges earned — skip but still consume an animation slot
      animIdx++;
    }

    // XP bar
    final xpIdx = animIdx++;
    children.add(
      _animatedRow(
        xpIdx.clamp(0, _fadeAnimations.length - 1),
        child: _buildXpSection(),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _animatedRow(int index, {required Widget child}) {
    if (index >= _fadeAnimations.length) {
      return child;
    }
    return FadeTransition(
      opacity: _fadeAnimations[index],
      child: SlideTransition(
        position: _slideAnimations[index],
        child: child,
      ),
    );
  }

  Widget _buildTopicRow(_TopicStat topic) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              topic.name,
              style: AppTypography.body,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: StudyProgressBar(
              current: topic.count,
              total: topic.total,
              height: 8,
              fillColor: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 28,
            child: Text(
              '${topic.count}',
              style: AppTypography.heading3,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeRow(GamificationBadge badge) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nova medalha!',
            style: AppTypography.caption.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            badge.name,
            style: AppTypography.heading3,
          ),
        ],
      ),
    );
  }

  Widget _buildXpSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          Text(
            '${widget.sessionXp} xp',
            style: AppTypography.heading3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _xpFill,
            builder: (context, _) {
              return Container(
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(100),
                ),
                clipBehavior: Clip.antiAlias,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final fillWidth = constraints.maxWidth * _xpFill.value.clamp(0.0, 1.0);
                    final prevWidth = constraints.maxWidth *
                        ((widget.progress.currentXp - widget.sessionXp)
                                .clamp(0, widget.progress.nextLevelXp) /
                            widget.progress.nextLevelXp)
                            .clamp(0.0, 1.0);
                    return Stack(
                      children: [
                        // Full fill (previous + new)
                        Container(
                          width: fillWidth,
                          height: 12,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.error.withValues(alpha: 0.7),
                                AppColors.error,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        // New XP portion highlighted in green
                        if (fillWidth > prevWidth)
                          Positioned(
                            left: prevWidth,
                            child: Container(
                              width: (fillWidth - prevWidth).clamp(0, constraints.maxWidth - prevWidth),
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
