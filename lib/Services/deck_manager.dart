import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:uuid/uuid.dart';

import 'package:app_ludiprof/Models/card_type.dart';
import 'package:app_ludiprof/Models/deck.dart';
import 'package:app_ludiprof/Models/flashcard_item.dart';
import 'package:app_ludiprof/Services/card_repository.dart';
import 'package:app_ludiprof/Services/deck_repository.dart';
import 'package:app_ludiprof/Services/storage_service.dart';

/// Handles initial seed-data loading from `assets/deck.json`.
///
/// Singleton — use `DeckManager()` to obtain the shared instance.
class DeckManager {
  static final DeckManager _instance = DeckManager._internal();
  factory DeckManager() => _instance;
  DeckManager._internal();

  /// Loads seed data from the bundled JSON asset, creates [FlashcardItem]s
  /// and a [Deck], and persists them via the provided repositories.
  ///
  /// This is a no-op if data has already been seeded
  /// (checked via [StorageService.isSeeded]).
  Future<void> seedInitialData(
    CardRepository cardRepo,
    DeckRepository deckRepo,
  ) async {
    if (StorageService.isSeeded) return;

    final jsonString = await rootBundle.loadString('assets/deck.json');
    final List<dynamic> data = json.decode(jsonString) as List<dynamic>;

    const uuid = Uuid();
    final deckId = uuid.v4();
    final cardIds = <String>[];

    for (final item in data) {
      final map = item as Map<String, dynamic>;
      final cardId = uuid.v4();

      // Determine card type from JSON — defaults to 'conceito' if absent.
      final typeString = map['type'] as String? ?? 'conceito';
      final cardType = CardType.fromJson(typeString);

      final card = FlashcardItem(
        id: cardId,
        question: map['question'] as String,
        answer: map['answer'] as String,
        cardType: cardType,
        deckId: deckId,
        createdBy: 'system',
      );

      await cardRepo.addCard(card);
      cardIds.add(cardId);
    }

    final deck = Deck(
      id: deckId,
      name: 'Fundamentos Educacionais',
      description: 'Deck inicial com conceitos fundamentais de educação.',
      cardIds: cardIds,
      createdBy: 'system',
    );

    await deckRepo.addDeck(deck);
    await StorageService.markSeeded();
  }
}
