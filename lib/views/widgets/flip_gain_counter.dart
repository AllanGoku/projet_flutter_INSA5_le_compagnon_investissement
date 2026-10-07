// [AI-GENERATED] Phase 2, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatters.dart';

/// Widget d'en-tête affichant la synthèse globale du portefeuille fictif.
///
/// Intègre [AnimatedFlipCounter] pour basculer de manière très fluide et animée
/// entre l'affichage de la plus/moins-value en pourcentage (%) et en euros (€) lors
/// d'un appui tactile sur la pilule de performance.
class FlipGainCounter extends StatefulWidget {
  final double totalValue;
  final double capitalGain;
  final double performancePercentage;
  final String userName;

  const FlipGainCounter({
    super.key,
    required this.totalValue,
    required this.capitalGain,
    required this.performancePercentage,
    this.userName = 'Novice',
  });

  @override
  State<FlipGainCounter> createState() => _FlipGainCounterState();
}

class _FlipGainCounterState extends State<FlipGainCounter> {
  /// Indique si la pilule de gain affiche le pourcentage (true) ou le montant en euros (false).
  bool _showPercentage = true;

  void _toggleDisplay() {
    setState(() {
      _showPercentage = !_showPercentage;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isGain = widget.capitalGain >= 0;
    final Color gainLossColor = isGain ? AppTheme.gainColor : AppTheme.lossColor;
    final Color pillBgColor = gainLossColor.withOpacity(0.15);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0x2634D399), // mint avec opacité 15%
            Color(0x2638BDF8), // azure avec opacité 15%
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      padding: const EdgeInsets.only(
        top: 48,
        left: 20,
        right: 20,
        bottom: 28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ligne de salutation et profil
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bonjour, ${widget.userName}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Ton Portefeuille Fictif',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(color: Colors.blue.shade50, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'N',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.azure,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Valeur totale et pilule de gain animée
          Text(
            'Valeur Totale',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),

          InkWell(
            onTap: _toggleDisplay,
            borderRadius: BorderRadius.circular(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  Formatters.formatCurrency(widget.totalValue),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 12),

                // Pilule interactive gain/perte
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: pillBgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isGain ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                        size: 14,
                        color: gainLossColor,
                      ),
                      const SizedBox(width: 4),
                      AnimatedFlipCounter(
                        value: _showPercentage ? widget.performancePercentage : widget.capitalGain,
                        prefix: _showPercentage
                            ? (widget.performancePercentage > 0 ? '+ ' : '')
                            : (widget.capitalGain > 0 ? '+ ' : ''),
                        suffix: _showPercentage ? ' %' : ' €',
                        fractionDigits: 2,
                        textStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: gainLossColor,
                        ),
                        duration: const Duration(milliseconds: 300),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
