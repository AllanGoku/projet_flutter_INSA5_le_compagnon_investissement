// [AI-GENERATED] Phase 8, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
// ignore: implementation_imports
import 'package:sqflite_common/src/mixin/factory.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';

import 'package:le_compagnon_investissement/views/screens/lexicon_screen.dart';
import 'package:le_compagnon_investissement/controllers/portfolio_controller.dart';
import 'package:le_compagnon_investissement/controllers/gamification_controller.dart';
import 'package:le_compagnon_investissement/services/cache_service.dart';

void main() {
  late CacheService cacheService;
  late PortfolioController portfolioController;
  late GamificationController gamificationController;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    databaseFactory = buildDatabaseFactory(
      invokeMethod: (String method, [Object? arguments]) async {
        if (method == 'openDatabase') return <String, dynamic>{'id': 1};
        if (method == 'execute') return null;
        if (method == 'insert') return 1;
        if (method == 'query') return <Map<String, dynamic>>[];
        if (method == 'delete') return 1;
        if (method == 'closeDatabase') return null;
        return null;
      },
    );

    cacheService = CacheService();
    await cacheService.initDB(inMemory: true);
    portfolioController = PortfolioController(cacheService: cacheService);
    gamificationController = GamificationController(cacheService);
    await gamificationController.loadData();
  });

  tearDown(() async {
    await cacheService.close();
  });

  Widget createWidgetUnderTest({
    String? initialSearchQuery,
  }) {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<PortfolioController>.value(
            value: portfolioController,
          ),
          ChangeNotifierProvider<GamificationController>.value(
            value: gamificationController,
          ),
        ],
        child: LexiconScreen(initialSearchQuery: initialSearchQuery),
      ),
    );
  }

  group('LexiconScreen - Tests de widgets', () {
    testWidgets(
      'Affiche l\'écran du lexique avec le titre, la barre de recherche et les termes par défaut',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Vérification de la présence du titre et de la barre de recherche
        expect(find.text('Lexique & Aide Financière'), findsOneWidget);
        expect(find.byKey(const Key('lexicon_search_input')), findsOneWidget);

        // Vérification de la présence de termes par défaut
        expect(find.text('Capitalisation Boursière'), findsOneWidget);
        expect(find.text('PER (Price Earnings Ratio)'), findsOneWidget);

        // Vérification du déclenchement du succès
        expect(gamificationController.achievements, isNotEmpty);
      },
    );

    testWidgets(
      'Filtre la liste des termes lors de la saisie dans la barre de recherche',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Saisie de "DCA" dans la recherche
        await tester.enterText(
          find.byKey(const Key('lexicon_search_input')),
          'DCA',
        );
        await tester.pumpAndSettle();

        // Vérification que le terme DCA est affiché et pas les autres
        expect(find.text('DCA (Dollar-Cost Averaging)'), findsOneWidget);
        expect(find.text('PER (Price Earnings Ratio)'), findsNothing);

        // Effacement de la recherche
        await tester.tap(find.byKey(const Key('lexicon_search_clear_button')));
        await tester.pumpAndSettle();

        expect(find.text('Capitalisation Boursière'), findsOneWidget);
      },
    );

    testWidgets(
      'Trouve et déplie le terme Capitalisation Boursière lors de la recherche du synonyme "Cap. Boursière"',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(initialSearchQuery: 'Cap. Boursière'),
        );
        await tester.pumpAndSettle();

        expect(find.text('Capitalisation Boursière'), findsOneWidget);
        expect(find.textContaining('Exemple concret :'), findsOneWidget);
      },
    );

    testWidgets(
      'Filtre les termes par chip de catégorie',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Défiler jusqu'au chip "Formules App" et cliquer dessus
        final formulasChipFinder = find.byKey(const Key('lexicon_chip_formulas'));
        await tester.ensureVisible(formulasChipFinder);
        await tester.pumpAndSettle();

        await tester.tap(formulasChipFinder);
        await tester.pumpAndSettle();

        // Vérification de l'affichage des termes de formule
        expect(
          find.text('Calcul de la Valeur du Portefeuille (Formule App)'),
          findsOneWidget,
        );
        expect(find.text('Capitalisation Boursière'), findsNothing);
      },
    );

    testWidgets(
      'Déplie une carte au clic pour afficher l\'explication détaillée et la formule',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Défiler dans la liste verticale jusqu'à la carte PMPA
        final pmpaCardFinder = find.byKey(const Key('lexicon_card_pmpa'));
        await tester.dragUntilVisible(
          pmpaCardFinder,
          find.byType(ListView),
          const Offset(0, -200),
        );
        await tester.pumpAndSettle();

        // Clic sur la carte PMPA pour la déplier
        await tester.tap(pmpaCardFinder);
        await tester.pumpAndSettle();

        // Vérification de la présence de l'exemple et de la formule mathématique
        expect(find.textContaining('Exemple concret :'), findsOneWidget);
        expect(
          find.text('PMPA = Total des montants d\'achat / Nombre total de titres'),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('lexicon_action_button_pmpa')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Affiche la vue d\'état vide lorsque aucun résultat ne correspond',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Saisie d'une recherche sans correspondance
        await tester.enterText(
          find.byKey(const Key('lexicon_search_input')),
          'MotCleInexistant123',
        );
        await tester.pumpAndSettle();

        // Vérification de la vue vide
        expect(find.text('Aucun terme trouvé'), findsOneWidget);
        expect(
          find.byKey(const Key('lexicon_reset_filters_button')),
          findsOneWidget,
        );

        // Clic sur la réinitialisation
        await tester.tap(
          find.byKey(const Key('lexicon_reset_filters_button')),
        );
        await tester.pumpAndSettle();

        expect(find.text('Capitalisation Boursière'), findsOneWidget);
      },
    );
  });
}
