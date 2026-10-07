// [AI-GENERATED] Phase 2, Agent, 2025-02-23
import 'package:flutter/material.dart';
import '../../models/asset.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatters.dart';

/// Section 2 du tableau de bord ("À surveiller") sous forme de liste défilante horizontale.
///
/// Affiche une collection de cartes compactes d'actifs avec une distinction visuelle
/// marquée pour les ETF (Fond indiciel coté) ainsi que le badge réel de plus-value/moins-value (%).
class AssetGridSection extends StatelessWidget {
  final List<Asset> assets;
  final Function(Asset asset) onAssetSelected;

  const AssetGridSection({
    super.key,
    required this.assets,
    required this.onAssetSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'À surveiller',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${assets.length} actifs',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 175,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: assets.length,
            itemBuilder: (context, index) {
              final asset = assets[index];
              final bool isEtf = asset.type.toUpperCase() == 'ETF';

              // Récupération de la variation (%) réelle de l'actif
              final double variation = asset.dailyChangePercentage;
              final bool isGain = variation >= 0;
              final Color varColor = isGain ? AppTheme.gainColor : AppTheme.lossColor;

              return Container(
                width: 170,
                margin: const EdgeInsets.only(right: 12),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  elevation: 0,
                  child: InkWell(
                    onTap: () => onAssetSelected(asset),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Ligne 1 : Symbole & Badge (ETF / Action)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  asset.symbol,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),

                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isEtf
                                      ? Colors.purple.shade50
                                      : Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isEtf ? 'ETF' : 'Action',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isEtf
                                        ? Colors.purple.shade700
                                        : Colors.blue.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Ligne 2 : Nom de l'actif
                          Text(
                            asset.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),

                          // Ligne 3 : Badge Plus-value / Moins-value (%)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: varColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              Formatters.formatPercentage(variation),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: varColor,
                              ),
                            ),
                          ),

                          // Ligne 4 : Prix & Bouton d'ajout d'achat
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        Formatters.formatCurrency(asset.currentPrice),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    if (asset.originalCurrency != 'EUR') ...[
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          '(${asset.originalPrice.toStringAsFixed(2)} ${asset.originalCurrency})',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppTheme.mint.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add_rounded,
                                  size: 18,
                                  color: AppTheme.primaryColor,
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
            },
          ),
        ),
      ],
    );
  }
}
