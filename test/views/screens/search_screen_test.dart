// [AI-GENERATED] Phase 3, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:le_compagnon_investissement/models/asset.dart';
import 'package:le_compagnon_investissement/models/portfolio_position.dart';
import 'package:le_compagnon_investissement/controllers/data_controller.dart';
import 'package:le_compagnon_investissement/controllers/portfolio_controller.dart';
import 'package:le_compagnon_investissement/services/cache_service.dart';
import 'package:le_compagnon_investissement/services/api_service.dart';
import 'package:le_compagnon_investissement/views/screens/search_screen.dart';

class FakeCacheService extends CacheService {
  final Map<String, Asset> mockAssets;

  FakeCacheService({required this.mockAssets});

  @override
  Future<void> initDB({bool inMemory = false}) async {}

  @override
  Future<List<Asset>> getAllAssets() async => mockAssets.values.toList();

  @override
  Future<Asset?> getAsset(String symbol) async => mockAssets[symbol];

  @override
  Future<List<PortfolioPosition>> getPortfolioPositions([
    String userEmail = 'guest@app.local',
  ]) async => [];
}

class FakeApiService extends ApiService {
  @override
  Future<List<Asset>> fetchTopGainersLosers() async => [];
}

void main() {
  late Map<String, Asset> testAssets;
  late DataController dataController;
  late PortfolioController portfolioController;

  setUp(() async {
    testAssets = {
      'AAPL': Asset(
        symbol: 'AAPL',
        name: 'Apple Inc.',
        currentPrice: 175.0,
        type: 'Stock',
        description: 'Tech Company',
        marketOpen: true,
        timezone: 'US/Eastern',
        timeSeries: {},
      ),
      'MSFT': Asset(
        symbol: 'MSFT',
        name: 'Microsoft Corp.',
        currentPrice: 400.0,
        type: 'Stock',
        description: 'Cloud Company',
        marketOpen: true,
        timezone: 'US/Eastern',
        timeSeries: {},
      ),
      'QQQ': Asset(
        symbol: 'QQQ',
        name: 'Invesco QQQ Trust',
        currentPrice: 450.0,
        type: 'ETF',
        description: 'Nasdaq-100 ETF',
        marketOpen: true,
        timezone: 'US/Eastern',
        timeSeries: {},
      ),
    };

    final fakeCache = FakeCacheService(mockAssets: testAssets);
    dataController = DataController(
      apiService: FakeApiService(),
      cacheService: fakeCache,
    );

    // Pré-chargement manuel des actifs dans le dataController
    await dataController.loadAllCachedAssets();

    portfolioController = PortfolioController(cacheService: fakeCache);
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<DataController>.value(value: dataController),
          ChangeNotifierProvider<PortfolioController>.value(
            value: portfolioController,
          ),
        ],
        child: child,
      ),
    );
  }

  group('SearchScreen - Tests de recherche et filtrage', () {
    testWidgets(
      'Affiche la barre de recherche, les puces de catégories et tous les actifs au départ',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestableWidget(const SearchScreen()));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('search_text_field')), findsOneWidget);
        expect(find.byKey(const Key('category_chip_Tous')), findsOneWidget);
        expect(find.byKey(const Key('category_chip_Actions')), findsOneWidget);
        expect(find.byKey(const Key('category_chip_ETF')), findsOneWidget);

        expect(find.text('Apple Inc.'), findsOneWidget);
        expect(find.text('Microsoft Corp.'), findsOneWidget);
        
        await tester.drag(find.byType(ListView), const Offset(0, -300));
        await tester.pumpAndSettle();
        expect(find.text('Invesco QQQ Trust'), findsOneWidget);
      },
    );

    testWidgets('Filtre les actifs par saisie textuelle (symbole ou nom)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(const SearchScreen()));
      await tester.pumpAndSettle();

      // Saisie 'MSFT' dans le champ de recherche
      final searchField = find.byKey(const Key('search_text_field'));
      await tester.enterText(searchField, 'MSFT');
      await tester.pumpAndSettle();

      // Seul Microsoft Corp. doit apparaître, Apple Inc. et Invesco QQQ Trust doivent être masqués
      expect(find.text('Microsoft Corp.'), findsOneWidget);
      expect(find.text('Apple Inc.'), findsNothing);
      expect(find.text('Invesco QQQ Trust'), findsNothing);
    });

    testWidgets('Filtre les actifs par catégorie (ETF)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(const SearchScreen()));
      await tester.pumpAndSettle();

      // Sélection de la puce 'ETF'
      final etfChip = find.byKey(const Key('category_chip_ETF'));
      await tester.tap(etfChip);
      await tester.pumpAndSettle();

      // Seul l'ETF QQQ (Invesco QQQ Trust) doit apparaître
      expect(find.text('Invesco QQQ Trust'), findsOneWidget);
      expect(find.text('Apple Inc.'), findsNothing);
      expect(find.text('Microsoft Corp.'), findsNothing);
    });

    testWidgets(
      'Affiche un message si aucun actif ne correspond à la recherche',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestableWidget(const SearchScreen()));
        await tester.pumpAndSettle();

        final searchField = find.byKey(const Key('search_text_field'));
        await tester.enterText(searchField, 'XYZ_INEXISTANT');
        await tester.pumpAndSettle();

        expect(
          find.text('Aucun actif ne correspond à votre recherche.'),
          findsOneWidget,
        );
      },
    );
  });
}
