import 'package:flutter/foundation.dart';

import 'package:app_ludiprof/Models/card_type.dart';
import 'package:app_ludiprof/Models/flashcard_item.dart';
import 'package:app_ludiprof/Services/card_repository.dart';
import 'package:app_ludiprof/Services/deck_repository.dart';
import 'package:app_ludiprof/Services/gamification_service.dart';
import 'package:uuid/uuid.dart';

/// Simple ViewModel for the card creator form.
class CardCreatorViewModel extends ChangeNotifier {
  final Uuid _uuid = const Uuid();

  CardType _selectedType = CardType.conceito;
  String? _selectedDeckId;

  CardType get selectedType => _selectedType;
  String? get selectedDeckId => _selectedDeckId;

  void setType(CardType type) {
    _selectedType = type;
    notifyListeners();
  }

  void setDeck(String deckId) {
    _selectedDeckId = deckId;
    notifyListeners();
  }

  bool canSave(String question, String answer) {
    if (selectedDeckId == null || question.trim().isEmpty) {
      return false;
    }
    
    // For practical action cards, answer is optional
    if (_selectedType == CardType.acaoPratica) {
      return true;
    }
    
    return answer.trim().isNotEmpty;
  }

  /// Creates and persists a new FlashcardItem, adds it to the selected
  /// deck, and records a gamification event.
  Future<void> saveCard({
    required String question,
    required String answer,
    required CardRepository cardRepo,
    required DeckRepository deckRepo,
    required GamificationService gamificationService,
  }) async {
    final cardId = _uuid.v4();

    final card = FlashcardItem(
      id: cardId,
      question: question.trim(),
      answer: answer.trim(),
      cardType: _selectedType,
      deckId: _selectedDeckId!,
      createdBy: 'user',
    );

    // Persist card
    await cardRepo.addCard(card);

    // Add card ID to the deck's cardIds
    final deck = deckRepo.getDeck(_selectedDeckId!);
    if (deck != null) {
      final updatedDeck = deck.copyWith(
        cardIds: [...deck.cardIds, cardId],
      );
      await deckRepo.updateDeck(updatedDeck);
    }

    // Record gamification event
    await gamificationService.recordCardCreated();
  }
}
