// [AI-GENERATED] Phase 4, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_compagnon_investissement/models/asset.dart';
import 'package:le_compagnon_investissement/models/portfolio_position.dart';
import 'package:le_compagnon_investissement/views/widgets/portfolio_position_card.dart';

void main() {
  final assetNvda = Asset(
    symbol: 'NVDA',
    name: 'NVIDIA Corporation',
    currentPrice: 150.0,
    type: 'Stock',
    description: 'Puces IA',
    marketOpen: true,
    timezone: 'US/Eastern',
    timeSeries: {},
  );

  group('PortfolioPositionCard Widget Tests', () {
    testWidgets('Affiche les détails de la position et réagit au bouton Vendre', (WidgetTester tester) async {
      bool sellPressed = false;

      final position = PortfolioPosition(
        asset: assetNvda,
        quantity: 10.0,
        averagePurchasePrice: 100.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PortfolioPositionCard(
              position: position,
              onSellPressed: () {
                sellPressed = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('NVDA'), findsOneWidget);
      expect(find.text('NVIDIA Corporation'), findsOneWidget);
      expect(find.textContaining('10'), findsWidgets); // Quantité
      expect(find.text('Vendre'), findsOneWidget);

      await tester.tap(find.text('Vendre'));
      await tester.pump();

      expect(sellPressed, isTrue);
    });
  });
}
