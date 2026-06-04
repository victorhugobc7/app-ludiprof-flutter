import 'package:flutter/material.dart';
import 'package:app_ludiprof/Services/analytics_service.dart';
import 'package:app_ludiprof/Services/card_repository.dart';
import 'package:app_ludiprof/Services/deck_repository.dart';
import 'package:app_ludiprof/Services/gamification_service.dart';

/// ViewModel for the simplified performance dashboard.
class DashboardViewModel extends ChangeNotifier {
  final AnalyticsService _analyticsService;
  final CardRepository _cardRepo;
  final DeckRepository _deckRepo;
  final GamificationService _gamificationService;

  DashboardViewModel({
    required AnalyticsService analyticsService,
    required CardRepository cardRepo,
    required DeckRepository deckRepo,
    required GamificationService gamificationService,
  })  : _analyticsService = analyticsService,
        _cardRepo = cardRepo,
        _deckRepo = deckRepo,
        _gamificationService = gamificationService;

  int get streak => _gamificationService.currentProgress.streakDays;
  
  int get totalCardsReviewed => _analyticsService.getTotalCardsReviewed();

  int get cardsMemorizados {
    int count = 0;
    for (final card in _cardRepo.getAllCards()) {
      final reps = card.fsrsData['reps'] as int? ?? 0;
      if (reps >= 2) {
        count++;
      }
    }
    return count;
  }

  String get topicoMaisFamiliar {
    final decks = _deckRepo.getAllDecks();
    if (decks.isEmpty) return 'Nenhum';
    
    String bestDeckName = 'Nenhum';
    double bestAverageReps = -1.0;
    
    for (final deck in decks) {
      final cards = _cardRepo.getCardsForDeck(deck.id);
      if (cards.isEmpty) continue;
      
      int totalReps = 0;
      for (final card in cards) {
         totalReps += (card.fsrsData['reps'] as int? ?? 0);
      }
      final avg = totalReps / cards.length;
      if (avg > bestAverageReps) {
        bestAverageReps = avg;
        bestDeckName = deck.title;
      }
    }
    
    return bestAverageReps > 0 ? bestDeckName : 'Nenhum';
  }

  int get quantTopicosDominados {
    final decks = _deckRepo.getAllDecks();
    int dominados = 0;
    
    for (final deck in decks) {
      final cards = _cardRepo.getCardsForDeck(deck.id);
      if (cards.isEmpty) continue;
      
      bool isDominated = true;
      bool hasReviewedCard = false;
      
      for (final card in cards) {
        final reps = card.fsrsData['reps'] as int? ?? 0;
        final lapses = card.fsrsData['lapses'] as int? ?? 0;
        
        if (reps > 0) {
           hasReviewedCard = true;
        }
        
        // If any card hasn't reached 5 reps or has lapses, it's not dominated
        if (reps < 5 || lapses > 0) {
          isDominated = false;
          break;
        }
      }
      
      if (hasReviewedCard && isDominated) {
        dominados++;
      }
    }
    
    return dominados;
  }

  List<MapEntry<DateTime, int>> getDailyCardsReviewed({int days = 7}) {
    final sessions = _analyticsService.getSessionHistory(days: days);
    final Map<DateTime, int> daily = {};

    final now = DateTime.now();
    for (int i = days - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      daily[date] = 0;
    }

    for (final session in sessions) {
      final dateKey = DateTime(
        session.sessionDate.year,
        session.sessionDate.month,
        session.sessionDate.day,
      );
      if (daily.containsKey(dateKey)) {
        daily[dateKey] = daily[dateKey]! + session.cardsReviewed;
      }
    }

    final entries = daily.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries;
  }

  double get mediaDiariaCards {
    final data = getDailyCardsReviewed(days: 7);
    int activeDays = 0;
    int total = 0;
    for (var entry in data) {
      if (entry.value > 0) {
         activeDays++;
         total += entry.value;
      }
    }
    return activeDays > 0 ? total / activeDays : 0.0;
  }
}
