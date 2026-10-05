// [AI-GENERATED] Setup, Agent, 2025-02-23

/// Utilitaires de formatage pour l'affichage des valeurs financières.
class Formatters {
  /// Formate un montant en devise de manière simple (ex: 1 234,56 €).
  static String formatCurrency(double amount) {
    String formatted = amount.toStringAsFixed(2);
    // Remplacement du point par la virgule pour le format français
    formatted = formatted.replaceAll('.', ',');
    
    // Ajout d'espaces pour les milliers (basique)
    final parts = formatted.split(',');
    String integerPart = parts[0];
    
    // Gérer les montants négatifs
    bool isNegative = integerPart.startsWith('-');
    if (isNegative) {
      integerPart = integerPart.substring(1);
    }

    String result = '';
    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        result += ' ';
      }
      result += integerPart[i];
    }
    
    if (isNegative) {
      result = '-$result';
    }

    return '$result,${parts[1]} €';
  }

  /// Formate un pourcentage avec son signe (ex: +12,34 % ou -5,67 %).
  static String formatPercentage(double percentage) {
    String formatted = percentage.toStringAsFixed(2).replaceAll('.', ',');
    if (percentage > 0) {
      return '+$formatted %';
    }
    return '$formatted %';
  }
}
