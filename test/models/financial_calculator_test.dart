// [AI-GENERATED] Setup, Agent, 2025-02-23
import 'package:flutter_test/flutter_test.dart';
import 'package:le_compagnon_investissement/models/financial_calculator.dart';
import 'package:le_compagnon_investissement/models/asset.dart';
import 'package:le_compagnon_investissement/models/price_point.dart';

void main() {
  group('FinancialCalculator', () {
    group('calculatePerformance', () {
      test('should calculate correct performance percentage', () {
        final performance = FinancialCalculator.calculatePerformance(
          initialValue: 100.0,
          currentValue: 150.0,
        );
        expect(performance, closeTo(50.0, 0.001));
      });

      test('should return 0.0 when initial value is 0 (division by zero)', () {
        final performance = FinancialCalculator.calculatePerformance(
          initialValue: 0.0,
          currentValue: 150.0,
        );
        expect(performance, 0.0);
      });

      test('should calculate negative performance correctly', () {
        final performance = FinancialCalculator.calculatePerformance(
          initialValue: 200.0,
          currentValue: 150.0,
        );
        expect(performance, closeTo(-25.0, 0.001));
      });
    });

    group('calculateCapitalGain', () {
      test('should calculate positive capital gain', () {
        final gain = FinancialCalculator.calculateCapitalGain(
          investedAmount: 1000.0,
          currentValue: 1500.0,
        );
        expect(gain, closeTo(500.0, 0.001));
      });

      test('should calculate negative capital loss', () {
        final loss = FinancialCalculator.calculateCapitalGain(
          investedAmount: 1000.0,
          currentValue: 800.0,
        );
        expect(loss, closeTo(-200.0, 0.001));
      });

      test('should handle zero investment', () {
        final gain = FinancialCalculator.calculateCapitalGain(
          investedAmount: 0.0,
          currentValue: 0.0,
        );
        expect(gain, 0.0);
      });
    });

    group('calculatePortfolioValue', () {
      test('should sum up quantities multiplied by current prices', () {
        // We will represent positions simply as a list of maps for this pure calculation
        // Or directly pass a list of quantities and prices.
        final value = FinancialCalculator.calculatePortfolioValue([
          {'quantity': 10.0, 'currentPrice': 50.0}, // 500
          {'quantity': 5.0, 'currentPrice': 200.0}, // 1000
        ]);
        expect(value, closeTo(1500.0, 0.001));
      });

      test('should return 0.0 for empty portfolio', () {
        final value = FinancialCalculator.calculatePortfolioValue([]);
        expect(value, 0.0);
      });
    });

    group('calculateTotalInvested', () {
      test('should sum up quantities multiplied by average purchase price', () {
        final invested = FinancialCalculator.calculateTotalInvested([
          {'quantity': 10.0, 'averagePurchasePrice': 40.0}, // 400
          {'quantity': 5.0, 'averagePurchasePrice': 150.0}, // 750
        ]);
        expect(invested, closeTo(1150.0, 0.001));
      });

      test('should return 0.0 for empty portfolio', () {
        final invested = FinancialCalculator.calculateTotalInvested([]);
        expect(invested, 0.0);
      });
    });

    group('simulateDCA', () {
      test('should calculate final value correctly based on fixed period contributions and final price', () {
        // If we invested $100 for 10 months, total invested = 1000.
        // If we bought a total of 10 shares (average price 100), and final price is 120.
        // Value = 120 * 10 = 1200.
        // Let's make the function simpler: it takes total periods, periodic investment, 
        // average purchase price across those periods, and final asset price.
        // Actually, typical DCA simulation: 
        // given periodic amount, list of prices at each period.
        final finalValue = FinancialCalculator.simulateDCA(
          periodicInvestment: 100.0,
          pricesAtInvestmentPeriods: [100.0, 50.0, 200.0],
          // Bought: 1 share, 2 shares, 0.5 shares = 3.5 shares.
          // Total invested: 300.
          // Final price: let's say the last price in the list is the final price = 200.0
          // Final value: 3.5 * 200.0 = 700.0
        );
        expect(finalValue['totalInvested'], closeTo(300.0, 0.001));
        expect(finalValue['finalValue'], closeTo(700.0, 0.001));
      });

      test('should handle empty price list', () {
        final finalValue = FinancialCalculator.simulateDCA(
          periodicInvestment: 100.0,
          pricesAtInvestmentPeriods: [],
        );
        expect(finalValue['totalInvested'], 0.0);
        expect(finalValue['finalValue'], 0.0);
      });
      
      test('should handle zero investment', () {
        final finalValue = FinancialCalculator.simulateDCA(
          periodicInvestment: 0.0,
          pricesAtInvestmentPeriods: [100.0, 200.0],
        );
        expect(finalValue['totalInvested'], 0.0);
        expect(finalValue['finalValue'], 0.0);
      });
    });

    group('simulateDcaCompound', () {
      test('retourne des montants nuls si le montant mensuel est de 0€', () {
        final res = FinancialCalculator.simulateDcaCompound(
          monthlyAmount: 0.0,
          annualReturnRate: 7.0,
          durationYears: 10,
        );
        expect(res['totalInvested'], 0.0);
        expect(res['finalValue'], 0.0);
        expect(res['totalGains'], 0.0);
      });

      test('retourne des montants nuls si la durée est de 0 an', () {
        final res = FinancialCalculator.simulateDcaCompound(
          monthlyAmount: 100.0,
          annualReturnRate: 7.0,
          durationYears: 0,
        );
        expect(res['totalInvested'], 0.0);
        expect(res['finalValue'], 0.0);
        expect(res['totalGains'], 0.0);
      });

      test('calcule correctement avec un taux de rendement de 0%', () {
        final res = FinancialCalculator.simulateDcaCompound(
          monthlyAmount: 100.0,
          annualReturnRate: 0.0,
          durationYears: 5,
        );
        // 100 € * 12 * 5 = 6000 €
        expect(res['totalInvested'], closeTo(6000.0, 0.001));
        expect(res['finalValue'], closeTo(6000.0, 0.001));
        expect(res['totalGains'], closeTo(0.0, 0.001));
      });

      test('calcule la simulation DCA avec intérêts composés (100€/mois, 7%, 10 ans)', () {
        final res = FinancialCalculator.simulateDcaCompound(
          monthlyAmount: 100.0,
          annualReturnRate: 7.0,
          durationYears: 10,
        );
        // Total investi: 100 * 12 * 10 = 12000 €
        expect(res['totalInvested'], closeTo(12000.0, 0.001));
        // Valeur finale estimée ~ 17308.48 €
        expect(res['finalValue'], closeTo(17308.48, 1.0));
        // Gains générés ~ 5308.48 €
        expect(res['totalGains'], closeTo(5308.48, 1.0));
      });

      test('gère un rendement négatif (-2% par an)', () {
        final res = FinancialCalculator.simulateDcaCompound(
          monthlyAmount: 100.0,
          annualReturnRate: -2.0,
          durationYears: 5,
        );
        // 6000 € investis
        expect(res['totalInvested'], closeTo(6000.0, 0.001));
        expect(res['finalValue']!, lessThan(6000.0));
        expect(res['totalGains']!, lessThan(0.0));
      });
    });

    group('calculateAssetAnnualizedReturn', () {
      test('calcule le rendement annuel composé (CAGR) à partir de l\'historique des prix', () {
        // Asset avec 2 points de données séparés de 1 an exactement (100 € -> 110 €)
        final asset = Asset(
          symbol: 'TEST',
          name: 'Test Asset',
          currentPrice: 110.0,
          type: 'Stock',
          description: 'Test',
          marketOpen: true,
          timezone: 'US/Eastern',
          timeSeries: {
            '2024-01-01': PricePoint(
              open: 108.0,
              high: 111.0,
              low: 107.0,
              close: 110.0,
              volume: 1000,
            ),
            '2023-01-01': PricePoint(
              open: 99.0,
              high: 101.0,
              low: 98.0,
              close: 100.0,
              volume: 1000,
            ),
          },
        );

        final rate = FinancialCalculator.calculateAssetAnnualizedReturn(asset);
        // (110 / 100)^(1/1) - 1 = 10%
        expect(rate, closeTo(10.0, 0.1));
      });

      test('calcule le rendement à partir de la variation (%) et des métriques 52 semaines', () {
        final asset = Asset(
          symbol: 'DYNAMIC',
          name: 'Dynamic Asset',
          currentPrice: 120.0,
          type: 'Stock',
          description: 'Dynamic',
          marketOpen: true,
          timezone: 'US/Eastern',
          timeSeries: {},
          changePercentage: 2.0,
          low52Week: 100.0,
        );

        final rate = FinancialCalculator.calculateAssetAnnualizedReturn(asset);
        // (120 - 100) / 100 = 20%
        expect(rate, closeTo(20.0, 0.1));
      });

      test('retourne une valeur de secours réaliste si l\'historique est vide', () {
        final assetAapl = Asset(
          symbol: 'AAPL',
          name: 'Apple Inc.',
          currentPrice: 175.0,
          type: 'Stock',
          description: 'Tech',
          marketOpen: true,
          timezone: 'US/Eastern',
          timeSeries: {},
        );

        final rate = FinancialCalculator.calculateAssetAnnualizedReturn(assetAapl);
        expect(rate, closeTo(12.0, 0.001));
      });
    });

    group('calculateRealizedGain', () {
      test('calcule correctement la plus-value réalisée lors d\'une revente positive', () {
        final gain = FinancialCalculator.calculateRealizedGain(
          sellPrice: 150.0,
          averagePurchasePrice: 100.0,
          quantity: 3.0,
        );
        expect(gain, closeTo(150.0, 0.001));
      });

      test('calcule correctement la moins-value réalisée', () {
        final loss = FinancialCalculator.calculateRealizedGain(
          sellPrice: 80.0,
          averagePurchasePrice: 100.0,
          quantity: 2.0,
        );
        expect(loss, closeTo(-40.0, 0.001));
      });
    });

    group('calculateAllocationPercentage', () {
      test('calcule le pourcentage d\'allocation d\'une position', () {
        final percentage = FinancialCalculator.calculateAllocationPercentage(
          positionValue: 300.0,
          totalPortfolioValue: 1200.0,
        );
        expect(percentage, closeTo(25.0, 0.001));
      });

      test('retourne 0.0 si la valeur totale du portefeuille est nulle', () {
        final percentage = FinancialCalculator.calculateAllocationPercentage(
          positionValue: 100.0,
          totalPortfolioValue: 0.0,
        );
        expect(percentage, 0.0);
      });
    });

    group('Phase 5: Gamification & XP', () {
      test('calculateBuyXp: forfait +50 XP par achat', () {
        expect(FinancialCalculator.calculateBuyXp(), 50);
      });

      test('calculateSaleXp: gain basé sur la performance et durée', () {
        // 10% sur 5 jours -> 50
        expect(FinancialCalculator.calculateSaleXp(performancePercentage: 10.0, holdingDuration: const Duration(days: 5)), 50);
        // < 1 jour = 1 jour -> 15% * 1 -> 15
        expect(FinancialCalculator.calculateSaleXp(performancePercentage: 15.0, holdingDuration: const Duration(hours: 5)), 15);
        // Perte ou 0% -> 10 minimum
        expect(FinancialCalculator.calculateSaleXp(performancePercentage: -5.0, holdingDuration: const Duration(days: 10)), 10);
      });

      test('calculateStreakBonus: retourne le bon bonus', () {
        expect(FinancialCalculator.calculateStreakBonus(1), 20);
        expect(FinancialCalculator.calculateStreakBonus(7), 50);
        expect(FinancialCalculator.calculateStreakBonus(14), 50);
        expect(FinancialCalculator.calculateStreakBonus(30), 200);
        expect(FinancialCalculator.calculateStreakBonus(60), 200);
      });

      test('calculateLevel: un niveau tous les 1000 XP', () {
        expect(FinancialCalculator.calculateLevel(-50), 1);
        expect(FinancialCalculator.calculateLevel(0), 1);
        expect(FinancialCalculator.calculateLevel(999), 1);
        expect(FinancialCalculator.calculateLevel(1000), 2);
        expect(FinancialCalculator.calculateLevel(2500), 3);
      });

      test('getTitleForLevel: retourne un titre approprié', () {
        expect(FinancialCalculator.getTitleForLevel(1), 'Novice');
        expect(FinancialCalculator.getTitleForLevel(5), 'Débutant');
        expect(FinancialCalculator.getTitleForLevel(10), 'Apprenti');
        expect(FinancialCalculator.getTitleForLevel(100), 'Maître de Wall Street');
      });
    });
  });
}
