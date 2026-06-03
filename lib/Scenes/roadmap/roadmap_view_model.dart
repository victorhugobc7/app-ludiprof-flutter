import 'package:flutter/material.dart';
import 'package:app_ludiprof/Models/roadmap.dart';
import 'package:app_ludiprof/Models/deck.dart';
import 'package:app_ludiprof/Services/deck_repository.dart';
import 'package:app_ludiprof/Services/card_repository.dart';

/// ViewModel for roadmap listing and detail views.
class RoadmapViewModel extends ChangeNotifier {
  final DeckRepository _deckRepo;
  final CardRepository _cardRepo;

  RoadmapViewModel({
    required DeckRepository deckRepo,
    required CardRepository cardRepo,
  })  : _deckRepo = deckRepo,
        _cardRepo = cardRepo;

  List<Roadmap> get roadmaps => _deckRepo.getAllRoadmaps();

  /// Gets all decks belonging to a roadmap, in order.
  List<Deck> getDecksForRoadmap(Roadmap roadmap) {
    return roadmap.deckIds
        .map((id) => _deckRepo.getDeck(id))
        .where((d) => d != null)
        .cast<Deck>()
        .toList();
  }

  /// Progress for a specific deck (cards reviewed / total cards).
  double getDeckProgress(Deck deck) {
    if (deck.cardIds.isEmpty) return 0.0;
    final cards = deck.cardIds
        .map((id) => _cardRepo.getCard(id))
        .where((c) => c != null)
        .toList();
    if (cards.isEmpty) return 0.0;
    final reviewed = cards.where((c) => c!.fsrsData.isNotEmpty).length;
    return reviewed / cards.length;
  }

  /// Overall roadmap progress.
  double getRoadmapProgress(Roadmap roadmap) {
    final decks = getDecksForRoadmap(roadmap);
    if (decks.isEmpty) return 0.0;
    final totalProgress = decks.fold<double>(
      0.0,
      (sum, deck) => sum + getDeckProgress(deck),
    );
    return totalProgress / decks.length;
  }
}
