// [AI-GENERATED] Phase 2, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:le_compagnon_investissement/views/screens/dashboard_screen.dart';
import 'package:le_compagnon_investissement/views/widgets/flip_gain_counter.dart';
import 'package:le_compagnon_investissement/views/widgets/hero_asset_card.dart';
import 'package:le_compagnon_investissement/views/widgets/asset_grid_section.dart';
import 'package:le_compagnon_investissement/views/widgets/market_movers_section.dart';
import 'package:le_compagnon_investissement/controllers/portfolio_controller.dart';
import 'package:le_compagnon_investissement/controllers/data_controller.dart';
import 'package:le_compagnon_investissement/models/portfolio_position.dart';
import 'package:le_compagnon_investissement/services/cache_service.dart';
import 'package:le_compagnon_investissement/services/api_service.dart';

class FakeCacheService extends CacheService {
  @override
  Future<void> initDB({bool inMemory = false}) async {}

  @override
  Future<void> savePortfolioPositions(List<PortfolioPosition> positions) async {}

  @override
  Future<List<PortfolioPosition>> getPortfolioPositions() async => [];
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

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<PortfolioController>.value(value: portfolioController),
          ChangeNotifierProvider<DataController>.value(value: dataController),
        ],
        child: child,
      ),
    );
  }

  group('DashboardScreen - Tests de widgets et d\'affichage', () {
    testWidgets('Affichage des différentes sections du tableau de bord', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const DashboardScreen()));
      await tester.pumpAndSettle();

      // Vérification de la présence de l'en-tête et des 3 sections clés
      expect(find.byType(FlipGainCounter), findsOneWidget);
      expect(find.byType(HeroAssetCard), findsOneWidget);
      expect(find.byType(AssetGridSection), findsOneWidget);
      expect(find.byType(MarketMoversSection), findsOneWidget);

      // Vérification des titres de section
      expect(find.text('Ton Portefeuille Fictif'), findsOneWidget);
      expect(find.text('À surveiller'), findsOneWidget);
      expect(find.text('Market Movers'), findsOneWidget);

      // Vérification de la présence de la barre de navigation inférieure
      expect(find.byType(NavigationBar), findsOneWidget);
    });
  });
}
