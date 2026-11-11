// [AI-GENERATED] Phase 4, Agent, 2025-02-23
import 'package:flutter/material.dart';

import '../../models/portfolio_position.dart';
import '../../models/financial_calculator.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatters.dart';
import 'performance_text.dart';

/// Carte représentant une ligne (position) dans le portefeuille fictif de l'utilisateur.
///
/// Affiche la quantité détenue, le Prix Moyen Pondéré d'Achat (PMPA), la valeur actuelle du marché,
/// la plus/moins-value latente (€ et %) et propose le bouton d'action "Vendre".
/// Un clic sur la carte déclenche [onTap] (pour ouvrir la fiche de l'actif).
class PortfolioPositionCard extends StatelessWidget {
  final PortfolioPosition position;
  final VoidCallback onSellPressed;
  final VoidCallback? onTap;

  const PortfolioPositionCard({
    super.key,
    required this.position,
    required this.onSellPressed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double currentValue = position.quantity * position.asset.currentPrice;
    final double investedValue =
        position.quantity * position.averagePurchasePrice;
    final double capitalGain = FinancialCalculator.calculateCapitalGain(
      investedAmount: investedValue,
      currentValue: currentValue,
    );
    final double performance = FinancialCalculator.calculatePerformance(
      initialValue: investedValue,
      currentValue: currentValue,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // En-tête : Nom, Symbole, Type, et Valeur totale courante
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.mint.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.show_chart_rounded,
                              color: AppTheme.primaryColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      position.asset.symbol,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        position.asset.type,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  position.asset.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          Formatters.formatCurrency(currentValue),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PerformanceText(
                              value: capitalGain,
                              isCurrency: true,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              ' (',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            PerformanceText(
                              value: performance,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              ')',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                const Divider(
                  height: 1,
                  thickness: 0.6,
                  color: Color(0xFFEEEEEE),
                ),
                const SizedBox(height: 12),

                // Détails : Quantité, PMPA, Cours actuel + Bouton "Vendre"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailColumn(
                      'Quantité',
                      '${position.quantity % 1 == 0 ? position.quantity.toInt() : position.quantity.toStringAsFixed(1)} un.',
                    ),
                    _buildDetailColumn(
                      'PMPA d\'achat',
                      Formatters.formatCurrency(position.averagePurchasePrice),
                    ),
                    _buildDetailColumn(
                      'Cours actuel',
                      Formatters.formatCurrency(position.asset.currentPrice),
                    ),
                    OutlinedButton.icon(
                      onPressed: onSellPressed,
                      icon: const Icon(Icons.sell_outlined, size: 14),
                      label: const Text('Vendre'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        side: BorderSide(color: Colors.red.shade200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
