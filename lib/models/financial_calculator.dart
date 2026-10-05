// [AI-GENERATED] Setup, Agent, 2025-02-23

/// Classe utilitaire contenant exclusivement des fonctions pures pour les calculs financiers.
///
/// Ces fonctions ne dépendent d'aucun état externe ni de l'interface graphique.
/// Elles répondent au besoin de séparer la logique métier pure du reste de l'application,
/// conformément à l'architecture demandée.
class FinancialCalculator {
  /// Calcule la performance globale d'un investissement en pourcentage.
  /// 
  /// Utilise la formule : `((currentValue - initialValue) / initialValue) * 100`
  /// 
  /// Gère le cas de division par zéro en retournant 0.0 si [initialValue] est 0.0.
  static double calculatePerformance({
    required double initialValue,
    required double currentValue,
  }) {
    if (initialValue == 0.0) return 0.0;
    return ((currentValue - initialValue) / initialValue) * 100;
  }

  /// Calcule la plus-value ou moins-value absolue (en devise).
  ///
  /// Utilise la formule : `currentValue - investedAmount`
  static double calculateCapitalGain({
    required double investedAmount,
    required double currentValue,
  }) {
    return currentValue - investedAmount;
  }

  /// Calcule la valeur totale d'un portefeuille à l'instant T.
  ///
  /// [positions] doit être une liste de Maps contenant au moins les clés
  /// `'quantity'` (double) et `'currentPrice'` (double).
  /// 
  /// Itère sur chaque ligne du portefeuille et additionne `quantité * prix_actuel`.
  static double calculatePortfolioValue(List<Map<String, double>> positions) {
    double total = 0.0;
    for (var position in positions) {
      final quantity = position['quantity'] ?? 0.0;
      final currentPrice = position['currentPrice'] ?? 0.0;
      total += quantity * currentPrice;
    }
    return total;
  }

  /// Calcule le montant total investi dans un portefeuille.
  ///
  /// [positions] doit être une liste de Maps contenant au moins les clés
  /// `'quantity'` (double) et `'averagePurchasePrice'` (double).
  /// 
  /// Itère sur chaque ligne du portefeuille et additionne `quantité * prix_achat_moyen`.
  static double calculateTotalInvested(List<Map<String, double>> positions) {
    double total = 0.0;
    for (var position in positions) {
      final quantity = position['quantity'] ?? 0.0;
      final averagePurchasePrice = position['averagePurchasePrice'] ?? 0.0;
      total += quantity * averagePurchasePrice;
    }
    return total;
  }

  /// Simule un investissement régulier (Dollar-Cost Averaging - DCA).
  ///
  /// [periodicInvestment] représente le montant investi à chaque période.
  /// [pricesAtInvestmentPeriods] contient la liste des prix de l'actif à chaque moment d'investissement.
  /// Le dernier prix de la liste est considéré comme le prix final pour valoriser le portefeuille.
  ///
  /// Retourne une Map contenant `'totalInvested'` (le capital total engagé)
  /// et `'finalValue'` (la valeur du portefeuille à la fin de la simulation).
  static Map<String, double> simulateDCA({
    required double periodicInvestment,
    required List<double> pricesAtInvestmentPeriods,
  }) {
    if (pricesAtInvestmentPeriods.isEmpty || periodicInvestment <= 0.0) {
      return {'totalInvested': 0.0, 'finalValue': 0.0};
    }

    double totalShares = 0.0;
    double totalInvested = 0.0;

    for (var price in pricesAtInvestmentPeriods) {
      if (price > 0.0) {
        totalShares += periodicInvestment / price;
        totalInvested += periodicInvestment;
      }
    }

    final finalPrice = pricesAtInvestmentPeriods.last;
    final finalValue = totalShares * finalPrice;

    return {
      'totalInvested': totalInvested,
      'finalValue': finalValue,
    };
  }
}
