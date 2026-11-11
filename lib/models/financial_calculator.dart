// [AI-GENERATED] Issue #5 & #6, Agent, 2025-02-23
import 'dart:math';

import 'asset.dart';
import 'achievement.dart';
import 'leaderboard_entry.dart';

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

    return {'totalInvested': totalInvested, 'finalValue': finalValue};
  }

  /// Simule un investissement mensuel programmé (DCA - Dollar-Cost Averaging) avec intérêts composés.
  ///
  /// [monthlyAmount] est le montant versé chaque mois en euros.
  /// [annualReturnRate] est le taux de rendement annuel attendu en pourcentage (ex: 7.0 pour 7%).
  /// [durationYears] est la durée totale de l'investissement en années.
  ///
  /// Retourne une [Map] avec les clés :
  /// - `'totalInvested'` : le capital total versé sur la période.
  /// - `'finalValue'` : la valeur finale estimée du portefeuille.
  /// - `'totalGains'` : le montant des gains d'intérêts générés (`finalValue - totalInvested`).
  static Map<String, double> simulateDcaCompound({
    required double monthlyAmount,
    required double annualReturnRate,
    required int durationYears,
  }) {
    if (monthlyAmount <= 0.0 || durationYears <= 0) {
      return {'totalInvested': 0.0, 'finalValue': 0.0, 'totalGains': 0.0};
    }

    final int totalMonths = durationYears * 12;
    final double totalInvested = monthlyAmount * totalMonths;

    if (annualReturnRate == 0.0) {
      return {
        'totalInvested': totalInvested,
        'finalValue': totalInvested,
        'totalGains': 0.0,
      };
    }

    final double monthlyRate = (annualReturnRate / 100) / 12;
    double finalValue = 0.0;

    for (int month = 0; month < totalMonths; month++) {
      finalValue = finalValue * (1 + monthlyRate) + monthlyAmount;
    }

    final double totalGains = finalValue - totalInvested;

    return {
      'totalInvested': totalInvested,
      'finalValue': finalValue,
      'totalGains': totalGains,
    };
  }

  /// Simule une projection DCA réaliste générant 3 scénarios (Défavorable, Neutre, Favorable)
  /// et les données annuelles pour tracer un cône de projection.
  static Map<String, dynamic> simulateDcaProjection({
    required double monthlyAmount,
    required double annualReturnRate,
    required int durationYears,
    double beta = 1.0,
  }) {
    if (monthlyAmount <= 0.0 || durationYears <= 0) {
      return {
        'totalInvested': 0.0,
        'neutralValue': 0.0,
        'pessimisticValue': 0.0,
        'optimisticValue': 0.0,
        'yearlyData': <Map<String, double>>[],
      };
    }

    // Volatilité de marché estimée à 15% / an, ajustée par le Bêta de l'actif
    final double volatility = 15.0 * (beta > 0.0 ? beta : 1.0);

    // Estimation d'écart-type de projection sur le rendement
    final double pessimisticRate = annualReturnRate - (volatility * 0.4);
    final double optimisticRate = annualReturnRate + (volatility * 0.4);

    final double neutralMonthlyRate = (annualReturnRate / 100) / 12;
    final double pessimisticMonthlyRate = (pessimisticRate / 100) / 12;
    final double optimisticMonthlyRate = (optimisticRate / 100) / 12;

    List<Map<String, double>> yearlyData = [];

    double neutralValue = 0.0;
    double pessimisticValue = 0.0;
    double optimisticValue = 0.0;
    double invested = 0.0;

    yearlyData.add({
      'year': 0.0,
      'invested': 0.0,
      'neutral': 0.0,
      'pessimistic': 0.0,
      'optimistic': 0.0,
    });

    for (int y = 1; y <= durationYears; y++) {
      for (int m = 0; m < 12; m++) {
        neutralValue = neutralValue * (1 + neutralMonthlyRate) + monthlyAmount;
        pessimisticValue =
            pessimisticValue * (1 + pessimisticMonthlyRate) + monthlyAmount;
        optimisticValue =
            optimisticValue * (1 + optimisticMonthlyRate) + monthlyAmount;
        invested += monthlyAmount;
      }
      yearlyData.add({
        'year': y.toDouble(),
        'invested': invested,
        'neutral': neutralValue,
        'pessimistic': pessimisticValue,
        'optimistic': optimisticValue,
      });
    }

    return {
      'totalInvested': invested,
      'neutralValue': neutralValue,
      'pessimisticValue': pessimisticValue,
      'optimisticValue': optimisticValue,
      'yearlyData': yearlyData,
    };
  }

  /// Calcule le taux de rendement annuel composé (CAGR - Compound Annual Growth Rate) d'un actif
  /// à partir de son historique de prix réel (`asset.timeSeries`).
  ///
  /// Si l'historique contient au moins 2 points séparés dans le temps, calcule :
  /// `((Prix_final / Prix_initial) ^ (1 / Années)) - 1`
  ///
  /// Si l'historique est insuffisant ou indisponible, retourne une valeur de référence historique réaliste.
  static double calculateAssetAnnualizedReturn(Asset asset) {
    if (asset.timeSeries.length >= 2) {
      final entries = asset.timeSeries.entries
          .map((e) {
            final date = DateTime.tryParse(e.key);
            return MapEntry(date, e.value);
          })
          .where((e) => e.key != null)
          .toList();

      if (entries.length >= 2) {
        entries.sort((a, b) => a.key!.compareTo(b.key!));

        final firstEntry = entries.first;
        final lastEntry = entries.last;

        final startPrice = firstEntry.value.close;
        final endPrice = lastEntry.value.close;

        final daysDiff = lastEntry.key!.difference(firstEntry.key!).inDays;

        if (startPrice > 0.0 && endPrice > 0.0 && daysDiff >= 30) {
          final double years = daysDiff / 365.25;
          final double cagr = (pow(endPrice / startPrice, 1 / years) - 1) * 100;
          if (!cagr.isNaN && !cagr.isInfinite && cagr > -50.0 && cagr < 100.0) {
            return double.parse(cagr.toStringAsFixed(1));
          }
        }
      }
    }

    // 2. Calcul basé sur le plus bas 52 semaines si présent
    if (asset.low52Week != null &&
        asset.low52Week! > 0.0 &&
        asset.currentPrice > 0.0) {
      final double gainRatio =
          ((asset.currentPrice - asset.low52Week!) / asset.low52Week!) * 100;
      if (gainRatio > 0.0) {
        final double estimatedRate = gainRatio.clamp(2.0, 25.0);
        return double.parse(estimatedRate.toStringAsFixed(1));
      }
    }

    // 3. Calcul annualisé basé sur la variation quotidienne (%)
    final double change = asset.dailyChangePercentage;
    if (change != 0.0) {
      final double estimatedRate = (7.0 + (change * 1.5)).clamp(1.0, 25.0);
      return double.parse(estimatedRate.toStringAsFixed(1));
    }

    // 4. Taux historiques de référence si l'historique disponible est trop court
    final symbol = asset.symbol.toUpperCase();
    if (symbol == 'AAPL') return 12.0;
    if (symbol == 'MSFT') return 10.0;
    if (symbol == 'NVDA') return 18.0;
    if (symbol == 'AMZN') return 11.0;
    if (symbol == 'SPY' || symbol == 'S&P 500') return 7.0;
    if (symbol == 'QQQ') return 11.0;
    if (asset.type.toUpperCase() == 'ETF') return 7.5;

    return 8.0;
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

  /// Calcule le gain d'XP attribué lors de l'achat d'un actif.
  ///
  /// Forfait de +50 XP par achat d'actif réussi pour valoriser le passage à l'action.
  static int calculateBuyXp() {
    return 50;
  }

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

  /// Génère un classement (Leaderboard) déterministe en intégrant l'utilisateur parmi des PNJ (personnages non joueurs).
  /// Les PNJ sont générés dynamiquement, mais de manière déterministe.
  static List<LeaderboardEntry> generateMockLeaderboardEntries({
    required int userXp,
    required double userPortfolioValue,
    required double userPerformancePercentage,
    LeaderboardSortCriteria sortBy = LeaderboardSortCriteria.xp,
    List<LeaderboardEntry> realUsers = const [],
  }) {
    final entries = <LeaderboardEntry>[];

    if (realUsers.isNotEmpty) {
      entries.addAll(realUsers);
    } else {
      // Ajout de l'utilisateur courant par défaut
      final userLevel = calculateLevel(userXp);
      entries.add(
        LeaderboardEntry(
          rank: 0,
          name: 'Vous',
          avatarInitials: 'VO',
          level: userLevel,
          xp: userXp,
          portfolioValue: userPortfolioValue,
          performancePercentage: userPerformancePercentage,
          isCurrentUser: true,
        ),
      );
    }

    // Ajout de compétiteurs fictifs PNJ
    final npcs = [
      LeaderboardEntry(
        rank: 0,
        name: 'Warren B.',
        avatarInitials: 'WB',
        level: calculateLevel(15000),
        xp: 15000,
        portfolioValue: 120500.0,
        performancePercentage: 22.4,
      ),
      LeaderboardEntry(
        rank: 0,
        name: 'Charlie M.',
        avatarInitials: 'CM',
        level: calculateLevel(12000),
        xp: 12000,
        portfolioValue: 95400.0,
        performancePercentage: 18.2,
      ),
      LeaderboardEntry(
        rank: 0,
        name: 'Peter L.',
        avatarInitials: 'PL',
        level: calculateLevel(8500),
        xp: 8500,
        portfolioValue: 42000.0,
        performancePercentage: 15.6,
      ),
      LeaderboardEntry(
        rank: 0,
        name: 'Alice S.',
        avatarInitials: 'AS',
        level: calculateLevel(4200),
        xp: 4200,
        portfolioValue: 18000.0,
        performancePercentage: 9.8,
      ),
      LeaderboardEntry(
        rank: 0,
        name: 'Bob J.',
        avatarInitials: 'BJ',
        level: calculateLevel(1500),
        xp: 1500,
        portfolioValue: 4500.0,
        performancePercentage: 4.2,
      ),
      LeaderboardEntry(
        rank: 0,
        name: 'Tom D.',
        avatarInitials: 'TD',
        level: calculateLevel(500),
        xp: 500,
        portfolioValue: 1200.0,
        performancePercentage: 1.5,
      ),
    ];

    for (var npc in npcs) {
      if (!entries.any((e) => e.name.toLowerCase() == npc.name.toLowerCase())) {
        entries.add(npc);
      }
    }

    // Tri par le critère sélectionné (ordre décroissant)
    entries.sort((a, b) {
      switch (sortBy) {
        case LeaderboardSortCriteria.xp:
          return b.xp.compareTo(a.xp);
        case LeaderboardSortCriteria.portfolioValue:
          return b.portfolioValue.compareTo(a.portfolioValue);
        case LeaderboardSortCriteria.performance:
          return b.performancePercentage.compareTo(a.performancePercentage);
      }
    });

    // Affectation du rang
    final rankedEntries = <LeaderboardEntry>[];
    for (int i = 0; i < entries.length; i++) {
      final old = entries[i];
      rankedEntries.add(
        LeaderboardEntry(
          rank: i + 1,
          name: old.name,
          avatarInitials: old.avatarInitials,
          level: old.level,
          xp: old.xp,
          portfolioValue: old.portfolioValue,
          performancePercentage: old.performancePercentage,
          isCurrentUser: old.isCurrentUser,
        ),
      );
    }

    return rankedEntries;
  }

  /// Vérifie si l'utilisateur remplit les conditions pour débloquer de nouveaux succès.
  /// Prends l'état actuel (XP, portefeuille, etc.) et retourne la liste des ID des succès nouvellement débloqués.
  static List<String> checkAchievementUnlock({
    required List<Achievement> achievements,
    required int userXp,
    required double portfolioValue,
    required double totalInvested,
    required int assetCount,
    required bool hasSimulatedDCA,
    required bool readLexicon,
  }) {
    final newlyUnlockedIds = <String>[];

    for (var ach in achievements) {
      if (ach.isUnlocked) continue; // Déjà débloqué

      bool unlock = false;
      switch (ach.id) {
        case 'first_step':
          unlock =
              true; // Débloqué par défaut au lancement si présent non débloqué
          break;
        case 'lynx_eye':
          unlock = assetCount >= 5; // 5 actifs consultés/possédés
          break;
        case 'market_linguist':
          unlock = readLexicon;
          break;
        case 'dca_pioneer':
          unlock = hasSimulatedDCA;
          break;
        case 'diversified_investor':
          unlock = assetCount >= 3; // N'exige que d'avoir au moins 3 actifs différents en portefeuille
          break;
        case 'cap_5k':
          unlock = portfolioValue >= 5000.0;
          break;
        case 'master_profit':
          unlock = (portfolioValue - totalInvested) >= 1000.0;
          break;
        case 'golden_patience':
          unlock = userXp >= 10000;
          break;
      }

      if (unlock) {
        newlyUnlockedIds.add(ach.id);
      }
    }

    return newlyUnlockedIds;
  }
}
