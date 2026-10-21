// [AI-GENERATED] Phase 4, Agent, 2025-02-23
import 'package:flutter_test/flutter_test.dart';
import 'package:le_compagnon_investissement/controllers/portfolio_controller.dart';
import 'package:le_compagnon_investissement/services/cache_service.dart';
import 'package:le_compagnon_investissement/models/asset.dart';
import 'package:le_compagnon_investissement/models/portfolio_position.dart';
import 'package:le_compagnon_investissement/models/portfolio_transaction.dart';

/// Implémentation factice de [CacheService] pour isoler les tests unitaires de [PortfolioController].
class FakeCacheService extends CacheService {
  final List<PortfolioPosition> _storedPositions = [];
  final List<PortfolioTransaction> _storedTransactions = [];
  double _storedCashBalance = 1000.0;

  @override
  Future<void> initDB({bool inMemory = false}) async {}

  @override
  Future<void> savePortfolioPositions(List<PortfolioPosition> positions) async {
    _storedPositions.clear();
    _storedPositions.addAll(positions);
  }

  @override
  Future<List<PortfolioPosition>> getPortfolioPositions() async {
    return List.from(_storedPositions);
  }

  @override
  Future<void> saveTransaction(PortfolioTransaction transaction) async {
    _storedTransactions.insert(0, transaction);
  }

  @override
  Future<List<PortfolioTransaction>> getTransactions() async {
    return List.from(_storedTransactions);
  }

  @override
  Future<void> deletePortfolioPosition(String symbol) async {
    _storedPositions.removeWhere(
      (p) => p.asset.symbol.toUpperCase() == symbol.toUpperCase(),
    );
  }

  @override
  Future<void> saveCashBalance(double balance) async {
    _storedCashBalance = balance;
  }

  @override
  Future<double> getCashBalance() async {
    return _storedCashBalance;
  }
}

void main() {
  late FakeCacheService cacheService;
  late PortfolioController portfolioController;

  // Modèles d'actifs de test
  final assetNvda = Asset(
    symbol: 'NVDA',
    name: 'NVIDIA Corporation',
    currentPrice: 130.0,
    type: 'Stock',
    description: 'Leader des puces IA',
    marketOpen: true,
    timezone: 'US/Eastern',
    timeSeries: {},
  );

  final assetAapl = Asset(
    symbol: 'AAPL',
    name: 'Apple Inc.',
    currentPrice: 220.0,
    type: 'Stock',
    description: 'Technologie grand public',
    marketOpen: true,
    timezone: 'US/Eastern',
    timeSeries: {},
  );

  setUp(() {
    cacheService = FakeCacheService();
    portfolioController = PortfolioController(cacheService: cacheService);
  });

  group('PortfolioController - Tests unitaires de la gestion du portefeuille et des liquidités', () {
    test('Portefeuille vide : solde de liquidités initial de 1 000,00 €', () {
      expect(portfolioController.positions, isEmpty);
      expect(portfolioController.cashBalance, closeTo(1000.0, 0.001));
      expect(portfolioController.totalValue, closeTo(0.0, 0.001));
      expect(portfolioController.totalInvested, closeTo(0.0, 0.001));
      expect(portfolioController.totalCapitalGain, closeTo(0.0, 0.001));
      expect(portfolioController.totalPerformance, closeTo(0.0, 0.001));
    });

    test('Achat d\'actif : débite le solde de liquidités', () async {
      // Solde initial = 1000 €
      // Achat de 2 NVDA à 130 € = 260 €
      await portfolioController.buyAsset(assetNvda, 2.0);

      expect(portfolioController.positions.length, equals(1));
      expect(portfolioController.cashBalance, closeTo(740.0, 0.001)); // 1000 - 260
      expect(portfolioController.totalValue, closeTo(260.0, 0.001));
    });

    test('Achat refusé si solde de liquidités insuffisant', () async {
      // 10 AAPL à 220 € = 2200 € > 1000 € solde
      expect(
        () async => await portfolioController.buyAsset(assetAapl, 10.0),
        throwsA(isA<StateError>()),
      );
      expect(portfolioController.cashBalance, closeTo(1000.0, 0.001));
      expect(portfolioController.positions, isEmpty);
    });

    test('Revente d\'actif : crédite le solde de liquidités', () async {
      await portfolioController.buyAsset(assetNvda, 2.0); // -260 € -> 740 €
      expect(portfolioController.cashBalance, closeTo(740.0, 0.001));

      // Revente de 1 unité de NVDA à 130 € -> +130 €
      await portfolioController.sellAsset(assetNvda, 1.0);

      expect(portfolioController.cashBalance, closeTo(870.0, 0.001)); // 740 + 130
      expect(portfolioController.positions.first.quantity, equals(1.0));
    });

    test('Revente partielle d\'unités entières : réduction de quantité et maintien du PMPA', () async {
      final asset100 = Asset(
        symbol: 'NVDA',
        name: 'NVIDIA Corporation',
        currentPrice: 100.0,
        type: 'Stock',
        description: 'Puces IA',
        marketOpen: true,
        timezone: 'US/Eastern',
        timeSeries: {},
      );

      await portfolioController.buyAsset(asset100, 5.0); // 5 x 100€ = 500€ -> solde = 500€

      final asset150 = Asset(
        symbol: 'NVDA',
        name: 'NVIDIA Corporation',
        currentPrice: 150.0,
        type: 'Stock',
        description: 'Puces IA',
        marketOpen: true,
        timezone: 'US/Eastern',
        timeSeries: {},
      );

      // Revente partielle de 3 unités à 150€ -> +450€ -> solde = 950€
      await portfolioController.sellAsset(asset150, 3.0);

      expect(portfolioController.positions.length, equals(1));
      final pos = portfolioController.positions.first;
      expect(pos.quantity, closeTo(2.0, 0.001));
      expect(pos.averagePurchasePrice, closeTo(100.0, 0.001));
      expect(portfolioController.cashBalance, closeTo(950.0, 0.001));
      expect(portfolioController.totalRealizedGain, closeTo(150.0, 0.001));
    });

    test('Revente totale d\'un actif : suppression de la position du portefeuille', () async {
      await portfolioController.buyAsset(assetAapl, 2.0); // 440 € -> solde = 560 €
      expect(portfolioController.positions.length, equals(1));

      await portfolioController.sellAsset(assetAapl, 2.0); // +440 € -> solde = 1000 €

      expect(portfolioController.positions, isEmpty);
      expect(portfolioController.cashBalance, closeTo(1000.0, 0.001));
    });

    test('Rejet d\'achat avec quantité décimale / fraction', () async {
      expect(
        () async => await portfolioController.buyAsset(assetNvda, 2.5),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Rejet de revente avec quantité décimale / fraction', () async {
      await portfolioController.buyAsset(assetNvda, 2.0);

      expect(
        () async => await portfolioController.sellAsset(assetNvda, 1.5),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Rejet de revente si quantité supérieure au montant possédé', () async {
      await portfolioController.buyAsset(assetNvda, 3.0);

      expect(
        () async => await portfolioController.sellAsset(assetNvda, 5.0),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Rejet de revente si l\'actif n\'est pas détenu', () async {
      expect(
        () async => await portfolioController.sellAsset(assetNvda, 1.0),
        throwsA(isA<StateError>()),
      );
    });

    test('Persistance CacheService : chargement des liquidités et positions', () async {
      await portfolioController.buyAsset(assetNvda, 2.0); // 260 € -> solde 740 €

      final newController = PortfolioController(cacheService: cacheService);
      await newController.loadPositions();

      expect(newController.positions.length, equals(1));
      expect(newController.cashBalance, closeTo(740.0, 0.001));
    });
  });
}
