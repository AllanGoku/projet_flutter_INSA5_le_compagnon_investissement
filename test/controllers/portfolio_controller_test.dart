// [AI-GENERATED] Phase 2, Agent, 2025-02-23
import 'package:flutter_test/flutter_test.dart';
import 'package:le_compagnon_investissement/controllers/portfolio_controller.dart';
import 'package:le_compagnon_investissement/services/cache_service.dart';
import 'package:le_compagnon_investissement/models/asset.dart';
import 'package:le_compagnon_investissement/models/portfolio_position.dart';

/// Implémentation factice de [CacheService] pour isoler les tests unitaires de [PortfolioController].
class FakeCacheService extends CacheService {
  final List<PortfolioPosition> _storedPositions = [];

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

  group('PortfolioController - Tests unitaires de la gestion du portefeuille', () {
    test('Portefeuille vide : les métriques doivent valoir 0.0', () {
      // Vérification des métriques sur un portefeuille sans aucune position
      expect(portfolioController.positions, isEmpty);
      expect(portfolioController.totalValue, closeTo(0.0, 0.001));
      expect(portfolioController.totalInvested, closeTo(0.0, 0.001));
      expect(portfolioController.totalCapitalGain, closeTo(0.0, 0.001));
      expect(portfolioController.totalPerformance, closeTo(0.0, 0.001));
    });

    test('Ajout d\'une nouvelle position : achete un premier actif', () async {
      // Achat de 2 actions NVDA à 130 €
      await portfolioController.buyAsset(assetNvda, 2.0);

      expect(portfolioController.positions.length, equals(1));
      final pos = portfolioController.positions.first;
      expect(pos.asset.symbol, equals('NVDA'));
      expect(pos.quantity, closeTo(2.0, 0.001));
      expect(pos.averagePurchasePrice, closeTo(130.0, 0.001));

      // Métriques
      expect(portfolioController.totalValue, closeTo(260.0, 0.001));
      expect(portfolioController.totalInvested, closeTo(260.0, 0.001));
      expect(portfolioController.totalCapitalGain, closeTo(0.0, 0.001));
      expect(portfolioController.totalPerformance, closeTo(0.0, 0.001));
    });

    test('Achats multiples du même actif : cumul de quantité et calcul exact du PMPA', () async {
      // Premier achat : 10 actions à 100 €
      final assetFirstBuy = Asset(
        symbol: 'NVDA',
        name: 'NVIDIA Corporation',
        currentPrice: 100.0,
        type: 'Stock',
        description: 'Puces IA',
        marketOpen: true,
        timezone: 'US/Eastern',
        timeSeries: {},
      );

      await portfolioController.buyAsset(assetFirstBuy, 10.0);

      // Second achat : 5 actions à 160 € (le cours de l'actif est passé à 160 €)
      final assetSecondBuy = Asset(
        symbol: 'NVDA',
        name: 'NVIDIA Corporation',
        currentPrice: 160.0,
        type: 'Stock',
        description: 'Puces IA',
        marketOpen: true,
        timezone: 'US/Eastern',
        timeSeries: {},
      );

      await portfolioController.buyAsset(assetSecondBuy, 5.0);

      // Quantité totale : 10 + 5 = 15
      // PMPA attendu = (10 * 100 + 5 * 160) / (10 + 5) = (1000 + 800) / 15 = 1800 / 15 = 120 €
      expect(portfolioController.positions.length, equals(1));
      final pos = portfolioController.positions.first;
      expect(pos.quantity, closeTo(15.0, 0.001));
      expect(pos.averagePurchasePrice, closeTo(120.0, 0.001));

      // Calcul des métriques avec cours actuel à 160 €
      // Valeur totale = 15 * 160 = 2400 €
      // Montant investi = 15 * 120 = 1800 €
      // Plus-value = 2400 - 1800 = 600 €
      // Performance = ((2400 - 1800) / 1800) * 100 = (600 / 1800) * 100 = 33.333 %
      expect(portfolioController.totalValue, closeTo(2400.0, 0.001));
      expect(portfolioController.totalInvested, closeTo(1800.0, 0.001));
      expect(portfolioController.totalCapitalGain, closeTo(600.0, 0.001));
      expect(portfolioController.totalPerformance, closeTo(33.333, 0.01));
    });

    test('Portefeuille multi-actifs : calcul correct de la valeur globale et plus-value', () async {
      // Achat NVDA : 2 * 130 = 260 €
      await portfolioController.buyAsset(assetNvda, 2.0);
      // Achat AAPL : 1 * 220 = 220 €
      await portfolioController.buyAsset(assetAapl, 1.0);

      expect(portfolioController.positions.length, equals(2));
      expect(portfolioController.totalInvested, closeTo(480.0, 0.001));
      expect(portfolioController.totalValue, closeTo(480.0, 0.001));
    });

    test('Mise à jour des cours via updateAssetPrices', () {
      portfolioController = PortfolioController(
        cacheService: cacheService,
        initialPositions: [
          PortfolioPosition(
            asset: assetNvda, // currentPrice = 130.0
            quantity: 10.0,
            averagePurchasePrice: 100.0,
          )
        ],
      );

      // Le cours de NVDA passe à 150 €
      final updatedNvda = Asset(
        symbol: 'NVDA',
        name: 'NVIDIA Corporation',
        currentPrice: 150.0,
        type: 'Stock',
        description: 'Puces IA',
        marketOpen: true,
        timezone: 'US/Eastern',
        timeSeries: {},
      );

      portfolioController.updateAssetPrices({'NVDA': updatedNvda});

      expect(portfolioController.totalValue, closeTo(1500.0, 0.001));
      expect(portfolioController.totalInvested, closeTo(1000.0, 0.001));
      expect(portfolioController.totalCapitalGain, closeTo(500.0, 0.001));
      expect(portfolioController.totalPerformance, closeTo(50.0, 0.001));
    });

    test('Persistance CacheService : chargement des positions après sauvegarde', () async {
      await portfolioController.buyAsset(assetNvda, 3.0);

      // Nouveau contrôleur lisant la même fausse mémoire
      final newController = PortfolioController(cacheService: cacheService);
      await newController.loadPositions();

      expect(newController.positions.length, equals(1));
      expect(newController.positions.first.asset.symbol, equals('NVDA'));
      expect(newController.positions.first.quantity, closeTo(3.0, 0.001));
    });
  });
}
