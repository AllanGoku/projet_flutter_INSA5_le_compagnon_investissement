// [AI-GENERATED] Phase 2, Agent, 2025-02-23
import 'package:flutter/foundation.dart';
import '../models/asset.dart';
import '../models/portfolio_position.dart';
import '../models/financial_calculator.dart';
import '../services/cache_service.dart';

/// Contrôleur gérant l'état applicatif du portefeuille fictif.
///
/// Implémente `ChangeNotifier` dans le cadre de l'architecture MVC pour notifier les vues
/// lors de tout changement d'état (achat d'actif, mise à jour des cours, chargement).
/// Assure le calcul en temps réel des métriques financières (valeur totale, montant investi,
/// plus-values et performance %) en s'appuyant sur [FinancialCalculator].
class PortfolioController extends ChangeNotifier {
  final CacheService cacheService;

  List<PortfolioPosition> _positions = [];
  bool _isLoading = false;

  PortfolioController({
    required this.cacheService,
    List<PortfolioPosition>? initialPositions,
  }) {
    if (initialPositions != null) {
      _positions = List.from(initialPositions);
    }
  }

  /// Liste immuable des positions actuellement détenues dans le portefeuille.
  List<PortfolioPosition> get positions => List.unmodifiable(_positions);

  /// Indique si les données du portefeuille sont en cours de chargement depuis SQLite.
  bool get isLoading => _isLoading;

  /// Charge de façon asynchrone les positions du portefeuille depuis le stockage local SQLite.
  ///
  /// Cette méthode doit être appelée lors de l'initialisation de l'écran principal
  /// pour restaurer les achats de l'utilisateur.
  Future<void> loadPositions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _positions = await cacheService.getPortfolioPositions();
    } catch (e) {
      debugPrint("Erreur lors du chargement du portefeuille: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Exécute un achat d'actif fictif avec la [quantity] spécifiée.
  ///
  /// **Algorithme du Prix Moyen Pondéré d'Achat (PMPA) :**
  /// Lorsqu'un actif est déjà présent dans le portefeuille, la nouvelle quantité est cumulée
  /// (`q_totale = q1 + q2`) et le PMPA est recalculé selon la formule :
  /// `PMPA = ((q1 * p1) + (q2 * p2)) / (q1 + q2)`
  /// où `p1` est l'ancien PMPA et `p2` est le cours d'achat actuel de l'actif [asset.currentPrice].
  ///
  /// Ce calcul garantit la conservation exacte de la valeur d'achat historique globale.
  /// Les modifications sont immédiatement sauvegardées en SQLite via [CacheService].
  Future<void> buyAsset(Asset asset, double quantity) async {
    if (quantity <= 0.0) return;

    final index = _positions.indexWhere(
      (pos) => pos.asset.symbol.toUpperCase() == asset.symbol.toUpperCase(),
    );

    if (index != -1) {
      // Actif déjà détenu : cumul de quantité et recalcul du PMPA
      final existingPos = _positions[index];
      final double q1 = existingPos.quantity;
      final double p1 = existingPos.averagePurchasePrice;
      final double q2 = quantity;
      final double p2 = asset.currentPrice;

      final double newQuantity = q1 + q2;
      final double newPmpa = ((q1 * p1) + (q2 * p2)) / newQuantity;

      _positions[index] = PortfolioPosition(
        asset: asset, // Mise à jour avec la dernière version de l'actif
        quantity: newQuantity,
        averagePurchasePrice: newPmpa,
      );
    } else {
      // Nouvel actif : création d'une nouvelle ligne dans le portefeuille
      _positions.add(PortfolioPosition(
        asset: asset,
        quantity: quantity,
        averagePurchasePrice: asset.currentPrice,
      ));
    }

    // Persistance automatique dans SQLite
    await cacheService.savePortfolioPositions(_positions);
    notifyListeners();
  }

  /// Met à jour les cours des actifs contenus dans le portefeuille.
  ///
  /// Utilisé lorsque [DataController] récupère de nouveaux cours depuis l'API Twelve Data.
  /// pour réévaluer la valeur courante du portefeuille sans altérer le PMPA d'achat.
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

  /// Valeur totale courante du portefeuille fictif (€).
  ///
  /// Calcule la somme de `quantité * prix_actuel` pour toutes les positions.
  /// Retourne 0.0 si le portefeuille est vide.
  double get totalValue {
    if (_positions.isEmpty) return 0.0;
    final mapPositions = _positions.map((pos) => {
      'quantity': pos.quantity,
      'currentPrice': pos.asset.currentPrice,
    }).toList();

    return FinancialCalculator.calculatePortfolioValue(mapPositions);
  }

  /// Montant total engagé / investi dans le portefeuille (€).
  ///
  /// Calcule la somme de `quantité * prix_achat_moyen` pour toutes les positions.
  /// Retourne 0.0 si le portefeuille est vide.
  double get totalInvested {
    if (_positions.isEmpty) return 0.0;
    final mapPositions = _positions.map((pos) => {
      'quantity': pos.quantity,
      'averagePurchasePrice': pos.averagePurchasePrice,
    }).toList();

    return FinancialCalculator.calculateTotalInvested(mapPositions);
  }

  /// Plus-value ou moins-value globale absolue (€).
  ///
  /// Différence entre la valeur actuelle et le montant total investi.
  double get totalCapitalGain {
    if (_positions.isEmpty) return 0.0;
    return FinancialCalculator.calculateCapitalGain(
      investedAmount: totalInvested,
      currentValue: totalValue,
    );
  }

  /// Performance globale du portefeuille en pourcentage (%).
  ///
  /// Calculée par `((totalValue - totalInvested) / totalInvested) * 100`.
  /// Retourne 0.0 si le montant investi est nul ou si le portefeuille est vide.
  double get totalPerformance {
    if (_positions.isEmpty) return 0.0;
    return FinancialCalculator.calculatePerformance(
      initialValue: totalInvested,
      currentValue: totalValue,
    );
  }
}
