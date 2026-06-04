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
    // Listen to changes if needed (but currently ViewModel is mostly rebuilt on dependency change)
    // Actually, GamificationService and others notify listeners, but since we are not using 
    // a Consumer here, we just read the latest state on build.
    // If the data updates dynamically while on this screen, we'd need context.watch.
    
    // Using context.watch to rebuild when repositories change
    context.watch<CardRepository>();
    context.watch<GamificationService>();
    context.watch<AnalyticsService>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Streak
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Streak\n${_viewModel.streak}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'Caveat', // Assuming a handwritten font if available, or just regular
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Bar Chart
              _buildBarChart(),
              
              const SizedBox(height: 48),

              // Stats List
              _buildStatRow('cards revisados no total', _viewModel.totalCardsReviewed.toString()),
              const SizedBox(height: 24),
              _buildStatRow('Cards memorizados', _viewModel.cardsMemorizados.toString()),
              const SizedBox(height: 24),
              _buildStatRow('Tópico mais familiar', _viewModel.topicoMaisFamiliar),
              const SizedBox(height: 24),
              _buildStatRow('Quant. Tópico dominados', _viewModel.quantTopicosDominados.toString()),
              
              const SizedBox(height: 32),
              
              // Divider
              const Divider(color: AppColors.border, thickness: 1.5),
              
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
            fontFamily: 'Caveat', // Try handwritten/casual font look for numbers if possible
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
      height: 160,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          BarChart(
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
                      padding: const EdgeInsets.only(right: -30),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
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
          
          // "média diária de cards" label on the left side
          Positioned(
            left: -10, // A bit off-screen if needed, or adjust padding
            top: 160 - (average / maxY * 160) - 20, // Calculate roughly the height position
            child: const Text(
              'média diária\nde cards',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
