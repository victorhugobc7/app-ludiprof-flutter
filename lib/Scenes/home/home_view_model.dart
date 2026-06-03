import 'package:flutter/foundation.dart';
import 'package:app_ludiprof/Models/gamification_models.dart';
import 'package:app_ludiprof/Models/deck.dart';

import 'package:app_ludiprof/Models/user_profile.dart';
import 'package:app_ludiprof/Services/storage_service.dart';
import 'package:app_ludiprof/Services/gamification_service.dart';
import 'package:app_ludiprof/Services/deck_repository.dart';
import 'package:app_ludiprof/Services/card_repository.dart';

/// ViewModel for the home / hub screen.
///
/// Aggregates user profile data, deck/card/session counts, and
/// gamification progress into a single reactive interface.
class HomeViewModel extends ChangeNotifier {
  final GamificationService? _gamificationService;
  final DeckRepository? _deckRepo;
  final CardRepository? _cardRepo;

  // ── State ─────────────────────────────────────────────────
  UserProgress? _progress;

  HomeViewModel({
    GamificationService? gamificationService,
    DeckRepository? deckRepo,
    CardRepository? cardRepo,
  })  : _gamificationService = gamificationService,
        _deckRepo = deckRepo,
        _cardRepo = cardRepo;

  // ── Public getters ────────────────────────────────────────

  UserProgress? get progress => _progress;

  /// Returns the current user profile, or `null` if not yet created.
  UserProfile? get user {
    final map = StorageService.userBox.get('current');
    if (map == null) return null;
    return UserProfile.fromMap(Map<dynamic, dynamic>.from(map));
  }

  /// Total number of decks stored locally.
  int get totalDecks => StorageService.decksBox.length;

  /// Total number of flashcards stored locally.
  int get totalCards => StorageService.cardsBox.length;

  /// Total number of study sessions recorded.
  int get totalSessions => StorageService.sessionsBox.length;

  /// Returns the number of cards pending for review.
  int get pendingCards {
    final allCards = _cardRepo?.getAllCards() ?? [];
    final now = DateTime.now();
    int count = 0;
    for (final card in allCards) {
      if (card.fsrsData.isEmpty) {
        count++;
      } else {
        final dueStr = card.fsrsData['due'];
        if (dueStr != null) {
          final dueDate = DateTime.parse(dueStr);
          if (dueDate.isBefore(now) || dueDate.isAtSameMomentAs(now)) {
            count++;
          }
        } else {
          count++;
        }
      }
    }
    return count;
  }

  /// Returns a list of decks with their card counts.
  List<DeckWithCount> get decksWithCounts {
    final decks = _deckRepo?.getAllDecks() ?? [];
    final allCards = _cardRepo?.getAllCards() ?? [];

    return decks.map((deck) {
      final count = allCards.where((c) => c.deckId == deck.id).length;
      return DeckWithCount(deck: deck, cardCount: count);
    }).toList();
  }

  // ── Gamification ──────────────────────────────────────────

  /// Refreshes the gamification progress from the service.
  Future<void> refreshProgress() async {
    if (_gamificationService != null) {
      _progress = await _gamificationService.getProgress();
    }
    notifyListeners();
  }
}

/// Helper class to pair a Deck with its flashcard count.
class DeckWithCount {
  final Deck deck;
  final int cardCount;

  const DeckWithCount({required this.deck, required this.cardCount});
}
