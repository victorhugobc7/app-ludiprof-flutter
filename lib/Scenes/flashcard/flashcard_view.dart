import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:fsrs/fsrs.dart' as fsrs;
import 'package:provider/provider.dart';
import 'package:app_ludiprof/Design System/Components/Gamification/achievement_toast.dart';
import 'package:app_ludiprof/Design System/Components/Buttons/glass_action_button.dart';
import 'package:app_ludiprof/Design System/Components/Layout/glass_bottom_bar.dart';

import 'package:app_ludiprof/Models/card_type.dart';
import 'package:app_ludiprof/Models/flashcard_item.dart';
import 'package:app_ludiprof/Services/card_repository.dart';
import 'package:app_ludiprof/Services/analytics_service.dart';
import 'package:app_ludiprof/Services/gamification_service.dart';
import 'package:app_ludiprof/application/app_coordinator.dart';
import 'package:app_ludiprof/Design System/Components/Inputs/custom_text_input.dart';

import 'flashcard_view_model.dart';

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
  final TextEditingController _taskController = TextEditingController();
  
  bool _hasReachedBottom = false;
  int _lastIndex = -1;

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
      _taskController.clear();
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollController.hasClients) {
          if (_scrollController.position.maxScrollExtent == 0) {
            setState(() => _hasReachedBottom = true);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _taskController.dispose();
    // End session if still active
    _viewModel.finishSession();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Flashcards')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_viewModel.isFinished) {
      return _buildFinishedScreen();
    }

    return _buildStudyScreen();
  }

  // ─── Finished screen ────────────────────────────────────────

  Widget _buildFinishedScreen() {
    return Scaffold(
      appBar: AppBar(title: const Text('Flashcards')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ShadCard(
            title: const Text(
              '🎉 Deck Concluído!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            description: const Text(
              'Parabéns! Você revisou todos os cards deste deck.',
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_viewModel.totalCards} cards revisados',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ShadButton(
                    onPressed: () => AppCoordinator().goToHome(),
                    size: ShadButtonSize.lg,
                    child: const Text('Voltar ao Início'),
                  ),
                  const SizedBox(height: 12),
                  ShadButton.outline(
                    onPressed: _viewModel.reset,
                    child: const Text('Revisar Novamente'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Active study screen ────────────────────────────────────

  Widget _buildStudyScreen() {
    final card = _viewModel.currentCard;
    final isConcept = card.cardType == CardType.conceito;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          isConcept ? 'Leitura' : 'Revisão',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => AppCoordinator().goBack(),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.only(
                top: 24.0,
                left: 24.0,
                right: 24.0,
                bottom: 140.0, // space for bottom bar
              ),
              child: _buildCardContent(card),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomButtons(card),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContent(FlashcardItem card) {
    switch (card.cardType) {
      case CardType.conceito:
        return _buildConceptCard(card);
      case CardType.cenarioProblema:
        return _buildScenarioCard(card);
      case CardType.acaoPratica:
        return _buildActionCard(card);
    }
  }

  Widget _buildConceptCard(FlashcardItem card) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          card.question,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          card.answer,
          style: const TextStyle(fontSize: 18, color: Colors.black87, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildScenarioCard(FlashcardItem card) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'UX/UI',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          card.question,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        if (_viewModel.isFlipped) ...[
          const SizedBox(height: 32),
          Text(
            card.answer,
            style: const TextStyle(fontSize: 18, color: Colors.black87, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildActionCard(FlashcardItem card) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Tarefa',
          style: TextStyle(
            fontSize: 12,
            color: Colors.green,
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          card.question,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        if (card.isTaskCompleted) ...[
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'Tarefa Concluída',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (card.answer.isNotEmpty)
            Text(
              card.answer,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
        ] else ...[
          CustomTextInput(
            controller: _taskController,
            placeholder: 'O que você fez nesta tarefa?',
            minLines: 4,
            maxLines: 8,
          ),
        ]
      ],
    );
  }

  Widget _buildBottomButtons(FlashcardItem card) {
    if (card.cardType == CardType.conceito) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: Center(
          child: GlassActionButton(
            label: 'Concluir',
            icon: Icons.check,
            onPressed: () {
              if (_hasReachedBottom) {
                _viewModel.rateCard(fsrs.Rating.good);
              } else {
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              }
            },
          ),
        ),
      );
    }
    
    if (card.cardType == CardType.acaoPratica && !card.isTaskCompleted) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: Center(
          child: GlassActionButton(
            label: 'Salvar e Concluir',
            icon: Icons.check,
            onPressed: () {
              _viewModel.markCurrentTaskCompleted(_taskController.text);
            },
          ),
        ),
      );
    }

    if (!_viewModel.isFlipped) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: Center(
          child: GlassActionButton(
            label: 'Exibir resposta',
            icon: Icons.visibility,
            onPressed: _viewModel.flipCard,
          ),
        ),
      );
    }

    return GlassBottomBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ratingButton('Errei', Colors.red.shade50, Colors.red.shade700, fsrs.Rating.again),
          _ratingButton('Difícil', Colors.orange.shade50, Colors.orange.shade700, fsrs.Rating.hard),
          _ratingButton('Bom', Colors.blue.shade50, Colors.blue.shade700, fsrs.Rating.good),
          _ratingButton('Fácil', Colors.green.shade50, Colors.green.shade700, fsrs.Rating.easy),
        ],
      ),
    );
  }

  Widget _ratingButton(String label, Color bgColor, Color textColor, fsrs.Rating rating) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: InkWell(
          onTap: () => _viewModel.rateCard(rating),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
