import 'package:flutter/foundation.dart';
import 'package:fsrs/fsrs.dart' as fsrs;
import 'package:app_ludiprof/Models/gamification_models.dart';

import 'package:app_ludiprof/Models/flashcard_item.dart';
import 'package:app_ludiprof/Services/card_repository.dart';
import 'package:app_ludiprof/Services/analytics_service.dart';
import 'package:app_ludiprof/Services/gamification_service.dart';

/// ViewModel for the flashcard study screen.
///
/// Manages the study session lifecycle: loading cards from a deck,
/// FSRS-based spaced repetition scheduling, analytics tracking,
/// and gamification event recording.
class FlashcardViewModel extends ChangeNotifier {
  final String deckId;
  final CardRepository _cardRepo;
  final AnalyticsService _analyticsService;
  final GamificationService _gamificationService;

  final fsrs.Scheduler _scheduler = fsrs.Scheduler();

  // ─── Private state ─────────────────────────────────────────
  List<FlashcardItem> _deck = [];
  int _currentIndex = 0;
  bool _isFlipped = false;
  bool _isLoading = true;
  final Map<String, fsrs.Card> _fsrsCards = {};

  /// The most recent gamification result, used to show achievement toasts.
  GamificationResult? lastResult;

  FlashcardViewModel({
    required this.deckId,
    required CardRepository cardRepo,
    required AnalyticsService analyticsService,
    required GamificationService gamificationService,
  })  : _cardRepo = cardRepo,
        _analyticsService = analyticsService,
        _gamificationService = gamificationService {
    _loadDeck();
  }

  // ─── Getters ───────────────────────────────────────────────

  FlashcardItem get currentCard => _deck[_currentIndex];
  bool get isFlipped => _isFlipped;
  bool get isFinished => _currentIndex >= _deck.length;
  bool get isLoading => _isLoading;
  String get progress => '${_currentIndex + 1}/${_deck.length}';
  int get currentIndex => _currentIndex;
  int get totalCards => _deck.length;

  // ─── Deck loading ──────────────────────────────────────────

  Future<void> _loadDeck() async {
    _deck = _cardRepo.getCardsByDeck(deckId);

    // Build fsrs.Card instances from persisted fsrsData
    for (final card in _deck) {
      if (card.fsrsData.isNotEmpty) {
        try {
          _fsrsCards[card.id] = fsrs.Card.fromMap(
            Map<String, dynamic>.from(card.fsrsData),
          );
        } catch (_) {
          _fsrsCards[card.id] = fsrs.Card(
            cardId: card.id.hashCode,
          );
        }
      } else {
        _fsrsCards[card.id] = fsrs.Card(
          cardId: card.id.hashCode,
        );
      }
    }

    _isLoading = false;

    // Start analytics session
    _analyticsService.startSession(deckId);

    notifyListeners();
  }

  // ─── Card interactions ─────────────────────────────────────

  /// Reveals the answer side of the current card.
  void flipCard() {
    _isFlipped = true;
    _analyticsService.recordClick();
    notifyListeners();
  }

  /// Rates the current card with an FSRS rating, schedules next review,
  /// persists data, records analytics & gamification, then advances.
  Future<void> rateCard(fsrs.Rating rating) async {
    final card = currentCard;
    final fsrsCard = _fsrsCards[card.id]!;

    // Schedule via FSRS
    final result = _scheduler.reviewCard(fsrsCard, rating);
    _fsrsCards[card.id] = result.card;

    // Persist FSRS data
    await _cardRepo.updateFsrsData(card.id, result.card.toMap());

    // Record analytics
    final isCorrect =
        rating == fsrs.Rating.good || rating == fsrs.Rating.easy;
    _analyticsService.recordReview(
      isCorrect: isCorrect,
      cardTypeKey: card.cardType.jsonKey,
    );

    // Record gamification
    lastResult = await _gamificationService.recordCardReviewed(
      isCorrect: isCorrect,
    );

    // Advance to next card
    _isFlipped = false;
    _currentIndex++;
    notifyListeners();
  }

  /// Marks the current practical-action card as completed.
  Future<void> markCurrentTaskCompleted([String userAnswer = '']) async {
    final card = currentCard;
    if (!card.isPracticalAction || card.isTaskCompleted) return;

    final updatedCard = card.copyWith(
      isTaskCompleted: true,
      answer: userAnswer,
    );

    // Update in local array so UI updates instantly
    _deck[_currentIndex] = updatedCard;

    await _cardRepo.updateCard(updatedCard);

    // Record gamification
    lastResult = await _gamificationService.recordTaskCompleted();

    // Record analytics
    _analyticsService.recordTaskCompleted();

    // Auto-rate as good to advance to next card via spaced repetition
    await rateCard(fsrs.Rating.good);
  }

  /// Resets the session to the beginning.
  void reset() {
    _currentIndex = 0;
    _isFlipped = false;
    lastResult = null;
    notifyListeners();
  }

  /// Ends the current study session, persists analytics,
  /// and optionally records deck completion.
  Future<void> finishSession() async {
    if (!_analyticsService.hasActiveSession) return;

    await _analyticsService.endSession();

    // If all cards were reviewed, record deck completion
    if (_currentIndex >= _deck.length && _deck.isNotEmpty) {
      lastResult = await _gamificationService.recordDeckCompleted();
    }
  }
}
