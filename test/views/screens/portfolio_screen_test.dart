// [AI-GENERATED] Phase 4, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:le_compagnon_investissement/controllers/portfolio_controller.dart';
import 'package:le_compagnon_investissement/services/cache_service.dart';
import 'package:le_compagnon_investissement/models/asset.dart';
import 'package:le_compagnon_investissement/models/portfolio_position.dart';
import 'package:le_compagnon_investissement/models/portfolio_transaction.dart';
import 'package:le_compagnon_investissement/views/screens/portfolio_screen.dart';

class FakeCacheService extends CacheService {
  final List<PortfolioPosition> _positions = [];

  @override
  Future<void> initDB({bool inMemory = false}) async {}

  @override
  Future<void> savePortfolioPositions(
    List<PortfolioPosition> positions, [
    String userEmail = 'guest@app.local',
  ]) async {
    _positions.clear();
    _positions.addAll(positions);
  }

  @override
  Future<List<PortfolioPosition>> getPortfolioPositions([
    String userEmail = 'guest@app.local',
  ]) async {
    return List.from(_positions);
  }

  @override
  Future<void> deletePortfolioPosition(
    String symbol, [
    String userEmail = 'guest@app.local',
  ]) async {}

  @override
  Future<void> saveTransaction(
    dynamic transaction, [
    String userEmail = 'guest@app.local',
  ]) async {}

  @override
  Future<List<PortfolioTransaction>> getTransactions([
    String userEmail = 'guest@app.local',
  ]) async => [];

  @override
  Future<void> saveCashBalance(
    double balance, [
    String userEmail = 'guest@app.local',
  ]) async {}

  @override
  Future<double> getCashBalance([String userEmail = 'guest@app.local']) async =>
      1000.0;
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

  group('PortfolioScreen Widget Tests', () {
    testWidgets(
      'Affiche la synthèse, le graphique, la position et l\'historique',
      (WidgetTester tester) async {
        final cacheService = FakeCacheService();
        final portfolioController = PortfolioController(
          cacheService: cacheService,
          initialPositions: [
            PortfolioPosition(
              asset: assetNvda,
              quantity: 2.0,
              averagePurchasePrice: 100.0,
            ),
          ],
        );

        await tester.pumpWidget(
          ChangeNotifierProvider<PortfolioController>.value(
            value: portfolioController,
            child: const MaterialApp(home: PortfolioScreen()),
          ),
        );

        expect(find.text('Mon Portefeuille'), findsOneWidget);
        expect(find.text('Patrimoine Total (Actifs + Cash)'), findsOneWidget);
        expect(find.text('Répartition du Portefeuille'), findsOneWidget);
        expect(find.text('Mes Positions (1)'), findsOneWidget);
        expect(find.text('NVDA'), findsWidgets);
        expect(find.text('Historique des Transactions'), findsOneWidget);
      },
    );

    testWidgets('Affiche l\'état vide quand aucune position n\'est détenue', (
      WidgetTester tester,
    ) async {
      final cacheService = FakeCacheService();
      final portfolioController = PortfolioController(
        cacheService: cacheService,
        initialPositions: [],
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<PortfolioController>.value(
          value: portfolioController,
          child: const MaterialApp(home: PortfolioScreen()),
        ),
      );

      expect(find.text('Mon Portefeuille'), findsOneWidget);
      expect(find.text('Portefeuille vide'), findsOneWidget);
    });
  });
}
