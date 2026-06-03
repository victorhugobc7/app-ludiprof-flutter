import 'package:flutter/foundation.dart';
import 'package:app_ludiprof/Models/deck.dart';
import 'package:app_ludiprof/Models/flashcard_item.dart';
import 'package:app_ludiprof/Models/card_type.dart';
import 'package:app_ludiprof/Services/deck_repository.dart';
import 'package:app_ludiprof/Services/card_repository.dart';
import 'package:app_ludiprof/Services/gamification_service.dart';
import 'package:uuid/uuid.dart';

enum FlowStep { reading, deckName, createCards, createAction, summary }

class IntegratedFlowViewModel extends ChangeNotifier {
  final DeckRepository _deckRepo;
  final CardRepository _cardRepo;
  final GamificationService _gamificationService;

  FlowStep _currentStep = FlowStep.reading;
  FlowStep get currentStep => _currentStep;

  String readingText = '';
  String deckName = '';
  Deck? _createdDeck;
  Deck? get createdDeck => _createdDeck;

  final List<FlashcardItem> _createdCards = [];
  List<FlashcardItem> get createdCards => _createdCards;

  IntegratedFlowViewModel({
    required DeckRepository deckRepo,
    required CardRepository cardRepo,
    required GamificationService gamificationService,
  })  : _deckRepo = deckRepo,
        _cardRepo = cardRepo,
        _gamificationService = gamificationService;

  void advanceToDeckName(String text) {
    readingText = text;
    _currentStep = FlowStep.deckName;
    notifyListeners();
  }

  Future<void> advanceToCreateCards(String name) async {
    deckName = name;
    
    final newDeck = Deck(
      id: const Uuid().v4(),
      name: deckName,
      description: 'Gerado a partir da leitura.',
    );
    await _deckRepo.addDeck(newDeck);
    _createdDeck = newDeck;
    
    // Criar o card conceito com o texto lido
    final conceptCard = FlashcardItem(
      id: const Uuid().v4(),
      question: 'Leitura: $deckName',
      answer: readingText,
      cardType: CardType.conceito,
      deckId: newDeck.id,
    );
    await _cardRepo.addCard(conceptCard);
    _createdCards.add(conceptCard);

    _currentStep = FlowStep.createCards;
    notifyListeners();
  }

  Future<void> addCard(String question, String answer) async {
    if (_createdDeck == null) return;
    final card = FlashcardItem(
      id: const Uuid().v4(),
      question: question,
      answer: answer,
      cardType: CardType.cenarioProblema,
      deckId: _createdDeck!.id,
    );
    await _cardRepo.addCard(card);
    _createdCards.add(card);
    notifyListeners();
  }

  void advanceToCreateAction() {
    _currentStep = FlowStep.createAction;
    notifyListeners();
  }

  Future<void> addActionAndFinish(String actionQuestion) async {
    if (_createdDeck != null && actionQuestion.trim().isNotEmpty) {
      final card = FlashcardItem(
        id: const Uuid().v4(),
        question: actionQuestion,
        answer: '',
        cardType: CardType.acaoPratica,
        deckId: _createdDeck!.id,
      );
      await _cardRepo.addCard(card);
      _createdCards.add(card);
    }
    
    // Ativar o buff de XP de 3x por 10 minutos
    _gamificationService.activateStudyBuff(minutes: 10);
    
    _currentStep = FlowStep.summary;
    notifyListeners();
  }
}
