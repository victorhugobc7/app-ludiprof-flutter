import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:app_ludiprof/Models/deck.dart';
import 'package:app_ludiprof/Services/deck_repository.dart';

/// Deck creation form screen.
///
/// Simple form with name and description fields.
/// Creates a new empty Deck and persists it via DeckRepository.
class DeckCreatorView extends StatefulWidget {
  const DeckCreatorView({super.key});

  @override
  State<DeckCreatorView> createState() => _DeckCreatorViewState();
}

class _DeckCreatorViewState extends State<DeckCreatorView> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _uuid = const Uuid();

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _canSave => _nameController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Deck'),
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
            const Text(
              'Nome do Deck',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            ShadInput(
              controller: _nameController,
              placeholder: const Text('Ex: BNCC Fundamentos'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            const Text(
              'Descrição',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            ShadInput(
              controller: _descriptionController,
              placeholder: const Text('Descreva o conteúdo do deck...'),
              minLines: 3,
              maxLines: 5,
            ),
            const SizedBox(height: 24),

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
                  : const Text('Criar Deck'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    setState(() => _isSaving = true);

    try {
      final deck = Deck(
        id: _uuid.v4(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        createdBy: 'user',
      );

      await context.read<DeckRepository>().addDeck(deck);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deck criado com sucesso!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar deck: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
