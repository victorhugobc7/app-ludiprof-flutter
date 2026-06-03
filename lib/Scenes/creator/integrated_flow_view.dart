import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_ludiprof/Design System/Shared/typography.dart';
import 'package:app_ludiprof/Design System/Components/Inputs/custom_text_input.dart';
import 'package:app_ludiprof/Design System/Components/Buttons/glass_action_button.dart';
import 'package:app_ludiprof/Services/deck_repository.dart';
import 'package:app_ludiprof/Services/card_repository.dart';
import 'package:app_ludiprof/Services/gamification_service.dart';
import 'package:app_ludiprof/application/app_coordinator.dart';

import 'integrated_flow_view_model.dart';

class IntegratedFlowView extends StatefulWidget {
  const IntegratedFlowView({super.key});

  @override
  State<IntegratedFlowView> createState() => _IntegratedFlowViewState();
}

class _IntegratedFlowViewState extends State<IntegratedFlowView> {
  late final IntegratedFlowViewModel _viewModel;
  
  // Controllers
  final _readingController = TextEditingController();
  final _deckNameController = TextEditingController();
  final _qController = TextEditingController();
  final _aController = TextEditingController();
  final _actionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = IntegratedFlowViewModel(
      deckRepo: context.read<DeckRepository>(),
      cardRepo: context.read<CardRepository>(),
      gamificationService: context.read<GamificationService>(),
    );
    _viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    _readingController.dispose();
    _deckNameController.dispose();
    _qController.dispose();
    _aController.dispose();
    _actionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Sessão de Estudo'),
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _buildCurrentStep(),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_viewModel.currentStep) {
      case FlowStep.reading:
        return _buildReadingStep();
      case FlowStep.deckName:
        return _buildDeckNameStep();
      case FlowStep.createCards:
        return _buildCreateCardsStep();
      case FlowStep.createAction:
        return _buildCreateActionStep();
      case FlowStep.summary:
        return _buildSummaryStep();
    }
  }

  Widget _buildReadingStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Passo 1: Leitura Base', style: AppTypography.heading2),
        const SizedBox(height: 16),
        const Text('Cole ou digite o texto do documento que você deseja estudar e transformar em flashcards.'),
        const SizedBox(height: 24),
        CustomTextInput(
          controller: _readingController,
          placeholder: 'Insira o texto base aqui...',
          minLines: 10,
          maxLines: 15,
        ),
        const SizedBox(height: 32),
        Center(
          child: GlassActionButton(
            label: 'Avançar',
            icon: Icons.arrow_forward,
            onPressed: () {
              if (_readingController.text.trim().isNotEmpty) {
                _viewModel.advanceToDeckName(_readingController.text);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDeckNameStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Passo 2: Nome do Deck', style: AppTypography.heading2),
        const SizedBox(height: 16),
        const Text('Dê um título para este conjunto de estudos.'),
        const SizedBox(height: 24),
        CustomTextInput(
          controller: _deckNameController,
          placeholder: 'Ex: Resumo de UX/UI...',
        ),
        const SizedBox(height: 32),
        Center(
          child: GlassActionButton(
            label: 'Avançar',
            icon: Icons.arrow_forward,
            onPressed: () {
              if (_deckNameController.text.trim().isNotEmpty) {
                _viewModel.advanceToCreateCards(_deckNameController.text);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCreateCardsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Passo 3: Criar Flashcards', style: AppTypography.heading2),
        const SizedBox(height: 8),
        Text('${_viewModel.createdCards.length - 1} cards criados nesta sessão.', style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 24),
        const Text('Pergunta:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        CustomTextInput(
          controller: _qController,
          placeholder: 'Qual a principal métrica...?',
        ),
        const SizedBox(height: 16),
        const Text('Resposta:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        CustomTextInput(
          controller: _aController,
          placeholder: 'A métrica principal é...',
          minLines: 3,
          maxLines: 5,
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                if (_qController.text.trim().isNotEmpty && _aController.text.trim().isNotEmpty) {
                  await _viewModel.addCard(_qController.text, _aController.text);
                  if (!mounted) return;
                  _qController.clear();
                  _aController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Card Adicionado!')));
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Card'),
            ),
            GlassActionButton(
              label: 'Finalizar Cards',
              icon: Icons.arrow_forward,
              onPressed: () => _viewModel.advanceToCreateAction(),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildCreateActionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Passo 4: Ação Prática', style: AppTypography.heading2),
        const SizedBox(height: 16),
        const Text('Opcional: Defina um desafio ou tarefa prática para fixar o conhecimento.'),
        const SizedBox(height: 24),
        CustomTextInput(
          controller: _actionController,
          placeholder: 'Ex: Desenhar um wireframe aplicando o conceito de hierarquia...',
          minLines: 4,
          maxLines: 6,
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () => _viewModel.addActionAndFinish(''),
              child: const Text('Pular', style: TextStyle(color: Colors.grey)),
            ),
            GlassActionButton(
              label: 'Concluir Fluxo',
              icon: Icons.check,
              onPressed: () {
                _viewModel.addActionAndFinish(_actionController.text);
              },
            ),
          ],
        )
      ],
    );
  }

  Widget _buildSummaryStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.celebration, size: 80, color: Colors.orange),
        const SizedBox(height: 24),
        Text('Sessão Concluída!', style: AppTypography.heading1),
        const SizedBox(height: 16),
        Text(
          'Você ativou o multiplicador de XP x3 por 10 minutos! Aproveite para revisar seus cards.',
          textAlign: TextAlign.center,
          style: AppTypography.heading3.copyWith(color: Colors.blue),
        ),
        const SizedBox(height: 32),
        GlassActionButton(
          label: 'Estudar Deck Agora',
          icon: Icons.local_fire_department,
          onPressed: () {
            AppCoordinator().goBack();
            if (_viewModel.createdDeck != null) {
              AppCoordinator().goToFlashcards(_viewModel.createdDeck!.id);
            }
          },
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => AppCoordinator().goToHome(),
          child: const Text('Voltar ao Início'),
        )
      ],
    );
  }
}
