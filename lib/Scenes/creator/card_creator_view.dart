import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:app_ludiprof/Design System/Components/Inputs/custom_text_input.dart';
import 'package:app_ludiprof/Design System/Components/Buttons/glass_action_button.dart';
import 'package:provider/provider.dart';

import 'package:app_ludiprof/Models/card_type.dart';
import 'package:app_ludiprof/Services/card_repository.dart';
import 'package:app_ludiprof/Services/deck_repository.dart';
import 'package:app_ludiprof/Services/gamification_service.dart';

import 'card_creator_view_model.dart';

/// Card creation form screen.
///
/// Allows users to create new flashcards with type selection,
/// question/answer fields, and deck assignment.
class CardCreatorView extends StatefulWidget {
  const CardCreatorView({super.key});

  @override
  State<CardCreatorView> createState() => _CardCreatorViewState();
}

class _CardCreatorViewState extends State<CardCreatorView> {
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  final _viewModel = CardCreatorViewModel();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  String get _questionLabel {
    switch (_viewModel.selectedType) {
      case CardType.conceito:
        return 'Conceito';
      case CardType.cenarioProblema:
        return 'Cenário';
      case CardType.acaoPratica:
        return 'Tarefa';
    }
  }

  String get _answerLabel {
    switch (_viewModel.selectedType) {
      case CardType.conceito:
        return 'Resposta';
      case CardType.cenarioProblema:
        return 'Análise';
      case CardType.acaoPratica:
        return 'Instruções';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Card'),
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
            // ─── Card type selector ──────────────────────
            const Text(
              'Tipo do Card',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: CardType.values.map((type) {
                final isSelected = _viewModel.selectedType == type;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: type != CardType.acaoPratica ? 8 : 0,
                    ),
                    child: isSelected
                        ? ShadButton(
                            onPressed: () => _viewModel.setType(type),
                            child: Text(
                              '${type.emoji} ${type.label}',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        : ShadButton.outline(
                            onPressed: () => _viewModel.setType(type),
                            child: Text(
                              '${type.emoji} ${type.label}',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ─── Deck Reference ────────────────────────────
            const Center(
              child: Text(
                'UX/UI',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ─── Question field ──────────────────────────
            Center(
              child: Text(
                _questionLabel,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            CustomTextInput(
              controller: _questionController,
              placeholder: 'Escreva a pergunta aqui...',
              minLines: 1,
              maxLines: 3,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),

            // ─── Answer field ────────────────────────────
            if (_viewModel.selectedType != CardType.acaoPratica) ...[
              Center(
                child: Text(
                  _answerLabel,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              CustomTextInput(
                controller: _answerController,
                placeholder: 'Escreva a resposta aqui...',
                minLines: 6,
                maxLines: 10,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 32),
            ],

            // ─── Save button ─────────────────────────────
            Center(
              child: GlassActionButton(
                label: 'Concluir',
                icon: Icons.check,
                onPressed: _canSave && !_isSaving ? _onSave : null,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  bool get _canSave => _viewModel.canSave(
        _questionController.text,
        _answerController.text,
      );

  Future<void> _onSave() async {
    setState(() => _isSaving = true);

    try {
      await _viewModel.saveCard(
        question: _questionController.text,
        answer: _answerController.text,
        cardRepo: context.read<CardRepository>(),
        deckRepo: context.read<DeckRepository>(),
        gamificationService: context.read<GamificationService>(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Card criado com sucesso!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar card: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
