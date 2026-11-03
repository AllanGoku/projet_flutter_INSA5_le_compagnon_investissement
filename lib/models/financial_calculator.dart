// [AI-GENERATED] Issue #5, Agent, 2025-02-23

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

  /// Calcule la plus-value ou moins-value réalisée lors de la revente d'un actif.
  ///
  /// Utilise la formule : `(sellPrice - averagePurchasePrice) * quantity`
  static double calculateRealizedGain({
    required double sellPrice,
    required double averagePurchasePrice,
    required double quantity,
  }) {
    return (sellPrice - averagePurchasePrice) * quantity;
  }

  /// Calcule le pourcentage de répartition (allocation) d'une position par rapport à la valeur globale du portefeuille.
  ///
  /// Utilise la formule : `(positionValue / totalPortfolioValue) * 100`
  /// Retourne 0.0 si [totalPortfolioValue] est inférieur ou égal à 0.
  static double calculateAllocationPercentage({
    required double positionValue,
    required double totalPortfolioValue,
  }) {
    if (totalPortfolioValue <= 0.0) return 0.0;
    return (positionValue / totalPortfolioValue) * 100;
  }

  // --- Phase 5: Fonctions de Gamification et XP ---

  /// Calcule le gain d'XP suite à une revente d'actif.
  ///
  /// L'XP gagné est indexé sur la performance relative (en %) multipliée par la durée de détention.
  /// Si l'investissement est en perte (performance <= 0), retourne un minimum forfaitaire pour encourager l'action.
  static int calculateSaleXp({
    required double performancePercentage,
    required Duration holdingDuration,
  }) {
    if (performancePercentage <= 0.0) return 10;
    
    // Au minimum 1 jour de détention pour le calcul
    final int days = holdingDuration.inDays < 1 ? 1 : holdingDuration.inDays;
    
    // L'XP = Performance (%) * Nombre de jours.
    // Cela valorise le "Long-Term Investing".
    return (performancePercentage * days).round();
  }

  /// Calcule le bonus d'XP quotidien basé sur la série de connexions (streak).
  ///
  /// 20 XP par jour.
  /// Bonus de 50 XP au 7ème jour (7j).
  /// Bonus de 200 XP au 30ème jour (30j).
  static int calculateStreakBonus(int streakCount) {
    if (streakCount > 0 && streakCount % 30 == 0) return 200;
    if (streakCount > 0 && streakCount % 7 == 0) return 50;
    return 20;
  }

  /// Détermine le niveau en fonction de l'XP total.
  ///
  /// Progression linéaire pour rester simple et prévisible: 1 niveau tous les 1000 XP.
  static int calculateLevel(int xp) {
    if (xp < 0) return 1;
    return (xp ~/ 1000) + 1;
  }

  /// Retourne un titre honorifique pédagogique basé sur le niveau.
  static String getTitleForLevel(int level) {
    if (level < 5) return "Novice";
    if (level < 10) return "Débutant";
    if (level < 20) return "Apprenti";
    if (level < 30) return "Initié";
    if (level < 50) return "Investisseur Averti";
    if (level < 75) return "Expert";
    if (level < 100) return "Stratège";
    return "Maître de Wall Street";
  }
}
