import 'package:flutter/foundation.dart';
import 'package:app_ludiprof/Models/deck.dart';
import 'package:app_ludiprof/Models/roadmap.dart';
import 'package:app_ludiprof/Services/storage_service.dart';

/// Repository for Deck and Roadmap CRUD operations backed by Hive.
class DeckRepository extends ChangeNotifier {
  // ─── Deck Operations ─────────────────────────────────────

  /// Returns all decks in storage.
  List<Deck> getAllDecks() {
    return StorageService.decksBox.values
        .map((raw) => Deck.fromMap(Map<dynamic, dynamic>.from(raw as Map)))
        .toList();
  }

  /// Returns a single deck by ID, or null.
  Deck? getDeck(String deckId) {
    final raw = StorageService.decksBox.get(deckId);
    if (raw == null) return null;
    return Deck.fromMap(Map<dynamic, dynamic>.from(raw as Map));
  }

  /// Adds a new deck.
  Future<void> addDeck(Deck deck) async {
    await StorageService.decksBox.put(deck.id, deck.toMap());
    notifyListeners();
  }

  /// Updates an existing deck (e.g. adding cardIds).
  Future<void> updateDeck(Deck deck) async {
    await StorageService.decksBox.put(deck.id, deck.toMap());
    notifyListeners();
  }

  /// Deletes a deck by ID.
  Future<void> deleteDeck(String deckId) async {
    await StorageService.decksBox.delete(deckId);
    notifyListeners();
  }

  // ─── Roadmap Operations ──────────────────────────────────

  /// Returns all roadmaps in storage.
  List<Roadmap> getAllRoadmaps() {
    return StorageService.roadmapsBox.values
        .map((raw) => Roadmap.fromMap(Map<dynamic, dynamic>.from(raw as Map)))
        .toList();
  }

  /// Adds a new roadmap.
  Future<void> addRoadmap(Roadmap roadmap) async {
    await StorageService.roadmapsBox.put(roadmap.id, roadmap.toMap());
    notifyListeners();
  }

  /// Updates an existing roadmap.
  Future<void> updateRoadmap(Roadmap roadmap) async {
    await StorageService.roadmapsBox.put(roadmap.id, roadmap.toMap());
    notifyListeners();
  }

  /// Deletes a roadmap by ID.
  Future<void> deleteRoadmap(String roadmapId) async {
    await StorageService.roadmapsBox.delete(roadmapId);
    notifyListeners();
  }
}
