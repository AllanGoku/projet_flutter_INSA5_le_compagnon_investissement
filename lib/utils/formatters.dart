// [AI-GENERATED] Phase 9, Agent, 2025-02-23

/// Utilitaires de formatage pour l'affichage des valeurs financières et des horodatages.
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

  /// Formate un horodatage en libellé relatif en français (ex: "À l'instant", "Il y a 5 min", "Il y a 2 h").
  static String formatRelativeTime(DateTime? dateTime) {
    if (dateTime == null) return 'Jamais';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.isNegative || difference.inSeconds < 60) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} h';
    } else {
      return 'Il y a ${difference.inDays} j';
    }
  }

  /// Formate la date de dernière mise à jour avec l'heure exacte (ex: "Mis à jour aujourd'hui à 14:32").
  static String formatLastUpdated(DateTime? dateTime) {
    if (dateTime == null) return 'Non synchronisé';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final String hourStr = dateTime.hour.toString().padLeft(2, '0');
    final String minStr = dateTime.minute.toString().padLeft(2, '0');
    final String timeStr = '$hourStr:$minStr';

    if (date == today) {
      return 'Mis à jour aujourd\'hui à $timeStr';
    } else if (date == yesterday) {
      return 'Mis à jour hier à $timeStr';
    } else {
      final String dayStr = dateTime.day.toString().padLeft(2, '0');
      final String monthStr = dateTime.month.toString().padLeft(2, '0');
      return 'Mis à jour le $dayStr/$monthStr à $timeStr';
    }
  }
}
