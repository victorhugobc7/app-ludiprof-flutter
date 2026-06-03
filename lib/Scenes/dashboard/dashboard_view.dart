import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:app_ludiprof/Models/card_type.dart';
import 'package:app_ludiprof/Services/analytics_service.dart';
import 'dashboard_view_model.dart';

/// Performance dashboard for teachers to visualize progress and knowledge gaps.
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard de Desempenho'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary stats row
            _buildSummaryCards(),
            const SizedBox(height: 24),

            // Cards reviewed over time
            const Text(
              'Cards Revisados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildCardsReviewedChart(),
            const SizedBox(height: 24),

            // Accuracy by card type
            const Text(
              'Taxa de Acerto por Tipo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildAccuracyByTypeChart(),
            const SizedBox(height: 24),

            // Accuracy trend
            const Text(
              'Tendência de Acerto',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildAccuracyTrendChart(),
            const SizedBox(height: 24),

            // Recent sessions
            const Text(
              'Sessões Recentes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildRecentSessions(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: ShadCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('📚', style: TextStyle(fontSize: 28)),
                  const SizedBox(height: 8),
                  Text(
                    '${_viewModel.totalCardsReviewed}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Cards Revisados',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ShadCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('🎯', style: TextStyle(fontSize: 28)),
                  const SizedBox(height: 8),
                  Text(
                    '${(_viewModel.overallAccuracy * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Taxa de Acerto',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ShadCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('⏱️', style: TextStyle(fontSize: 28)),
                  const SizedBox(height: 8),
                  Text(
                    '${_viewModel.totalStudyTimeMinutes}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Min Estudando',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardsReviewedChart() {
    final data = _viewModel.getDailyCardsReviewed(days: 7);
    if (data.isEmpty || data.every((e) => e.value == 0)) {
      return ShadCard(
        child: SizedBox(
          height: 200,
          child: const Center(
            child: Text(
              'Nenhuma sessão de estudo ainda.\nComece a estudar para ver seu progresso!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    final dateFormat = DateFormat('dd/MM');

    return ShadCard(
      child: SizedBox(
        height: 200,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: data.map((e) => e.value.toDouble()).reduce((a, b) => a > b ? a : b) * 1.2,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.round()} cards',
                      const TextStyle(color: Colors.white, fontSize: 12),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= data.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          dateFormat.format(data[index].key),
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.round().toString(),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              barGroups: data.asMap().entries.map((entry) {
                return BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value.value.toDouble(),
                      color: const Color(0xFF3F51B5),
                      width: 20,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccuracyByTypeChart() {
    final accuracy = _viewModel.accuracyByCardType;
    if (accuracy.isEmpty) {
      return ShadCard(
        child: SizedBox(
          height: 150,
          child: const Center(
            child: Text(
              'Revise cards para ver a análise por tipo.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return ShadCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: CardType.values.map((type) {
            final acc = accuracy[type] ?? 0.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Text(type.emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: Text(
                      type.label,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: acc,
                        minHeight: 12,
                        backgroundColor: Colors.grey[200],
                        color: _colorForType(type),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 45,
                    child: Text(
                      '${(acc * 100).round()}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAccuracyTrendChart() {
    final trend = _viewModel.getAccuracyTrend(lastN: 10);
    if (trend.isEmpty) {
      return ShadCard(
        child: SizedBox(
          height: 150,
          child: const Center(
            child: Text(
              'Mais sessões necessárias para análise de tendência.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return ShadCard(
      child: SizedBox(
        height: 200,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: 1,
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt() + 1}',
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${(value * 100).round()}%',
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                drawHorizontalLine: true,
                horizontalInterval: 0.25,
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: trend.asMap().entries.map((e) {
                    return FlSpot(e.key.toDouble(), e.value);
                  }).toList(),
                  isCurved: true,
                  color: const Color(0xFF4CAF50),
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSessions() {
    final sessions = _viewModel.getRecentSessions(days: 30);
    if (sessions.isEmpty) {
      return ShadCard(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: const Center(
            child: Text(
              'Nenhuma sessão de estudo registrada.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    final recentSessions = sessions.length > 10
        ? sessions.sublist(sessions.length - 10)
        : sessions;

    return Column(
      children: recentSessions.reversed.map((session) {
        final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
        final durationMin = (session.totalTimeMs / 60000).round();
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ShadCard(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateFormat.format(session.sessionDate),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${session.cardsReviewed} cards • ${durationMin}min',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _accuracyColor(session.accuracyRate)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${(session.accuracyRate * 100).round()}%',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _accuracyColor(session.accuracyRate),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _colorForType(CardType type) {
    switch (type) {
      case CardType.conceito:
        return const Color(0xFF42A5F5);
      case CardType.cenarioProblema:
        return const Color(0xFFFF7043);
      case CardType.acaoPratica:
        return const Color(0xFF66BB6A);
    }
  }

  Color _accuracyColor(double accuracy) {
    if (accuracy >= 0.8) return const Color(0xFF4CAF50);
    if (accuracy >= 0.6) return const Color(0xFFFFC107);
    return const Color(0xFFE53935);
  }
}
