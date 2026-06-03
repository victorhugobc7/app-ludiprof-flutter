import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:app_ludiprof/Models/roadmap.dart';
import 'package:app_ludiprof/Services/deck_repository.dart';
import 'package:app_ludiprof/Services/card_repository.dart';
import 'package:app_ludiprof/application/app_coordinator.dart';
import 'roadmap_view_model.dart';

/// Roadmap list and detail view for organized learning paths.
class RoadmapView extends StatefulWidget {
  const RoadmapView({super.key});

  @override
  State<RoadmapView> createState() => _RoadmapViewState();
}

class _RoadmapViewState extends State<RoadmapView> {
  late RoadmapViewModel _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _viewModel = RoadmapViewModel(
      deckRepo: context.read<DeckRepository>(),
      cardRepo: context.read<CardRepository>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deckRepo = context.watch<DeckRepository>();
    // Recreate VM when data changes
    _viewModel = RoadmapViewModel(
      deckRepo: deckRepo,
      cardRepo: context.read<CardRepository>(),
    );

    final roadmaps = _viewModel.roadmaps;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Roadmaps'),
      ),
      body: roadmaps.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🗺️', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhum roadmap criado.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ShadButton(
                    onPressed: () =>
                        AppCoordinator().goToRoadmapCreator(),
                    child: const Text('Criar Roadmap'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: roadmaps.length,
              itemBuilder: (context, index) {
                return _buildRoadmapCard(roadmaps[index]);
              },
            ),
      floatingActionButton: roadmaps.isNotEmpty
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF3F51B5),
              onPressed: () => AppCoordinator().goToRoadmapCreator(),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildRoadmapCard(Roadmap roadmap) {
    final decks = _viewModel.getDecksForRoadmap(roadmap);
    final progress = _viewModel.getRoadmapProgress(roadmap);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showRoadmapDetail(roadmap),
        child: ShadCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🗺️', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            roadmap.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (roadmap.description.isNotEmpty)
                            Text(
                              roadmap.description,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      '${decks.length} decks',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const Spacer(),
                    Text(
                      '${(progress * 100).round()}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    color: const Color(0xFF3F51B5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRoadmapDetail(Roadmap roadmap) {
    final decks = _viewModel.getDecksForRoadmap(roadmap);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(roadmap.name)),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: decks.length,
            itemBuilder: (context, index) {
              final deck = decks[index];
              final progress = _viewModel.getDeckProgress(deck);
              final isLast = index == decks.length - 1;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline indicator
                    SizedBox(
                      width: 40,
                      child: Column(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: progress >= 1.0
                                  ? const Color(0xFF4CAF50)
                                  : progress > 0
                                      ? const Color(0xFFFFC107)
                                      : Colors.grey[300],
                            ),
                            child: Center(
                              child: progress >= 1.0
                                  ? const Icon(Icons.check,
                                      size: 16, color: Colors.white)
                                  : Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: progress > 0
                                            ? Colors.white
                                            : Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                    ),
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: Colors.grey[300],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Deck card
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          onTap: () =>
                              AppCoordinator().goToFlashcards(deck.id),
                          child: ShadCard(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    deck.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${deck.cardIds.length} cards • ${(progress * 100).round()}% concluído',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(3),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 6,
                                      backgroundColor: Colors.grey[200],
                                      color: const Color(0xFF3F51B5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
