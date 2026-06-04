import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:app_ludiprof/Design System/Shared/colors.dart';
import 'package:app_ludiprof/Services/analytics_service.dart';
import 'package:app_ludiprof/Services/card_repository.dart';
import 'package:app_ludiprof/Services/deck_repository.dart';
import 'package:app_ludiprof/Services/gamification_service.dart';
import 'dashboard_view_model.dart';

/// Dashboard with minimalist layout showing study statistics.
class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late DashboardViewModel _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _viewModel = DashboardViewModel(
      analyticsService: context.read<AnalyticsService>(),
      cardRepo: context.read<CardRepository>(),
      deckRepo: context.read<DeckRepository>(),
      gamificationService: context.read<GamificationService>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<CardRepository>();
    context.watch<GamificationService>();
    context.watch<AnalyticsService>();

    return Scaffold(
      backgroundColor: AppColors.surface, // Matches the initial screen card color (white)
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // XP Progress Bar (replacing Streak)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nível ${_viewModel.progress.level}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${_viewModel.progress.currentXp} / ${_viewModel.progress.nextLevelXp} XP',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _viewModel.progress.nextLevelXp > 0
                          ? _viewModel.progress.currentXp / _viewModel.progress.nextLevelXp
                          : 0,
                      minHeight: 16,
                      backgroundColor: AppColors.background,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // Bar Chart
              _buildBarChart(),
              
              const SizedBox(height: 48),

              // Stats List
              _buildStatRow('Cards revisados no total', _viewModel.totalCardsReviewed.toString()),
              const SizedBox(height: 24),
              _buildStatRow('Cards memorizados', _viewModel.cardsMemorizados.toString()),
              const SizedBox(height: 24),
              _buildStatRow('Média diária', _viewModel.mediaDiariaCards.round().toString()),
              const SizedBox(height: 24),
              if (_viewModel.topicoMaisFamiliar != 'Nenhum') ...[
                _buildStatRow('Tópico mais familiar', _viewModel.topicoMaisFamiliar),
                const SizedBox(height: 24),
              ],
              _buildStatRow('Quant. Tópico dominados', _viewModel.quantTopicosDominados.toString()),
              
              const SizedBox(height: 32),
              
              // Divider
              const Divider(color: Color(0xFFDCDCDC), thickness: 1.5),
              
              const SizedBox(height: 32),
              
              // Ranks (Temporary variables)
              _buildStatRow('Rank global', '#48'),
              const SizedBox(height: 24),
              _buildStatRow('Rank diário', '#8'),
              
              const SizedBox(height: 120), // Bottom padding for nav bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Caveat', // Casual font look for numbers
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    final data = _viewModel.getDailyCardsReviewed(days: 7);
    final average = _viewModel.mediaDiariaCards;
    
    // Find max Y for scaling
    double maxY = average;
    for (var entry in data) {
      if (entry.value > maxY) maxY = entry.value.toDouble();
    }
    maxY = maxY < 10 ? 10 : maxY * 1.2; // Add some headroom

    return SizedBox(
      height: 100, // Reduced height
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          minY: 0,
          barTouchData: BarTouchData(enabled: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: average,
                color: AppColors.textPrimary.withValues(alpha: 0.5),
                strokeWidth: 1.5,
                dashArray: [6, 4], // Dashed line effect
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.zero, // Keep inside bounds
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  labelResolver: (line) => '${average.round()}',
                ),
              ),
            ],
          ),
          barGroups: data.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.value.toDouble(),
                  color: AppColors.primary.withValues(alpha: 0.1),
                  width: 32,
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
