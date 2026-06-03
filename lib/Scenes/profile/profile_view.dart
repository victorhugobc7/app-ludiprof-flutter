import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:app_ludiprof/Design System/Components/Gamification/xp_bar.dart';
import 'package:app_ludiprof/Design System/Components/Gamification/streak_card.dart';
import 'package:app_ludiprof/Design System/Components/Gamification/level_card.dart';
import 'package:app_ludiprof/Design System/Components/Gamification/badge_grid.dart';
import 'package:app_ludiprof/Services/user_repository.dart';
import 'package:app_ludiprof/Services/gamification_service.dart';
import 'package:app_ludiprof/Services/card_repository.dart';
import 'package:app_ludiprof/Services/analytics_service.dart';
import 'package:app_ludiprof/Models/gamification_models.dart';

/// Teacher profile screen showing gamification progress and badges.
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  UserProgress? _progress;
  bool _isEditing = false;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _loadProgress();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    final gamification = context.read<GamificationService>();
    final progress = await gamification.getProgress();
    if (mounted) {
      setState(() {
        _progress = progress;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userRepo = context.watch<UserRepository>();
    final cardRepo = context.watch<CardRepository>();
    final analyticsService = context.watch<AnalyticsService>();
    final user = userRepo.getUser();

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Perfil')),
        body: const Center(child: Text('Perfil não encontrado.')),
      );
    }

    _nameController.text = user.displayName;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () async {
              if (_isEditing) {
                final newName = _nameController.text.trim();
                if (newName.isNotEmpty) {
                  await userRepo.updateUser(user.copyWith(displayName: newName));
                }
              }
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFF3F51B5),
                    child: Text(
                      user.displayName.isNotEmpty
                          ? user.displayName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_isEditing)
                    SizedBox(
                      width: 200,
                      child: ShadInput(
                        controller: _nameController,
                        placeholder: const Text('Seu nome'),
                      ),
                    )
                  else
                    Text(
                      user.displayName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    'Membro desde ${_formatDate(user.createdAt)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Gamification section
            if (_progress != null) ...[
              const Text(
                'Progresso',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              LevelCard(progress: _progress!),
              const SizedBox(height: 16),
              XpBar(progress: _progress!),
              const SizedBox(height: 16),
              StreakCard(progress: _progress!),
              const SizedBox(height: 24),

              const Text(
                'Conquistas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              BadgeGrid(
                progress: _progress!,
                allBadges: GamificationService.availableBadges,
              ),
              const SizedBox(height: 24),
            ],

            // Stats summary
            const Text(
              'Estatísticas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildStatsGrid(cardRepo, analyticsService),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(
      CardRepository cardRepo, AnalyticsService analyticsService) {
    final totalCards = cardRepo.getAllCards().length;
    final userCards =
        cardRepo.getAllCards().where((c) => c.createdBy != 'system').length;
    final totalReviewed = analyticsService.getTotalCardsReviewed();
    final studyMinutes =
        (analyticsService.getTotalStudyTimeMs() / 60000).round();

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _statCard('📚', '$totalCards', 'Cards Totais'),
        _statCard('✏️', '$userCards', 'Cards Criados'),
        _statCard('🔄', '$totalReviewed', 'Revisões'),
        _statCard('⏱️', '${studyMinutes}min', 'Tempo de Estudo'),
      ],
    );
  }

  Widget _statCard(String emoji, String value, String label) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 44) / 2,
      child: ShadCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
