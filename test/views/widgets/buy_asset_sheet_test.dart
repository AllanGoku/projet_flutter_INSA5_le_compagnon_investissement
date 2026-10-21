// [AI-GENERATED] Phase 2, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:le_compagnon_investissement/views/widgets/buy_asset_sheet.dart';
import 'package:le_compagnon_investissement/models/asset.dart';
import 'package:le_compagnon_investissement/models/portfolio_position.dart';
import 'package:le_compagnon_investissement/models/portfolio_transaction.dart';
import 'package:le_compagnon_investissement/controllers/portfolio_controller.dart';
import 'package:le_compagnon_investissement/services/cache_service.dart';

class FakeCacheService extends CacheService {
  @override
  Future<void> initDB({bool inMemory = false}) async {}

  @override
  Future<void> savePortfolioPositions(List<PortfolioPosition> positions) async {}

  @override
  Future<List<PortfolioPosition>> getPortfolioPositions() async => [];

  @override
  Future<void> saveTransaction(PortfolioTransaction transaction) async {}

  @override
  Future<List<PortfolioTransaction>> getTransactions() async => [];
}

void main() {
  late Asset testAsset;
  late PortfolioController portfolioController;

  setUp(() {
    testAsset = Asset(
      symbol: 'NVDA',
      name: 'NVIDIA Corporation',
      currentPrice: 130.0,
      type: 'Stock',
      description: 'Puces IA',
      marketOpen: true,
      timezone: 'US/Eastern',
      timeSeries: {},
    );

    portfolioController = PortfolioController(cacheService: FakeCacheService());
  });

  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: MultiProvider(
          providers: [
            ChangeNotifierProvider<PortfolioController>.value(
              value: portfolioController,
            ),
          ],
          child: child,
        ),
      ),
    );
  }

  group('BuyAssetSheet - Tests de widgets', () {
    testWidgets('Affiche le nom de l\'actif et le prix unitaire', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(BuyAssetSheet(asset: testAsset)));

      expect(find.text('NVIDIA Corporation'), findsOneWidget);
      expect(find.text('NVDA'), findsOneWidget);
      expect(find.text('Confirmer l\'achat fictif'), findsOneWidget);
    });

    testWidgets('Validation du champ quantité > 0 et refus de validation si invalide', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(BuyAssetSheet(asset: testAsset)));

      // Effacer la quantité par défaut
      final textField = find.byType(TextFormField);
      await tester.enterText(textField, '0');
      await tester.pump();

      // Tap sur le bouton de confirmation
      final confirmButton = find.byKey(const Key('confirm_buy_button'));
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      // Vérifies l'apparition du message de validation d'erreur
      expect(find.text('La quantité doit être supérieure à 0.'), findsOneWidget);
      expect(portfolioController.positions, isEmpty);
    });

    testWidgets('Refus de validation en cas de saisie d\'une fraction d\'action', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(BuyAssetSheet(asset: testAsset)));

      final textField = find.byType(TextFormField);
      await tester.enterText(textField, '1.5');
      await tester.pump();

      final confirmButton = find.byKey(const Key('confirm_buy_button'));
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      expect(find.textContaining('entier'), findsOneWidget);
      expect(portfolioController.positions, isEmpty);
    });

    testWidgets('Saisie d\'une quantité valide et déclenchement de l\'achat', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(BuyAssetSheet(asset: testAsset)));

      final textField = find.byType(TextFormField);
      await tester.enterText(textField, '5');
      await tester.pump();

      final confirmButton = find.byKey(const Key('confirm_buy_button'));
      await tester.tap(confirmButton);
      await tester.pump();

      // Vérification que l'achat a été enregistré dans le contrôleur
      expect(portfolioController.positions.length, equals(1));
      expect(portfolioController.positions.first.quantity, closeTo(5.0, 0.001));
    });
  });
}
