// [AI-GENERATED] Setup, Agent, 2025-02-23
import 'package:flutter_test/flutter_test.dart';
import 'package:le_compagnon_investissement/models/financial_calculator.dart';

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
  });
}
