// [AI-GENERATED] Issue #0, Agent, 2025-02-23
import 'package:flutter/material.dart';

import '../../utils/app_theme.dart';
import '../../utils/formatters.dart';

/// Widget textuel intelligent pour afficher une performance.
///
/// Affiche la valeur passée en pourcentage formatée (par ex. +15,00 % ou -10,00 %).
/// La couleur du texte change automatiquement selon la valeur :
/// - Vert (`AppTheme.gainColor`) pour une performance positive ou nulle.
/// - Rouge (`AppTheme.lossColor`) pour une performance négative.
class PerformanceText extends StatelessWidget {
  /// La valeur de performance (en pourcentage ou valeur brute)
  final double value;

  /// Style de texte de base (la couleur sera écrasée)
  final TextStyle? style;

  /// Si vrai, formate la valeur comme une devise plutôt qu'un pourcentage
  final bool isCurrency;

  const PerformanceText({
    super.key,
    required this.value,
    this.style,
    this.isCurrency = false,
  });

  @override
  Widget build(BuildContext context) {
    // Choisir la couleur basée sur la valeur numérique
    final Color textColor = value >= 0
        ? AppTheme.gainColor
        : AppTheme.lossColor;

    // Formater la valeur avec la classe utilitaire appropriée
    final String formattedText = isCurrency
        ? Formatters.formatCurrency(value)
        : Formatters.formatPercentage(value);

    // Appliquer la couleur sur le style fourni, ou utiliser un style par défaut
    final textStyle = (style ?? const TextStyle(fontWeight: FontWeight.bold))
        .copyWith(color: textColor);

    return Text(formattedText, style: textStyle);
  }
}
