// [AI-GENERATED] Phase 4, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/portfolio_controller.dart';
import '../../models/asset.dart';
import '../../models/portfolio_position.dart';
import '../../models/portfolio_transaction.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatters.dart';
import '../widgets/performance_text.dart';
import '../widgets/portfolio_allocation_chart.dart';
import '../widgets/portfolio_position_card.dart';
import '../widgets/cash_balance_card.dart';
import '../widgets/sell_asset_sheet.dart';
import '../widgets/transaction_history_section.dart';
import '../widgets/transaction_detail_sheet.dart';
import 'asset_detail_screen.dart';

/// Écran principal de gestion dédiée du portefeuille fictif (`PortfolioScreen`).
///
/// Affiche la synthèse financière globale (patrimoine total, liquidités, plus-values latentes et réalisées),
/// la carte de liquidités animée ([CashBalanceCard]), le graphique de répartition en donut ([PortfolioAllocationChart]),
/// la liste détaillée des positions ([PortfolioPositionCard]) et l'historique des transactions.
class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  void _openSellModal(BuildContext context, PortfolioPosition position) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SellAssetSheet(
        position: position,
        onSellSuccess: () {
          setState(() {});
        },
      ),
    );
  }

  void _openAssetDetail(Asset asset) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AssetDetailScreen(asset: asset),
      ),
    );
  }

  void _openTransactionDetail(PortfolioTransaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionDetailSheet(transaction: transaction),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Mon Portefeuille',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: Consumer<PortfolioController>(
        builder: (context, portfolio, child) {
          final positions = portfolio.positions;
          final transactions = portfolio.transactions;

          return RefreshIndicator(
            onRefresh: () async {
              await context.read<PortfolioController>().loadPositions();
            },
            color: AppTheme.primaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Carte de Synthèse Financière Globale (Patrimoine Total = Actifs + Liquidités)
                  _buildSummaryCard(portfolio),
                  const SizedBox(height: 12),

                  // 2. Carte des Liquidités Disponibles (avec AnimatedFlipCounter)
                  CashBalanceCard(cashBalance: portfolio.cashBalance),
                  const SizedBox(height: 20),

                  // 3. Graphique de Répartition du Portefeuille
                  PortfolioAllocationChart(
                    positions: positions,
                    totalValue: portfolio.totalValue,
                  ),
                  const SizedBox(height: 24),

                  // 4. Liste des Positions Détenues
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mes Positions (${positions.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (positions.isEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 48,
                            color: AppTheme.mint.withOpacity(0.6),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Portefeuille vide',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Votre portefeuille d\'actifs est vide. Utilisez vos liquidités pour réaliser vos premiers achats d\'actions ou d\'ETF !',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: positions.length,
                      itemBuilder: (context, index) {
                        final pos = positions[index];
                        return PortfolioPositionCard(
                          position: pos,
                          onSellPressed: () => _openSellModal(context, pos),
                          onTap: () => _openAssetDetail(pos.asset),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 24),

                  // 5. Section Historique des Transactions
                  TransactionHistorySection(
                    transactions: transactions,
                    onTransactionSelected: (tx) => _openTransactionDetail(tx),
                  ),
                  const SizedBox(height: 100), // Marge pour la barre de nav
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(PortfolioController portfolio) {
    final double netWorth = portfolio.totalValue + portfolio.cashBalance;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D3B2E), AppTheme.primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Patrimoine Total (Actifs + Cash)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Fictif',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            Formatters.formatCurrency(netWorth),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          Container(
            height: 1,
            color: Colors.white.withOpacity(0.15),
          ),
          const SizedBox(height: 14),

          // Ligne des sous-métriques : Valeur Actifs, Gain Latent, Gain Réalisé
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Valeur Actifs',
                      style: TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        Formatters.formatCurrency(portfolio.totalValue),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Gain Latent',
                      style: TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PerformanceText(
                            value: portfolio.totalCapitalGain,
                            isCurrency: true,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            ' (',
                            style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7)),
                          ),
                          PerformanceText(
                            value: portfolio.totalPerformance,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            ')',
                            style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Gain Réalisé',
                      style: TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: PerformanceText(
                        value: portfolio.totalRealizedGain,
                        isCurrency: true,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
