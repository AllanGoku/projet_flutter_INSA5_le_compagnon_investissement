// [AI-GENERATED] Phase 3, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:le_compagnon_investissement/models/asset.dart';
import 'package:le_compagnon_investissement/models/portfolio_position.dart';
import 'package:le_compagnon_investissement/models/portfolio_transaction.dart';
import 'package:le_compagnon_investissement/controllers/portfolio_controller.dart';
import 'package:le_compagnon_investissement/services/cache_service.dart';
import 'package:le_compagnon_investissement/views/screens/asset_detail_screen.dart';
import 'package:le_compagnon_investissement/views/widgets/buy_asset_sheet.dart';
import 'package:le_compagnon_investissement/views/widgets/asset_historical_chart.dart';

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

  @override
  Future<void> saveCashBalance(double balance) async {}

  @override
  Future<double> getCashBalance() async => 1000.0;
}

void main() {
  late Asset testAsset;
  late PortfolioController portfolioController;

  setUp(() {
    testAsset = Asset(
      symbol: 'AAPL',
      name: 'Apple Inc.',
      currentPrice: 175.50,
      type: 'Stock',
      description: 'Leader mondial des smartphones et ordinateurs.',
      marketOpen: true,
      timezone: 'US/Eastern',
      timeSeries: {},
      changePercentage: 1.5,
    );

    portfolioController = PortfolioController(cacheService: FakeCacheService());
  });

  Widget buildTestableWidget(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PortfolioController>.value(value: portfolioController),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('AssetDetailScreen - Tests de l\'écran de détail', () {
    testWidgets('Affiche le nom de l\'actif, le cours, le graphique et les statistiques', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(AssetDetailScreen(asset: testAsset)));

      expect(find.text('AAPL'), findsOneWidget);
      expect(find.text('Apple Inc.'), findsOneWidget);
      expect(find.text('175,50 €'), findsOneWidget);
      expect(find.byType(AssetHistoricalChart), findsOneWidget);
      expect(find.text('Acheter cet actif (Fictif)'), findsOneWidget);
    });

    testWidgets('Le clic sur le bouton dédié "Acheter cet actif (Fictif)" ouvre la feuille modale d\'achat', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(AssetDetailScreen(asset: testAsset)));

      // Clic sur le bouton d'achat en bas d'écran
      final buyButton = find.byKey(const Key('buy_asset_detail_button'));
      await tester.tap(buyButton);
      await tester.pumpAndSettle();

      // Vérification que BuyAssetSheet est ouvert
      expect(find.byType(BuyAssetSheet), findsOneWidget);
      expect(find.text('Confirmer l\'achat fictif'), findsOneWidget);
    });
  });
}
