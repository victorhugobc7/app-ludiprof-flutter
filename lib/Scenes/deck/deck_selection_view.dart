import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:provider/provider.dart';

import 'package:app_ludiprof/Models/card_type.dart';
import 'package:app_ludiprof/Models/flashcard_item.dart';
import 'package:app_ludiprof/Services/card_repository.dart';
import 'package:app_ludiprof/Services/deck_repository.dart';
import 'package:app_ludiprof/Design System/Components/card_type_badge.dart';
import 'package:app_ludiprof/application/app_coordinator.dart';

/// Deck selection / browser screen.
///
/// Lists all available decks with card counts and type breakdowns.
/// Tapping a deck navigates to the flashcard study screen.
class DeckSelectionView extends StatelessWidget {
  const DeckSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final deckRepo = context.watch<DeckRepository>();
    final cardRepo = context.watch<CardRepository>();
    final decks = deckRepo.getAllDecks();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar Deck'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppCoordinator().goBack(),
        ),
      ),
      body: decks.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Nenhum deck encontrado',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Crie seu primeiro deck para começar!',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: decks.length,
              itemBuilder: (context, index) {
                final deck = decks[index];
                final cards = cardRepo.getCardsByDeck(deck.id);
                final typeCounts = _countByType(cards);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => AppCoordinator().goToFlashcards(deck.id),
                    borderRadius: BorderRadius.circular(12),
                    child: ShadCard(
                      title: Text(
                        deck.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      description: Text(
                        '${deck.cardIds.length} cards',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (typeCounts[CardType.conceito]! > 0)
                              _TypeCountChip(
                                cardType: CardType.conceito,
                                count: typeCounts[CardType.conceito]!,
                              ),
                            if (typeCounts[CardType.cenarioProblema]! > 0)
                              _TypeCountChip(
                                cardType: CardType.cenarioProblema,
                                count: typeCounts[CardType.cenarioProblema]!,
                              ),
                            if (typeCounts[CardType.acaoPratica]! > 0)
                              _TypeCountChip(
                                cardType: CardType.acaoPratica,
                                count: typeCounts[CardType.acaoPratica]!,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AppCoordinator().goToDeckCreator(),
        tooltip: 'Criar Deck',
        child: const Icon(Icons.add),
      ),
    );
  }

  Map<CardType, int> _countByType(List<FlashcardItem> cards) {
    final counts = {
      CardType.conceito: 0,
      CardType.cenarioProblema: 0,
      CardType.acaoPratica: 0,
    };
    for (final card in cards) {
      counts[card.cardType] = (counts[card.cardType] ?? 0) + 1;
    }
    return counts;
  }
}

class _TypeCountChip extends StatelessWidget {
  final CardType cardType;
  final int count;

  const _TypeCountChip({required this.cardType, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CardTypeBadge(cardType: cardType, compact: true),
        const SizedBox(width: 4),
        Text(
          '×$count',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
