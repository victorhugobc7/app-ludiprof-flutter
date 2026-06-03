import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:app_ludiprof/Design System/Shared/colors.dart';
import 'package:app_ludiprof/Design System/Shared/typography.dart';
import 'package:app_ludiprof/Services/deck_manager.dart';
import 'package:app_ludiprof/Services/user_repository.dart';
import 'package:app_ludiprof/Services/card_repository.dart';
import 'package:app_ludiprof/Services/deck_repository.dart';
import 'package:app_ludiprof/application/app_coordinator.dart';

/// First-launch onboarding screen.
///
/// Collects the teacher's display name, seeds the initial decks
/// and cards, then navigates to the home screen.
class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _nameController.text.trim().isNotEmpty && !_isLoading;

  Future<void> _onStart() async {
    if (!_canSubmit) return;

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();

      // Capture providers before async gap
      final userRepo = context.read<UserRepository>();
      final cardRepo = context.read<CardRepository>();
      final deckRepo = context.read<DeckRepository>();

      // 1. Create user profile via repository
      await userRepo.createUser(name);

      // 2. Seed initial deck data
      await DeckManager().seedInitialData(cardRepo, deckRepo);

      // 3. Navigate to home
      if (mounted) {
        AppCoordinator().goToHome();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 48),

                  // ── App icon ──────────────────────────────
                  const Text(
                    '📚',
                    style: TextStyle(fontSize: 64),
                  ),
                  const SizedBox(height: 24),

                  // ── Title ─────────────────────────────────
                  Text(
                    'Bem-vindo ao LudiProf!',
                    style: AppTypography.heading1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // ── Subtitle ──────────────────────────────
                  Text(
                    'Sua jornada de desenvolvimento profissional começa aqui.',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // ── Name input ────────────────────────────
                  ShadInput(
                    controller: _nameController,
                    placeholder: const Text('Digite seu nome'),
                  ),
                  const SizedBox(height: 24),

                  // ── Start button ──────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ShadButton(
                      onPressed: _canSubmit ? _onStart : null,
                      enabled: _canSubmit,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Começar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
