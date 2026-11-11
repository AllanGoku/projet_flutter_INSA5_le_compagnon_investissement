// [AI-GENERATED] Issue #5, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';

import '../../models/user_profile.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatters.dart';

/// Widget d'en-tête affichant la synthèse globale du portefeuille fictif et des liquidités.
///
/// Intègre [AnimatedFlipCounter] pour basculer de manière très fluide et animée
/// entre l'affichage de la plus/moins-value en pourcentage (%) et en euros (€)
/// et pour animer le compteur des liquidités disponibles.
class FlipGainCounter extends StatefulWidget {
  final double totalValue;
  final double capitalGain;
  final double performancePercentage;
  final double cashBalance;
  final String userName;
  final UserProfile? user;
  final VoidCallback? onProfileTap;

  const FlipGainCounter({
    super.key,
    required this.totalValue,
    required this.capitalGain,
    required this.performancePercentage,
    this.cashBalance = 1000.0,
    this.userName = 'Novice',
    this.user,
    this.onProfileTap,
  });

  @override
  State<FlipGainCounter> createState() => _FlipGainCounterState();
}

class _FlipGainCounterState extends State<FlipGainCounter> {
  /// Indique si la pilule de gain affiche le pourcentage (true) ou le montant en euros (false).
  bool _showPercentage = true;

  String get _initials {
    if (widget.user != null) {
      final first = widget.user!.firstName.trim();
      final last = widget.user!.lastName.trim();
      String result = '';
      if (first.isNotEmpty) result += first[0].toUpperCase();
      if (last.isNotEmpty) result += last[0].toUpperCase();
      if (result.isNotEmpty) return result;
    }
    if (widget.userName.isNotEmpty) {
      return widget.userName[0].toUpperCase();
    }
    return 'N';
  }

  String get _displayName {
    if (widget.user != null && widget.user!.firstName.trim().isNotEmpty) {
      return widget.user!.firstName.trim();
    }
    return widget.userName;
  }

  void _toggleDisplay() {
    setState(() {
      _showPercentage = !_showPercentage;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isGain = widget.capitalGain >= 0;
    final Color gainLossColor = isGain
        ? AppTheme.gainColor
        : AppTheme.lossColor;
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
      padding: const EdgeInsets.only(top: 48, left: 20, right: 20, bottom: 24),
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
                    'Bonjour, $_displayName',
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
              InkWell(
                onTap: widget.onProfileTap,
                borderRadius: BorderRadius.circular(21),
                child: CircleAvatar(
                  radius: 21,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(
                    _initials,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Valeur totale et pilule de gain animée
          Text(
            'Valeur des Actifs',
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: pillBgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isGain
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        size: 14,
                        color: gainLossColor,
                      ),
                      const SizedBox(width: 4),
                      AnimatedFlipCounter(
                        value: _showPercentage
                            ? widget.performancePercentage
                            : widget.capitalGain,
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
          const SizedBox(height: 12),

          // Badge Liquidités disponibles avec compteur animé
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.8)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 15,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 6),
                Text(
                  'Liquidités : ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                AnimatedFlipCounter(
                  value: widget.cashBalance,
                  suffix: ' €',
                  fractionDigits: 2,
                  thousandSeparator: ' ',
                  duration: const Duration(milliseconds: 500),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
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
