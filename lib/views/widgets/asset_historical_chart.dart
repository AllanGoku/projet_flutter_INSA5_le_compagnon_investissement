// [AI-GENERATED] Phase 3, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/price_point.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatters.dart';

/// Composant graphique boursier interactif basé sur `fl_chart`.
///
/// Affiche la courbe historique d'un actif avec sélection de périodes (7J, 1M, 1A, MAX),
/// infobulle tactile au survol/toucher et dégradé sous la courbe adapté à la hausse/baisse.
class AssetHistoricalChart extends StatefulWidget {
  /// Map des séries temporelles (horodatage -> PricePoint).
  final Map<String, PricePoint> timeSeries;

  /// Hauteur globale du graphique.
  final double height;

  const AssetHistoricalChart({
    super.key,
    required this.timeSeries,
    this.height = 240.0,
  });

  @override
  State<AssetHistoricalChart> createState() => _AssetHistoricalChartState();
}

class _AssetHistoricalChartState extends State<AssetHistoricalChart> {
  String _selectedPeriod = '7J';

  /// Filtre les points de données chronologiques selon la période sélectionnée.
  List<MapEntry<String, PricePoint>> _getFilteredPoints() {
    if (widget.timeSeries.isEmpty) return [];

    // Tri chronologique croissant par date (du plus ancien au plus récent)
    final sortedEntries = widget.timeSeries.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    int count = sortedEntries.length;
    int limit;

    switch (_selectedPeriod) {
      case '7J':
        limit = 7;
        break;
      case '1M':
        limit = 30;
        break;
      case '1A':
        limit = 365;
        break;
      case 'MAX':
      default:
        limit = count;
        break;
    }

    if (count <= limit) return sortedEntries;
    return sortedEntries.sublist(count - limit);
  }

  @override
  Widget build(BuildContext context) {
    final filteredPoints = _getFilteredPoints();

    if (filteredPoints.isEmpty) {
      return Container(
        height: widget.height,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.show_chart_rounded, size: 40, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'Historique non disponible',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    final List<FlSpot> spots = [];
    final List<String> dates = [];

    for (int i = 0; i < filteredPoints.length; i++) {
      final entry = filteredPoints[i];
      dates.add(entry.key);
      spots.add(FlSpot(i.toDouble(), entry.value.close));
    }

    // Calcul de la tendance globale sur la période sélectionnée
    final double firstPrice = spots.first.y;
    final double lastPrice = spots.last.y;
    final bool isPositive = lastPrice >= firstPrice;
    final Color trendColor = isPositive ? AppTheme.gainColor : AppTheme.lossColor;

    // Calcul des min/max Y pour une courbe bien équilibrée
    double minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    double maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);

    // Marge visuelle en haut et en bas de la courbe
    final double deltaY = (maxY - minY).abs();
    final double paddingY = deltaY == 0 ? 1.0 : deltaY * 0.08;
    minY -= paddingY;
    maxY += paddingY;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Boutons de sélection de la période (7J, 1M, 1A, MAX)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: ['7J', '1M', '1A', 'MAX'].map((period) {
              final isSelected = _selectedPeriod == period;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  key: Key('period_chip_$period'),
                  label: Text(period),
                  selected: isSelected,
                  selectedColor: trendColor.withOpacity(0.15),
                  backgroundColor: AppTheme.backgroundColor,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? trendColor : Colors.black54,
                  ),
                  side: BorderSide(
                    color: isSelected ? trendColor : Colors.transparent,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedPeriod = period;
                      });
                    }
                  },
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Zone du graphique fl_chart
          SizedBox(
            height: widget.height - 70,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (spots.length - 1).toDouble(),
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.shade100,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: const FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final index = spot.x.toInt();
                        final dateStr = (index >= 0 && index < dates.length)
                            ? dates[index]
                            : '';
                        final formattedPrice = Formatters.formatCurrency(spot.y);
                        return LineTooltipItem(
                          '$dateStr\n$formattedPrice',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    barWidth: 2.8,
                    color: trendColor,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          trendColor.withOpacity(0.35),
                          trendColor.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
