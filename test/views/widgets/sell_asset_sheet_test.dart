// [AI-GENERATED] Phase 4, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:le_compagnon_investissement/models/user_profile.dart';
import 'package:le_compagnon_investissement/controllers/auth_controller.dart';
import 'package:le_compagnon_investissement/controllers/portfolio_controller.dart';
import 'package:le_compagnon_investissement/services/auth_service.dart';
import 'package:le_compagnon_investissement/services/cache_service.dart';
import 'package:le_compagnon_investissement/models/asset.dart';
import 'package:le_compagnon_investissement/models/portfolio_position.dart';
import 'package:le_compagnon_investissement/views/widgets/sell_asset_sheet.dart';

class FakeCacheService extends CacheService {
  final List<PortfolioPosition> _positions = [];

  @override
  Future<void> initDB({bool inMemory = false}) async {}

  @override
  Future<void> savePortfolioPositions(List<PortfolioPosition> positions) async {
    _positions.clear();
    _positions.addAll(positions);
  }

  @override
  Future<List<PortfolioPosition>> getPortfolioPositions() async {
    return List.from(_positions);
  }

  @override
  Future<void> deletePortfolioPosition(String symbol) async {}

  @override
  Future<void> saveTransaction(dynamic transaction) async {}

  @override
  Future<void> saveCashBalance(double balance) async {}

  @override
  Future<double> getCashBalance() async => 1000.0;
}

class FakeAuthService implements AuthService {
  @override
  Future<UserProfile?> getCurrentUser() async => null;
  @override
  Future<bool> isKeepLoggedIn() async => false;
  @override
  Future<UserProfile> login(String e, String p, bool k) async => throw Exception();
  @override
  Future<void> logout() async {}
  @override
  Future<void> register(UserProfile u, String p) async {}
  @override
  Future<void> updateUser(UserProfile u) async {}
}

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

  final position = PortfolioPosition(
    asset: assetNvda,
    quantity: 5.0,
    averagePurchasePrice: 100.0,
  );

  group('SellAssetSheet Widget Tests', () {
    testWidgets('Rendu de la modale de revente et raccourci Tout vendre', (WidgetTester tester) async {
      final cacheService = FakeCacheService();
      final portfolioController = PortfolioController(
        cacheService: cacheService,
        initialPositions: [position],
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<PortfolioController>.value(value: portfolioController),
            ChangeNotifierProvider<AuthController>(create: (_) => AuthController(authService: FakeAuthService())),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SellAssetSheet(position: position),
            ),
          ),
        ),
      );

      expect(find.text('Revente Fictive'), findsOneWidget);
      expect(find.text('NVIDIA Corporation'), findsOneWidget);
      expect(find.text('Tout vendre'), findsOneWidget);

      // Clic sur Tout vendre -> Remplit le champ avec 5
      await tester.tap(find.text('Tout vendre'));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.controller?.text, equals('5'));
    });

    testWidgets('Validation et alerte en cas de saisie décimale/fraction', (WidgetTester tester) async {
      final cacheService = FakeCacheService();
      final portfolioController = PortfolioController(
        cacheService: cacheService,
        initialPositions: [position],
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<PortfolioController>.value(value: portfolioController),
            ChangeNotifierProvider<AuthController>(create: (_) => AuthController(authService: FakeAuthService())),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SellAssetSheet(position: position),
            ),
          ),
        ),
      );

      // Saisie d'une valeur décimale 2.5
      await tester.enterText(find.byType(TextFormField), '2.5');
      await tester.tap(find.byKey(const Key('confirm_sell_button')));
      await tester.pumpAndSettle();

      expect(find.textContaining('entier'), findsOneWidget);
    });

    testWidgets('Exécution réussie de la revente d\'unités entières', (WidgetTester tester) async {
      bool successCalled = false;
      final cacheService = FakeCacheService();
      final portfolioController = PortfolioController(
        cacheService: cacheService,
        initialPositions: [position],
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<PortfolioController>.value(value: portfolioController),
            ChangeNotifierProvider<AuthController>(create: (_) => AuthController(authService: FakeAuthService())),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SellAssetSheet(
                position: position,
                onSellSuccess: () {
                  successCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '2');
      await tester.tap(find.byKey(const Key('confirm_sell_button')));
      await tester.pumpAndSettle();

      expect(portfolioController.positions.first.quantity, equals(3.0));
      expect(successCalled, isTrue);
    });
  });
}
