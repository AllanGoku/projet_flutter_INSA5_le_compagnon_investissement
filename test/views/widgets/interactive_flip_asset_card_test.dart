// [AI-GENERATED] Phase 3, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_compagnon_investissement/models/asset.dart';
import 'package:le_compagnon_investissement/views/widgets/interactive_flip_asset_card.dart';

void main() {
  final testAsset = Asset(
    symbol: 'AAPL',
    name: 'Apple Inc.',
    currentPrice: 175.50,
    type: 'Stock',
    description: 'Technologie grand public.',
    marketOpen: true,
    timezone: 'US/Eastern',
    timeSeries: {},
    changePercentage: 2.5,
  );

  group('InteractiveFlipAssetCard - Tests de widgets et d\'animation 3D', () {
    testWidgets('Affiche le recto de la carte avec les informations de base', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: InteractiveFlipAssetCard(asset: testAsset)),
        ),
      );

      expect(find.text('AAPL'), findsOneWidget);
      expect(find.text('Apple Inc.'), findsOneWidget);
      expect(find.text('Touchez pour retourner 3D'), findsOneWidget);
    });

    testWidgets(
      'Déclenche le retournement 3D au tap n\'importe où sur la carte et dévoile le verso',
      (WidgetTester tester) async {
        bool detailPressed = false;
        bool buyPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: InteractiveFlipAssetCard(
                asset: testAsset,
                onDetailPressed: () {
                  detailPressed = true;
                },
                onBuyPressed: () {
                  buyPressed = true;
                },
              ),
            ),
          ),
        );

        // Tap n'importe où sur la carte pour retourner en 3D
        await tester.tap(
          find.byKey(Key('flip_card_gesture_${testAsset.symbol}')),
        );
        await tester.pumpAndSettle();

        // Vérification du verso : le texte "Aperçu rapide" et le bouton "Voir les détails" doivent être visibles
        expect(find.text('Aperçu rapide'), findsOneWidget);
        expect(find.text('Voir les détails'), findsOneWidget);

        // Séparation UX : Le tap sur la carte n'a pas déclenché les callbacks d'achat ou de détails
        expect(detailPressed, isFalse);
        expect(buyPressed, isFalse);
      },
    );

    testWidgets(
      'Le clic sur "Voir les détails" au verso déclenche le callback onDetailPressed',
      (WidgetTester tester) async {
        bool detailPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: InteractiveFlipAssetCard(
                asset: testAsset,
                onDetailPressed: () {
                  detailPressed = true;
                },
              ),
            ),
          ),
        );

        // Retournement 3D
        await tester.tap(
          find.byKey(Key('flip_card_gesture_${testAsset.symbol}')),
        );
        await tester.pumpAndSettle();

        // Clic sur "Voir les détails"
        await tester.tap(
          find.byKey(Key('flip_card_detail_button_${testAsset.symbol}')),
        );
        await tester.pumpAndSettle();

        expect(detailPressed, isTrue);
      },
    );
  });
}
