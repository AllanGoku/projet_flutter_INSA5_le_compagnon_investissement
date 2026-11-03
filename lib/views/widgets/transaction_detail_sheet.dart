// [AI-GENERATED] Phase 4, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/portfolio_transaction.dart';
import '../../models/asset.dart';
import '../../controllers/data_controller.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatters.dart';
import '../screens/asset_detail_screen.dart';
import 'performance_text.dart';

/// Modale récapitulative des détails d'une transaction sélectionnée.
///
/// Affiche la date/heure d'exécution, le type (Achat/Vente), la quantité,
/// le prix unitaire, le montant total engagé, la plus-value réalisée (si vente),
/// et propose d'accéder directement à la fiche détaillée de l'actif.
class TransactionDetailSheet extends StatelessWidget {
  final PortfolioTransaction transaction;

  const TransactionDetailSheet({
    super.key,
    required this.transaction,
  });

  String _formatDate(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year à $hour:$minute';
  }

  void _openAssetDetail(BuildContext context) {
    Asset? asset;
    try {
      final dataController = context.read<DataController>();
      asset = dataController.assets[transaction.symbol];
    } catch (_) {}

    asset ??= Asset(
      symbol: transaction.symbol,
      name: transaction.assetName,
      currentPrice: transaction.price,
      type: 'Stock',
      description: 'Actif issu du journal de transactions.',
      marketOpen: true,
      timezone: 'UTC',
      timeSeries: {},
    );

    Navigator.of(context).pop(); // Fermer la modale
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AssetDetailScreen(asset: asset!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBuy = transaction.isBuy;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: 24 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poignée de glissement
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // En-tête : Titre & Badge Type
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Détails de la Transaction',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          transaction.assetName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isBuy ? AppTheme.mint.withOpacity(0.15) : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isBuy ? 'ACHAT' : 'VENTE',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isBuy ? AppTheme.primaryColor : Colors.orange.shade900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Conteneur des métriques de la transaction
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Symbole d\'actif', transaction.symbol),
                    const Divider(height: 20),
                    _buildDetailRow('Date & Heure', _formatDate(transaction.timestamp)),
                    const Divider(height: 20),
                    _buildDetailRow(
                      'Quantité',
                      '${transaction.quantity % 1 == 0 ? transaction.quantity.toInt() : transaction.quantity.toStringAsFixed(1)} un.',
                    ),
                    const Divider(height: 20),
                    _buildDetailRow('Prix unitaire d\'exécution', Formatters.formatCurrency(transaction.price)),
                    const Divider(height: 20),
                    _buildDetailRow(
                      'Montant Total Fictif',
                      Formatters.formatCurrency(transaction.totalAmount),
                      isBold: true,
                    ),
                    if (transaction.isSell && transaction.realizedGain != null) ...[
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Plus-value réalisée',
                            style: TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                          PerformanceText(
                            value: transaction.realizedGain!,
                            isCurrency: true,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Bouton pour ouvrir la fiche de l'actif
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openAssetDetail(context),
                  icon: const Icon(Icons.analytics_outlined),
                  label: const Text(
                    'Voir la fiche de l\'actif',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
