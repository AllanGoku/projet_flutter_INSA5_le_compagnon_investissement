// [AI-GENERATED] Phase 4, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/portfolio_position.dart';
import '../../models/financial_calculator.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatters.dart';

/// Palette de couleurs harmonieuses pour le graphique de répartition en donut.
const List<Color> _chartColors = [
  AppTheme.primaryColor,
  AppTheme.azure,
  AppTheme.mint,
  Colors.purple,
  Colors.orange,
  Colors.teal,
  Colors.pink,
  Colors.indigo,
];

/// Widget affichant la répartition du portefeuille sous forme de Donut Chart (PieChart via `fl_chart`).
///
/// Calcule la proportion de chaque position via [FinancialCalculator.calculateAllocationPercentage]
/// et affiche une légende détaillée sous le graphique.
class PortfolioAllocationChart extends StatelessWidget {
  final List<PortfolioPosition> positions;
  final double totalValue;

  const PortfolioAllocationChart({
    super.key,
    required this.positions,
    required this.totalValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Répartition du Portefeuille',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          if (positions.isEmpty || totalValue <= 0) ...[
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Icon(
                      Icons.pie_chart_outline_rounded,
                      size: 48,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Aucune position à afficher',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Row(
              children: [
                // Graphique Donut (fl_chart)
                SizedBox(
                  height: 120,
                  width: 120,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 28,
                      startDegreeOffset: -90,
                      sections: List.generate(positions.length, (index) {
                        final pos = positions[index];
                        final positionVal = pos.quantity * pos.asset.currentPrice;
                        final percentage = FinancialCalculator.calculateAllocationPercentage(
                          positionValue: positionVal,
                          totalPortfolioValue: totalValue,
                        );
                        final color = _chartColors[index % _chartColors.length];

                        return PieChartSectionData(
                          color: color,
                          value: positionVal,
                          title: '${percentage.toStringAsFixed(0)}%',
                          radius: 22,
                          titleStyle: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Légende des actifs sécurisée contre les débordements (RenderFlex overflow)
                Expanded(
                  child: Column(
                    children: List.generate(positions.length, (index) {
                      final pos = positions[index];
                      final positionVal = pos.quantity * pos.asset.currentPrice;
                      final percentage = FinancialCalculator.calculateAllocationPercentage(
                        positionValue: positionVal,
                        totalPortfolioValue: totalValue,
                      );
                      final color = _chartColors[index % _chartColors.length];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      pos.asset.symbol,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${percentage.toStringAsFixed(1)}% (${Formatters.formatCurrency(positionVal)})',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
