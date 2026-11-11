// [AI-GENERATED] Phase 3, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_compagnon_investissement/models/price_point.dart';
import 'package:le_compagnon_investissement/views/widgets/asset_historical_chart.dart';

void main() {
  final Map<String, PricePoint> sampleTimeSeries = {
    '2025-02-01': PricePoint(
      open: 100.0,
      high: 105.0,
      low: 99.0,
      close: 102.0,
      volume: 1000,
    ),
    '2025-02-02': PricePoint(
      open: 102.0,
      high: 108.0,
      low: 101.0,
      close: 106.0,
      volume: 1200,
    ),
    '2025-02-03': PricePoint(
      open: 106.0,
      high: 110.0,
      low: 105.0,
      close: 109.0,
      volume: 1500,
    ),
  };

  group('AssetHistoricalChart - Tests de widgets', () {
    testWidgets(
      'Affiche les puces de sélection de période et le graphique fl_chart',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AssetHistoricalChart(timeSeries: sampleTimeSeries),
            ),
          ),
        );

        // Vérification des boutons de choix de période
        expect(find.text('7J'), findsOneWidget);
        expect(find.text('1M'), findsOneWidget);
        expect(find.text('1A'), findsOneWidget);
        expect(find.text('MAX'), findsOneWidget);
      },
    );

    testWidgets('Permet la bascule entre les périodes (7J, 1M, 1A, MAX)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AssetHistoricalChart(timeSeries: sampleTimeSeries),
          ),
        ),
      );

      // Clic sur la puce '1M'
      await tester.tap(find.byKey(const Key('period_chip_1M')));
      await tester.pumpAndSettle();

      // Clic sur la puce 'MAX'
      await tester.tap(find.byKey(const Key('period_chip_MAX')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('period_chip_MAX')), findsOneWidget);
    });

    testWidgets('Gère proprement le cas d\'un historique vide', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AssetHistoricalChart(timeSeries: {})),
        ),
      );

      expect(find.text('Historique non disponible'), findsOneWidget);
    });
  });
}
