import 'package:flutter/foundation.dart';
import 'package:app_ludiprof/Models/flashcard_item.dart';
import 'package:app_ludiprof/Services/storage_service.dart';
import 'package:app_ludiprof/Services/notification_service.dart';

/// Repository for flashcard CRUD operations backed by Hive.
class CardRepository extends ChangeNotifier {
  /// Returns all cards belonging to a given deck.
  List<FlashcardItem> getCardsByDeck(String deckId) {
    final allCards = StorageService.cardsBox.values
        .map((raw) => FlashcardItem.fromMap(Map<dynamic, dynamic>.from(raw as Map)))
        .toList();
    if (deckId.isEmpty) return allCards;
    return allCards.where((c) => c.deckId == deckId).toList();
  }

  /// Returns a single card by its ID, or null.
  FlashcardItem? getCard(String cardId) {
    final raw = StorageService.cardsBox.get(cardId);
    if (raw == null) return null;
    return FlashcardItem.fromMap(Map<dynamic, dynamic>.from(raw as Map));
  }

  /// Returns all cards in storage.
  List<FlashcardItem> getAllCards() {
    return StorageService.cardsBox.values
        .map((raw) => FlashcardItem.fromMap(Map<dynamic, dynamic>.from(raw as Map)))
        .toList();
  }

  /// Adds a new card to storage.
  Future<void> addCard(FlashcardItem card) async {
    await StorageService.cardsBox.put(card.id, card.toMap());
    notifyListeners();
  }

  /// Updates the FSRS scheduling data for a card.
  Future<void> updateFsrsData(String cardId, Map<String, dynamic> fsrsData) async {
    final raw = StorageService.cardsBox.get(cardId);
    if (raw == null) return;
    
    final updated = FlashcardItem.fromMap(Map<dynamic, dynamic>.from(raw as Map));
    updated.fsrsData = fsrsData;
    await StorageService.cardsBox.put(cardId, updated.toMap());
    
    // Update notifications schedule
    try {
      await NotificationService().scheduleNextReviewNotification(this);
    } catch (e) {
      debugPrint('Failed to schedule notification: $e');
    }
  }

  /// Updates the FSRS scheduling data for multiple cards in batch.
  Future<void> updateFsrsDataBatch(Map<String, Map<String, dynamic>> batchData) async {
    for (final entry in batchData.entries) {
      final cardId = entry.key;
      final fsrsData = entry.value;
      
      final raw = StorageService.cardsBox.get(cardId);
      if (raw != null) {
        final updated = FlashcardItem.fromMap(Map<dynamic, dynamic>.from(raw as Map));
        updated.fsrsData = fsrsData;
        await StorageService.cardsBox.put(cardId, updated.toMap());
      }
    }
    
    // Update notifications schedule ONCE
    try {
      await NotificationService().scheduleNextReviewNotification(this);
    } catch (e) {
      debugPrint('Failed to schedule notification: $e');
    }
  }

  /// Marks a practical-action card as task-completed.
  Future<void> markTaskCompleted(String cardId) async {
    final raw = StorageService.cardsBox.get(cardId);
    if (raw == null) return;
    final map = Map<String, dynamic>.from(raw as Map);
    map['isTaskCompleted'] = true;
    await StorageService.cardsBox.put(cardId, map);
    notifyListeners();
  }

  /// Updates an existing card entirely.
  Future<void> updateCard(FlashcardItem card) async {
    await StorageService.cardsBox.put(card.id, card.toMap());
    notifyListeners();
  }

  /// Deletes a card by ID.
  Future<void> deleteCard(String cardId) async {
    await StorageService.cardsBox.delete(cardId);
    notifyListeners();
  }
}
