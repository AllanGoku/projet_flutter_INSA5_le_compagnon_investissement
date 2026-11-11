// [AI-GENERATED] Phase 4, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_compagnon_investissement/models/asset.dart';
import 'package:le_compagnon_investissement/models/portfolio_position.dart';
import 'package:le_compagnon_investissement/views/widgets/portfolio_allocation_chart.dart';

void main() {
  final assetNvda = Asset(
    symbol: 'NVDA',
    name: 'NVIDIA Corporation',
    currentPrice: 100.0,
    type: 'Stock',
    description: 'Puces IA',
    marketOpen: true,
    timezone: 'US/Eastern',
    timeSeries: {},
  );

  final assetAapl = Asset(
    symbol: 'AAPL',
    name: 'Apple Inc.',
    currentPrice: 200.0,
    type: 'Stock',
    description: 'Tech',
    marketOpen: true,
    timezone: 'US/Eastern',
    timeSeries: {},
  );

  group('PortfolioAllocationChart Widget Tests', () {
    testWidgets('Affiche le donut chart et la légende avec les positions', (
      WidgetTester tester,
    ) async {
      final positions = [
        PortfolioPosition(
          asset: assetNvda,
          quantity: 2.0,
          averagePurchasePrice: 100.0,
        ), // 200 € (50%)
        PortfolioPosition(
          asset: assetAapl,
          quantity: 1.0,
          averagePurchasePrice: 200.0,
        ), // 200 € (50%)
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PortfolioAllocationChart(
              positions: positions,
              totalValue: 400.0,
            ),
          ),
        ),
      );

      expect(find.text('Répartition du Portefeuille'), findsOneWidget);
      expect(find.text('NVDA'), findsOneWidget);
      expect(find.text('AAPL'), findsOneWidget);
      expect(find.textContaining('50.0%'), findsNWidgets(2));
    });

    testWidgets(
      'Affiche l\'état vide quand le portefeuille n\'a pas de positions',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PortfolioAllocationChart(positions: [], totalValue: 0.0),
            ),
          ),
        );

        expect(find.text('Répartition du Portefeuille'), findsOneWidget);
        expect(find.text('Aucune position à afficher'), findsOneWidget);
      },
    );
  });
}
