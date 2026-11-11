// [AI-GENERATED] Phase 6, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:le_compagnon_investissement/views/screens/dca_simulator_screen.dart';
import 'package:le_compagnon_investissement/models/asset.dart';
import 'package:le_compagnon_investissement/controllers/portfolio_controller.dart';
import 'package:le_compagnon_investissement/controllers/data_controller.dart';
import 'package:le_compagnon_investissement/services/cache_service.dart';
import 'package:le_compagnon_investissement/services/api_service.dart';
import 'package:le_compagnon_investissement/models/portfolio_position.dart';

class FakeCacheService extends CacheService {
  @override
  Future<void> initDB({bool inMemory = false}) async {}

  @override
  Future<List<PortfolioPosition>> getPortfolioPositions([
    String userEmail = 'guest@app.local',
  ]) async => [];
}

void main() {
  late PortfolioController portfolioController;
  late DataController dataController;

  setUp(() {
    final cacheService = FakeCacheService();
    portfolioController = PortfolioController(cacheService: cacheService);
    dataController = DataController(
      apiService: ApiService(),
      cacheService: cacheService,
    );
  });

  Widget buildTestableWidget({Asset? initialAsset}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PortfolioController>.value(
          value: portfolioController,
        ),
        ChangeNotifierProvider<DataController>.value(value: dataController),
      ],
      child: MaterialApp(home: DcaSimulatorScreen(initialAsset: initialAsset)),
    );
  }

  group('DcaSimulatorScreen - Tests de widgets et simulation', () {
    testWidgets('Affiche les composants principaux du simulateur DCA', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // En-tête et titre
      expect(find.text('Simulateur DCA'), findsOneWidget);

      // Champs de saisie et curseurs
      expect(find.byKey(const Key('dca_monthly_amount_field')), findsOneWidget);
      expect(
        find.byKey(const Key('dca_monthly_amount_slider')),
        findsOneWidget,
      );

      // Puces de sélection de durée (1, 5, 10, 20 ans)
      expect(find.byKey(const Key('dca_duration_chip_1')), findsOneWidget);
      expect(find.byKey(const Key('dca_duration_chip_5')), findsOneWidget);
      expect(find.byKey(const Key('dca_duration_chip_10')), findsOneWidget);
      expect(find.byKey(const Key('dca_duration_chip_20')), findsOneWidget);

      // Composants de résultats et comparaison
      expect(find.byKey(const Key('dca_final_value')), findsOneWidget);
      expect(find.byKey(const Key('dca_total_invested')), findsOneWidget);
      expect(find.byKey(const Key('dca_total_gains')), findsOneWidget);
      expect(find.byKey(const Key('dca_distribution_bar')), findsOneWidget);
      expect(find.byKey(const Key('dca_comparison_card')), findsOneWidget);

      // Bouton d'achat
      expect(find.byKey(const Key('dca_buy_button')), findsOneWidget);
    });

    testWidgets(
      'Met à jour la simulation lors de la modification de la durée',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestableWidget());
        await tester.pumpAndSettle();

        // Sélection de 5 ans au lieu de 10 ans
        final chip5Years = find.byKey(const Key('dca_duration_chip_5'));
        await tester.tap(chip5Years);
        await tester.pumpAndSettle();

        // 100€/mois pendant 5 ans = 6000€ investis
        expect(find.textContaining('6 000'), findsAtLeastNWidgets(1));
      },
    );

    testWidgets('Initialise le simulateur avec un actif spécifique', (
      WidgetTester tester,
    ) async {
      final testAsset = Asset(
        symbol: 'AAPL',
        name: 'Apple Inc.',
        currentPrice: 175.0,
        type: 'Stock',
        description: 'Tech',
        marketOpen: true,
        timezone: 'US/Eastern',
        timeSeries: {},
      );

      await tester.pumpWidget(buildTestableWidget(initialAsset: testAsset));
      await tester.pumpAndSettle();

      expect(find.textContaining('Apple Inc.'), findsAtLeastNWidgets(1));
    });

    testWidgets(
      'Ouvre la modale d\'achat lors du clic sur le bouton d\'action',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestableWidget());
        await tester.pumpAndSettle();

        final buyButton = find.byKey(const Key('dca_buy_button'));
        await tester.tap(buyButton);
        await tester.pumpAndSettle();

        // Vérifie l'ouverture du sheet d'achat
        expect(find.textContaining('Achat Fictif'), findsOneWidget);
      },
    );
  });
}
