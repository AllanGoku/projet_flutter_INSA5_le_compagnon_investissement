// [AI-GENERATED] Phase 3, Agent, 2025-02-23
import 'package:flutter/material.dart';
import '../../models/asset.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatters.dart';
import '../widgets/asset_historical_chart.dart';
import '../widgets/market_term_help_button.dart';
import '../widgets/buy_asset_sheet.dart';

/// Écran complet de détail et d'analyse pédagogique d'un actif financier.
///
/// Présente les informations clés, la grille "Statistiques Clés" (Cap. Boursière, PER,
/// Dividende, Risque visuel, Bêta, BPA), le graphique historique `fl_chart`,
/// les bulles d'aide ("?") et l'action d'achat fictif unique.
class AssetDetailScreen extends StatefulWidget {
  final Asset asset;

  const AssetDetailScreen({
    super.key,
    required this.asset,
  });

  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends State<AssetDetailScreen> {
  void _openBuyModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BuyAssetSheet(
        asset: widget.asset,
        onPurchaseSuccess: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Achat fictif de ${widget.asset.symbol} effectué avec succès !'),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
        },
      ),
    );
  }

  /// Construit la jauge visuelle à 5 capsules pour le Niveau de Risque
  Widget _buildRiskGauge(int riskLevel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: List.generate(5, (index) {
            final isFilled = index < riskLevel;
            return Expanded(
              child: Container(
                height: 10,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isFilled ? const Color(0xFFF97316) : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Text(
          _getRiskLabel(riskLevel),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  String _getRiskLabel(int level) {
    switch (level) {
      case 1:
        return '1/5 - Très faible';
      case 2:
        return '2/5 - Modéré';
      case 3:
        return '3/5 - Moyen';
      case 4:
        return '4/5 - Élevé';
      case 5:
      default:
        return '5/5 - Très élevé';
    }
  }

  /// Carte individuelle pour la grille "Statistiques Clés"
  Widget _buildStatCard({
    required String title,
    required String helpTerm,
    Widget? customContent,
    String? valueText,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // En-tête de la carte : Titre + Bulle d'aide ?
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              MarketTermHelpButton(
                term: helpTerm,
                iconSize: 16,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Contenu de la carte : Texte en gras ou composant personnalisé (jauge)
          if (customContent != null)
            customContent
          else
            Text(
              valueText ?? '-',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asset = widget.asset;
    final double change = asset.dailyChangePercentage;
    final bool isPositive = change >= 0;
    final Color changeColor = isPositive ? AppTheme.gainColor : AppTheme.lossColor;

    // Récupération des données OHLCV
    double openPrice = 0.0;
    double highPrice = 0.0;
    double lowPrice = 0.0;
    int volume = 0;

    if (asset.timeSeries.isNotEmpty) {
      final latestPoint = asset.timeSeries.values.first;
      openPrice = latestPoint.open;
      highPrice = latestPoint.high;
      lowPrice = latestPoint.low;
      volume = latestPoint.volume;
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          asset.symbol,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          MarketTermHelpButton(
            term: asset.type,
            iconSize: 22,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. En-tête : Nom, Type & Badge Statut
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          asset.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.mint.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                asset.type,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: asset.marketOpen
                                    ? Colors.green.shade50
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: asset.marketOpen
                                      ? Colors.green.shade200
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 8,
                                    color: asset.marketOpen ? AppTheme.gainColor : Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    asset.marketOpen ? 'Marché Ouvert' : 'Marché Fermé',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: asset.marketOpen
                                          ? Colors.green.shade800
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const MarketTermHelpButton(
                                    term: 'Ouverture du marché',
                                    iconSize: 14,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2. Prix Actuel & Variation
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cours Actuel (EUR)',
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Formatters.formatCurrency(asset.currentPrice),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                        if (asset.originalCurrency != 'EUR') ...[
                          const SizedBox(height: 2),
                          Text(
                            'Origine : ${asset.originalPrice.toStringAsFixed(2)} ${asset.originalCurrency}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: changeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isPositive ? Icons.trending_up : Icons.trending_down,
                                color: changeColor,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                Formatters.formatPercentage(change),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: changeColor,
                                ),
                              ),
                              const MarketTermHelpButton(
                                term: 'Variation %',
                                iconSize: 14,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Section Statistiques Clés (Grille 2 colonnes comme sur l'image)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Statistiques Clés',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  MarketTermHelpButton(
                    term: 'Cap. Boursière',
                    iconSize: 18,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard(
                    title: 'Cap. Boursière',
                    helpTerm: 'Cap. Boursière',
                    valueText: asset.displayMarketCap,
                  ),
                  _buildStatCard(
                    title: 'PER (P/E)',
                    helpTerm: 'PER (P/E)',
                    valueText: asset.displayPeRatio.toStringAsFixed(1),
                  ),
                  _buildStatCard(
                    title: 'Dividende',
                    helpTerm: 'Dividende',
                    valueText: '${asset.displayDividendYield.toStringAsFixed(2)}%',
                  ),
                  _buildStatCard(
                    title: 'Risque',
                    helpTerm: 'Risque',
                    customContent: _buildRiskGauge(asset.displayRiskLevel),
                  ),
                  _buildStatCard(
                    title: 'Bêta (Volatilité)',
                    helpTerm: 'Bêta',
                    valueText: asset.displayBeta.toStringAsFixed(2),
                  ),
                  _buildStatCard(
                    title: 'BPA (EPS)',
                    helpTerm: 'BPA (EPS)',
                    valueText: Formatters.formatCurrency(asset.displayEps),
                  ),
                  _buildStatCard(
                    title: 'Plus haut 52 sem.',
                    helpTerm: 'Plus haut 52 sem.',
                    valueText: Formatters.formatCurrency(asset.displayHigh52Week),
                  ),
                  _buildStatCard(
                    title: 'Plus bas 52 sem.',
                    helpTerm: 'Plus bas 52 sem.',
                    valueText: Formatters.formatCurrency(asset.displayLow52Week),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 4. Graphique Historique Interactif fl_chart
              const Text(
                'Historique des cours',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              AssetHistoricalChart(
                timeSeries: asset.timeSeries,
                height: 250,
              ),
              const SizedBox(height: 24),

              // 5. Métriques Générales de Séance (Ouverture, Plus Haut, Volume)
              const Text(
                'Séance et Échanges',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildMetricRow('Ouverture', openPrice > 0 ? Formatters.formatCurrency(openPrice) : 'N/A'),
                    const Divider(height: 20),
                    _buildMetricRow('Plus haut jour', highPrice > 0 ? Formatters.formatCurrency(highPrice) : 'N/A'),
                    const Divider(height: 20),
                    _buildMetricRow('Plus bas jour', lowPrice > 0 ? Formatters.formatCurrency(lowPrice) : 'N/A'),
                    const Divider(height: 20),
                    _buildMetricRow(
                      'Volume 24h',
                      volume > 0 ? '$volume titres' : 'Non spécifié',
                      helpTerm: 'Volume',
                    ),
                    const Divider(height: 20),
                    _buildMetricRow('Fuseau horaire', asset.timezone),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 6. Description de l'actif
              if (asset.description.isNotEmpty) ...[
                const Text(
                  'À propos de l\'actif',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    asset.description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // 7. Espace sous défilement pour le bouton fixe d'achat
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      // Bouton d'achat fixe en bas de l'écran
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              key: const Key('buy_asset_detail_button'),
              onPressed: _openBuyModal,
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text(
                'Acheter cet actif (Fictif)',
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
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, {String? helpTerm}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            if (helpTerm != null) ...[
              const SizedBox(width: 4),
              MarketTermHelpButton(term: helpTerm, iconSize: 16),
            ],
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
