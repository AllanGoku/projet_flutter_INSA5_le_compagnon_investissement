// [AI-GENERATED] Phase 3, Agent, 2025-02-23
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/asset.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatters.dart';
import 'market_term_help_button.dart';

/// Carte d'actif avec animation de retournement 3D (Flip Card) au tap.
///
/// Recto : Vue synthétique de l'actif (nom, symbole, prix, variation %).
/// Verso : Métriques clés approfondies et bouton d'action "Voir les détails".
/// Séparation UX : Un tap n'importe où sur la carte déclenche le retournement 3D
/// sans déclencher la procédure d'achat fictif.
class InteractiveFlipAssetCard extends StatefulWidget {
  final Asset asset;

  /// Callback exécuté au clic sur le bouton "Voir les détails" au verso.
  final VoidCallback? onDetailPressed;

  /// Callback optionnel exécuté au clic sur le bouton d'achat dédié.
  final VoidCallback? onBuyPressed;

  const InteractiveFlipAssetCard({
    super.key,
    required this.asset,
    this.onDetailPressed,
    this.onBuyPressed,
  });

  @override
  State<InteractiveFlipAssetCard> createState() => _InteractiveFlipAssetCardState();
}

class _InteractiveFlipAssetCardState extends State<InteractiveFlipAssetCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Inverse la carte avec une rotation 3D fluide à 180 degrés.
  void _flipCard() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _isFront = !_isFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: Key('flip_card_gesture_${widget.asset.symbol}'),
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final double angle = _animation.value * math.pi;
          final bool isFrontVisible = angle < math.pi / 2;

          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Effet de perspective 3D
              ..rotateY(angle),
            alignment: Alignment.center,
            child: isFrontVisible
                ? _buildFrontCard(context)
                : Transform(
                    transform: Matrix4.identity()..rotateY(math.pi), // Évite l'effet miroir au verso
                    alignment: Alignment.center,
                    child: _buildBackCard(context),
                  ),
          );
        },
      ),
    );
  }

  /// Visuel Recto de la carte
  Widget _buildFrontCard(BuildContext context) {
    final double change = widget.asset.dailyChangePercentage;
    final bool isPositive = change >= 0;
    final Color changeColor = isPositive ? AppTheme.gainColor : AppTheme.lossColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ligne d'en-tête (Symbole & Type)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.mint.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  widget.asset.symbol,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                    fontSize: 13,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.asset.type,
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Nom de l'actif
          Text(
            widget.asset.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          // Prix & Variation %
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Formatters.formatCurrency(widget.asset.currentPrice),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: changeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      size: 16,
                      color: changeColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      Formatters.formatPercentage(change),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: changeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Indication visuelle de retournement 3D
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.flip_camera_android_rounded, size: 14, color: Colors.grey.shade400),
              const SizedBox(width: 6),
              Text(
                'Touchez pour retourner 3D',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Visuel Verso de la carte (Informations approfondies & Action "Voir les détails")
  Widget _buildBackCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F8), // Fond différencié pour le verso
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.azure.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Aperçu rapide',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondaryColor,
                ),
              ),
              MarketTermHelpButton(term: widget.asset.type),
            ],
          ),
          const SizedBox(height: 8),

          // Ligne Statut marché
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('Marché : ', style: TextStyle(fontSize: 12, color: Colors.black54)),
                  MarketTermHelpButton(term: 'Ouverture du marché', iconSize: 14),
                ],
              ),
              Text(
                widget.asset.marketOpen ? 'Ouvert' : 'Fermé',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: widget.asset.marketOpen ? AppTheme.gainColor : Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Devise d'origine & Prix
          if (widget.asset.originalCurrency != 'EUR')
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Prix origine : ', style: TextStyle(fontSize: 12, color: Colors.black54)),
                Text(
                  '${widget.asset.originalPrice.toStringAsFixed(2)} ${widget.asset.originalCurrency}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
              ],
            ),
          const SizedBox(height: 4),

          // Fuseau Horaire
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Zone : ', style: TextStyle(fontSize: 12, color: Colors.black54)),
              Text(
                widget.asset.timezone,
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Boutons d'action au verso
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  key: Key('flip_card_detail_button_${widget.asset.symbol}'),
                  onPressed: widget.onDetailPressed,
                  icon: const Icon(Icons.analytics_outlined, size: 16),
                  label: const Text('Voir les détails', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              if (widget.onBuyPressed != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  key: Key('flip_card_buy_button_${widget.asset.symbol}'),
                  onPressed: widget.onBuyPressed,
                  icon: const Icon(Icons.add_shopping_cart_rounded, color: AppTheme.primaryColor),
                  tooltip: 'Acheter cet actif',
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.mint.withOpacity(0.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
