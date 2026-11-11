// [AI-GENERATED] Phase 3, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../models/price_point.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatters.dart';

/// Composant graphique boursier interactif basé sur `fl_chart`.
///
/// Affiche la courbe historique d'un actif avec sélection de périodes (7J, 1M, 1A, MAX),
/// graduation strictement limitée et unique pour les bornes MIN/MAX en X (dates) et en Y (cours),
/// et survol tactile dynamique affichant la date exacte et le cours sélectionné.
class AssetHistoricalChart extends StatefulWidget {
  /// Map des séries temporelles (horodatage -> PricePoint).
  final Map<String, PricePoint> timeSeries;

  /// Hauteur globale du graphique.
  final double height;

  const AssetHistoricalChart({
    super.key,
    required this.timeSeries,
    this.height = 260.0,
  });

  @override
  State<AssetHistoricalChart> createState() => _AssetHistoricalChartState();
}

class _AssetHistoricalChartState extends State<AssetHistoricalChart> {
  String _selectedPeriod = '7J';
  int? _touchedIndex;

  /// Filtre les points de données chronologiques selon la période sélectionnée.
  List<MapEntry<String, PricePoint>> _getFilteredPoints() {
    if (widget.timeSeries.isEmpty) return [];

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

  /// Formate une chaîne de date au format court pour l'axe X (ex: 23/02 ou 23/02/25).
  String _formatShortDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      if (_selectedPeriod == '1A' || _selectedPeriod == 'MAX') {
        final year = dt.year.toString().substring(2);
        return '$day/$month/$year';
      }
      return '$day/$month';
    } catch (_) {
      if (dateStr.contains('-') && dateStr.length >= 10) {
        final parts = dateStr.split('-');
        if (parts.length >= 3) {
          return '${parts[2].substring(0, 2)}/${parts[1]}';
        }
      }
      return dateStr;
    }
  }

  /// Formate une chaîne de date au format complet (ex: 23/02/2025).
  String _formatFullDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final year = dt.year;
      return '$day/$month/$year';
    } catch (_) {
      return dateStr;
    }
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
    final Color trendColor = isPositive
        ? AppTheme.gainColor
        : AppTheme.lossColor;

    // Point actif (touché par l'utilisateur ou le dernier point par défaut)
    final int activeIndex =
        (_touchedIndex != null &&
            _touchedIndex! >= 0 &&
            _touchedIndex! < spots.length)
        ? _touchedIndex!
        : (spots.length - 1);
    final String activeDate = _formatFullDate(dates[activeIndex]);
    final String activePrice = Formatters.formatCurrency(spots[activeIndex].y);

    // Calcul des bornes Y strictement réelles
    final double rawMinY = spots
        .map((s) => s.y)
        .reduce((a, b) => a < b ? a : b);
    final double rawMaxY = spots
        .map((s) => s.y)
        .reduce((a, b) => a > b ? a : b);

    final double deltaY = (rawMaxY - rawMinY).abs();
    final double paddingY = deltaY == 0
        ? (rawMaxY > 0 ? rawMaxY * 0.1 : 1.0)
        : deltaY * 0.08;

    final double minY = (rawMinY - paddingY).clamp(0.0, double.infinity);
    final double maxY = rawMaxY + paddingY;
    final double yRange = (maxY - minY) == 0 ? 1.0 : (maxY - minY);

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
          // 1. Boutons de sélection de la période (7J, 1M, 1A, MAX)
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
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
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
                        _touchedIndex = null;
                      });
                    }
                  },
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // 2. Bandeau d'information du point sélectionné (Date & Valeur)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      activeDate,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                Text(
                  activePrice,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: trendColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Zone du graphique fl_chart affichant le prix MIN/MAX unique (Y) et la date MIN/MAX unique (X)
          SizedBox(
            height: widget.height - 110,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (spots.length - 1).toDouble(),
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: Colors.grey.shade100, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 58,
                      interval: yRange,
                      getTitlesWidget: (value, meta) {
                        // fl_chart appelle getTitlesWidget exactement deux fois : pour meta.min et meta.max
                        if ((value - meta.min).abs() < 0.001) {
                          return SideTitleWidget(
                            meta: meta,
                            fitInside: SideTitleFitInsideData.fromTitleMeta(
                              meta,
                            ),
                            child: Text(
                              Formatters.formatCurrency(rawMinY),
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          );
                        }

                        if ((value - meta.max).abs() < 0.001) {
                          return SideTitleWidget(
                            meta: meta,
                            fitInside: SideTitleFitInsideData.fromTitleMeta(
                              meta,
                            ),
                            child: Text(
                              Formatters.formatCurrency(rawMaxY),
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 1.0,
                      getTitlesWidget: (value, meta) {
                        final index = value.round();
                        if ((value - index).abs() > 0.01) {
                          return const SizedBox.shrink();
                        }
                        final int total = dates.length;
                        if (index < 0 || index >= total) {
                          return const SizedBox.shrink();
                        }

                        // Affiche STRICTEMENT et UNIQUEMENT la date min (index 0) et la date max (index total - 1)
                        if (index != 0 && index != total - 1) {
                          return const SizedBox.shrink();
                        }

                        final Alignment alignment = (index == 0)
                            ? Alignment.topLeft
                            : Alignment.topRight;

                        return SideTitleWidget(
                          meta: meta,
                          fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                          child: Align(
                            alignment: alignment,
                            child: Text(
                              _formatShortDate(dates[index]),
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchCallback:
                      (FlTouchEvent event, LineTouchResponse? touchResponse) {
                        if (event is FlPanEndEvent || event is FlTapUpEvent) {
                          setState(() {
                            _touchedIndex = null;
                          });
                        } else if (touchResponse != null &&
                            touchResponse.lineBarSpots != null &&
                            touchResponse.lineBarSpots!.isNotEmpty) {
                          final index =
                              touchResponse.lineBarSpots!.first.spotIndex;
                          setState(() {
                            _touchedIndex = index;
                          });
                        }
                      },
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final index = spot.x.toInt();
                        final dateStr = (index >= 0 && index < dates.length)
                            ? _formatFullDate(dates[index])
                            : '';
                        final formattedPrice = Formatters.formatCurrency(
                          spot.y,
                        );
                        return LineTooltipItem(
                          '$dateStr\n$formattedPrice',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
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
