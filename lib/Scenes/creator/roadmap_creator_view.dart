import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:app_ludiprof/Models/deck.dart';
import 'package:app_ludiprof/Models/roadmap.dart';
import 'package:app_ludiprof/Services/deck_repository.dart';

/// Roadmap creation form screen.
///
/// Allows users to create an ordered learning path from existing decks.
/// Decks can be checked/unchecked and reordered via drag handles.
class RoadmapCreatorView extends StatefulWidget {
  const RoadmapCreatorView({super.key});

  @override
  State<RoadmapCreatorView> createState() => _RoadmapCreatorViewState();
}

class _RoadmapCreatorViewState extends State<RoadmapCreatorView> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _uuid = const Uuid();

  final List<String> _selectedDeckIds = [];
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _nameController.text.trim().isNotEmpty && _selectedDeckIds.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final deckRepo = context.watch<DeckRepository>();
    final allDecks = deckRepo.getAllDecks();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Roadmap'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Name field ──────────────────────────────
            const Text(
              'Nome do Roadmap',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            ShadInput(
              controller: _nameController,
              placeholder: const Text('Ex: Fundamentos da BNCC'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // ─── Description field ───────────────────────
            const Text(
              'Descrição',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            ShadInput(
              controller: _descriptionController,
              placeholder:
                  const Text('Descreva o caminho de aprendizagem...'),
              minLines: 2,
              maxLines: 4,
            ),
            const SizedBox(height: 24),

            // ─── Deck selector ───────────────────────────
            const Text(
              'Selecionar Decks',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text(
              'Marque os decks e arraste para reordenar.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            if (allDecks.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'Nenhum deck disponível.\nCrie decks primeiro.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              _buildDeckChecklist(allDecks),

            // ─── Selected decks reorderable list ─────────
            if (_selectedDeckIds.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'Ordem dos Decks',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _buildReorderableList(allDecks),
            ],
            const SizedBox(height: 24),

            // ─── Save button ─────────────────────────────
            ShadButton(
              onPressed: _canSave && !_isSaving ? _onSave : null,
              width: double.infinity,
              size: ShadButtonSize.lg,
              enabled: _canSave && !_isSaving,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Criar Roadmap'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeckChecklist(List<Deck> allDecks) {
    return Column(
      children: allDecks.map((deck) {
        final isSelected = _selectedDeckIds.contains(deck.id);
        return CheckboxListTile(
          value: isSelected,
          title: Text(deck.name),
          subtitle: Text('${deck.cardIds.length} cards'),
          dense: true,
          onChanged: (checked) {
            setState(() {
              if (checked == true) {
                _selectedDeckIds.add(deck.id);
              } else {
                _selectedDeckIds.remove(deck.id);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildReorderableList(List<Deck> allDecks) {
    final deckMap = {for (final d in allDecks) d.id: d};

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _selectedDeckIds.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex--;
          final item = _selectedDeckIds.removeAt(oldIndex);
          _selectedDeckIds.insert(newIndex, item);
        });
      },
      itemBuilder: (context, index) {
        final deckId = _selectedDeckIds[index];
        final deck = deckMap[deckId];
        return ListTile(
          key: ValueKey(deckId),
          leading: CircleAvatar(
            radius: 14,
            child: Text(
              '${index + 1}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          title: Text(deck?.name ?? 'Deck desconhecido'),
          trailing: const Icon(Icons.drag_handle),
        );
      },
    );
  }

  Future<void> _onSave() async {
    setState(() => _isSaving = true);

    try {
      final roadmap = Roadmap(
        id: _uuid.v4(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        deckIds: List<String>.from(_selectedDeckIds),
        createdBy: 'user',
      );

      await context.read<DeckRepository>().addRoadmap(roadmap);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Roadmap criado com sucesso!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar roadmap: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
