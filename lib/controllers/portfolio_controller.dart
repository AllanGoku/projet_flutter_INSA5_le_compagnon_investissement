// [AI-GENERATED] Phase 4 & Multi-User Isolation, Agent, 2025-02-23
import 'package:flutter/foundation.dart';

import '../models/asset.dart';
import '../models/portfolio_position.dart';
import '../models/portfolio_transaction.dart';
import '../models/financial_calculator.dart';
import '../services/cache_service.dart';

/// Contrôleur gérant l'état applicatif du portefeuille fictif et du solde de liquidités.
/// Isolations des données par `userEmail` pour le multi-utilisateur.
class PortfolioController extends ChangeNotifier {
  final CacheService cacheService;

  List<PortfolioPosition> _positions = [];
  List<PortfolioTransaction> _transactions = [];
  double _totalRealizedGain = 0.0;
  double _cashBalance = 1000.0;
  bool _isLoading = false;
  String _userEmail = 'guest@app.local';

  PortfolioController({
    required this.cacheService,
    List<PortfolioPosition>? initialPositions,
    List<PortfolioTransaction>? initialTransactions,
    double? initialCashBalance,
  }) {
    if (initialPositions != null) {
      _positions = List.from(initialPositions);
    }
    if (initialTransactions != null) {
      _transactions = List.from(initialTransactions);
      _calculateRealizedGainFromTransactions();
    }
    if (initialCashBalance != null) {
      _cashBalance = initialCashBalance;
    }
  }

  /// Email de l'utilisateur actuellement actif.
  String get userEmail => _userEmail;

  /// Liste immuable des positions actuellement détenues dans le portefeuille.
  List<PortfolioPosition> get positions => List.unmodifiable(_positions);

  /// Liste immuable du journal des transactions effectuées.
  List<PortfolioTransaction> get transactions =>
      List.unmodifiable(_transactions);

  /// Cumul total des plus-values réalisées lors des reventes d'actifs (€).
  double get totalRealizedGain => _totalRealizedGain;

  /// Solde de liquidités disponibles en Euros (€).
  double get cashBalance => _cashBalance;

  /// Indique si les données du portefeuille sont en cours de chargement depuis SQLite.
  bool get isLoading => _isLoading;

  /// Recalcule le cumul des plus-values réalisées à partir de la liste des transactions de revente.
  void _calculateRealizedGainFromTransactions() {
    _totalRealizedGain = _transactions
        .where((t) => t.isSell && t.realizedGain != null)
        .fold(0.0, (sum, t) => sum + (t.realizedGain ?? 0.0));
  }

  /// Charge de façon asynchrone les positions, transactions et liquidités depuis SQLite pour un `userEmail`.
  Future<void> loadPositions([String? userEmail]) async {
    if (userEmail != null && userEmail.isNotEmpty) {
      _userEmail = userEmail;
      try {
        await cacheService.migrateLegacyDataIfNeeded(_userEmail);
      } catch (_) {}
    }
    _isLoading = true;
    notifyListeners();

    try {
      _positions = await cacheService.getPortfolioPositions(_userEmail);
      _transactions = await cacheService.getTransactions(_userEmail);
      _cashBalance = await cacheService.getCashBalance(_userEmail);
      _calculateRealizedGainFromTransactions();
    } catch (e) {
      debugPrint("Erreur lors du chargement du portefeuille: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Réinitialise complètement le portefeuille d'un utilisateur (positions, transactions, cash initial).
  Future<void> resetPortfolio() async {
    _positions.clear();
    _transactions.clear();
    _totalRealizedGain = 0.0;
    _cashBalance = 1000.0;

    await cacheService.clearPortfolioAndTransactions(_userEmail);

    notifyListeners();
  }

  /// Exécute un achat d'actif fictif avec la [quantity] spécifiée.
  Future<void> buyAsset(Asset asset, double quantity) async {
    if (quantity <= 0.0) {
      throw ArgumentError('La quantité à acheter doit être supérieure à zéro.');
    }
    if ((quantity - quantity.round()).abs() > 0.0001) {
      throw ArgumentError(
        'L\'achat se fait uniquement par unités entières (pas de fractions).',
      );
    }

    final double totalCost = quantity * asset.currentPrice;
    if (totalCost > _cashBalance) {
      throw StateError(
        'Solde de liquidités insuffisant (${_cashBalance.toStringAsFixed(2)} € disponible vs ${totalCost.toStringAsFixed(2)} € requis).',
      );
    }

    final index = _positions.indexWhere(
      (pos) => pos.asset.symbol.toUpperCase() == asset.symbol.toUpperCase(),
    );

    if (index != -1) {
      final existingPos = _positions[index];
      final double q1 = existingPos.quantity;
      final double p1 = existingPos.averagePurchasePrice;
      final double q2 = quantity;
      final double p2 = asset.currentPrice;

      final double newQuantity = q1 + q2;
      final double newPmpa = ((q1 * p1) + (q2 * p2)) / newQuantity;

      _positions[index] = PortfolioPosition(
        asset: asset,
        quantity: newQuantity,
        averagePurchasePrice: newPmpa,
      );
    } else {
      _positions.add(
        PortfolioPosition(
          asset: asset,
          quantity: quantity,
          averagePurchasePrice: asset.currentPrice,
        ),
      );
    }

    // Débit du solde de liquidités
    _cashBalance -= totalCost;
    await cacheService.saveCashBalance(_cashBalance, _userEmail);

    // Création et enregistrement de la transaction d'achat
    final transaction = PortfolioTransaction(
      symbol: asset.symbol,
      assetName: asset.name,
      type: TransactionType.buy,
      quantity: quantity,
      price: asset.currentPrice,
      timestamp: DateTime.now(),
    );
    await cacheService.saveTransaction(transaction, _userEmail);
    _transactions.insert(0, transaction);

    // Persistance automatique des positions dans SQLite
    await cacheService.savePortfolioPositions(_positions, _userEmail);
    notifyListeners();
  }

  /// Exécute la revente partielle ou totale d'un actif fictif.
  Future<Map<String, dynamic>> sellAsset(Asset asset, double quantity) async {
    if (quantity <= 0.0) {
      throw ArgumentError('La quantité à vendre doit être supérieure à zéro.');
    }
    if ((quantity - quantity.round()).abs() > 0.0001) {
      throw ArgumentError(
        'La revente se fait uniquement par unités entières (pas de fractions).',
      );
    }

    final index = _positions.indexWhere(
      (pos) => pos.asset.symbol.toUpperCase() == asset.symbol.toUpperCase(),
    );

    if (index == -1) {
      throw StateError(
        'L\'actif ${asset.symbol} n\'est pas détenu dans le portefeuille.',
      );
    }

    final existingPos = _positions[index];
    if (quantity > existingPos.quantity) {
      throw ArgumentError(
        'Quantité à vendre ($quantity) supérieure à la quantité possédée (${existingPos.quantity}).',
      );
    }

    // Calcul de la performance et durée pour l'XP
    final double performancePercentage =
        FinancialCalculator.calculatePerformance(
          initialValue: existingPos.averagePurchasePrice * quantity,
          currentValue: asset.currentPrice * quantity,
        );

    final pastBuyTransactions = _transactions
        .where(
          (t) =>
              t.isBuy && t.symbol.toUpperCase() == asset.symbol.toUpperCase(),
        )
        .toList();

    DateTime firstBuyDate = DateTime.now();
    if (pastBuyTransactions.isNotEmpty) {
      firstBuyDate = pastBuyTransactions.last.timestamp;
    }
    final Duration holdingDuration = DateTime.now().difference(firstBuyDate);

    final double realizedGain = FinancialCalculator.calculateRealizedGain(
      sellPrice: asset.currentPrice,
      averagePurchasePrice: existingPos.averagePurchasePrice,
      quantity: quantity,
    );
    final double saleProceeds = quantity * asset.currentPrice;

    _totalRealizedGain += realizedGain;

    if (quantity >= existingPos.quantity) {
      _positions.removeAt(index);
      await cacheService.deletePortfolioPosition(asset.symbol, _userEmail);
    } else {
      final double newQuantity = existingPos.quantity - quantity;
      _positions[index] = PortfolioPosition(
        asset: asset,
        quantity: newQuantity,
        averagePurchasePrice: existingPos.averagePurchasePrice,
      );
      await cacheService.savePortfolioPositions(_positions, _userEmail);
    }

    _cashBalance += saleProceeds;
    await cacheService.saveCashBalance(_cashBalance, _userEmail);

    final transaction = PortfolioTransaction(
      symbol: asset.symbol,
      assetName: asset.name,
      type: TransactionType.sell,
      quantity: quantity,
      price: asset.currentPrice,
      timestamp: DateTime.now(),
      realizedGain: realizedGain,
    );
    await cacheService.saveTransaction(transaction, _userEmail);
    _transactions.insert(0, transaction);

    notifyListeners();

    return {
      'realizedGain': realizedGain,
      'performancePercentage': performancePercentage,
      'holdingDuration': holdingDuration,
    };
  }

  /// Met à jour les cours des actifs contenus dans le portefeuille.
  void updateAssetPrices(Map<String, Asset> updatedAssets) {
    bool hasChanged = false;

    for (int i = 0; i < _positions.length; i++) {
      final symbol = _positions[i].asset.symbol;
      if (updatedAssets.containsKey(symbol)) {
        final newAsset = updatedAssets[symbol]!;
        _positions[i] = PortfolioPosition(
          asset: newAsset,
          quantity: _positions[i].quantity,
          averagePurchasePrice: _positions[i].averagePurchasePrice,
        );
        hasChanged = true;
      }
    }

    if (hasChanged) {
      notifyListeners();
    }
  }

  /// Valeur totale courante des actifs détenus (€).
  double get totalValue {
    if (_positions.isEmpty) return 0.0;
    final mapPositions = _positions
        .map(
          (pos) => {
            'quantity': pos.quantity,
            'currentPrice': pos.asset.currentPrice,
          },
        )
        .toList();

    return FinancialCalculator.calculatePortfolioValue(mapPositions);
  }

  /// Montant total engagé / investi dans les actifs (€).
  double get totalInvested {
    if (_positions.isEmpty) return 0.0;
    final mapPositions = _positions
        .map(
          (pos) => {
            'quantity': pos.quantity,
            'averagePurchasePrice': pos.averagePurchasePrice,
          },
        )
        .toList();

    return FinancialCalculator.calculateTotalInvested(mapPositions);
  }

  /// Plus-value ou moins-value latente globale absolue (€).
  double get totalCapitalGain {
    if (_positions.isEmpty) return 0.0;
    return FinancialCalculator.calculateCapitalGain(
      investedAmount: totalInvested,
      currentValue: totalValue,
    );
  }

  /// Performance globale du portefeuille en pourcentage (%).
  double get totalPerformance {
    if (_positions.isEmpty) return 0.0;
    return FinancialCalculator.calculatePerformance(
      initialValue: totalInvested,
      currentValue: totalValue,
    );
  }
}
