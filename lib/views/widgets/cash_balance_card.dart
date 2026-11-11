// [AI-GENERATED] Phase 4, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';

import '../../utils/app_theme.dart';

/// Carte présentant le solde de liquidités disponible de l'utilisateur avec animation.
///
/// Utilise [AnimatedFlipCounter] pour faire monter ou descendre les chiffres de façon
/// très fluide lors des achats (débit) et des reventes (crédit).
class CashBalanceCard extends StatelessWidget {
  final double cashBalance;

  const CashBalanceCard({super.key, required this.cashBalance});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.mint.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Liquidités disponibles',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedFlipCounter(
                  value: cashBalance,
                  suffix: ' €',
                  fractionDigits: 2,
                  thousandSeparator: ' ',
                  duration: const Duration(milliseconds: 500),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryColor,
                    letterSpacing: -0.2,
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
