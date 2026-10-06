// [AI-GENERATED] Issue #2, Agent, 2024-05-24
import 'package:flutter/foundation.dart';
import 'data_state.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../models/asset.dart';

/// Contrôleur gérant la récupération, la mise en cache et la distribution des données
/// financières de l'application. 
/// Gère explicitement l'état de chargement pour répercussion sur la vue (MVC).
class DataController extends ChangeNotifier {
  final ApiService apiService;
  final CacheService cacheService;

  DataState _state = DataState.initial;
  String _errorMessage = '';
  
  // Dictionnaire local des actifs en cours de consultation / possédés
  final Map<String, Asset> _assets = {};

  DataController({
    required this.apiService,
    required this.cacheService,
  });

  DataState get state => _state;
  String get errorMessage => _errorMessage;
  Map<String, Asset> get assets => _assets;

  /// Met à jour l'état interne et notifie les écouteurs (vues).
  void _setState(DataState newState, {String error = ''}) {
    _state = newState;
    _errorMessage = error;
    notifyListeners();
  }

  /// Charge un actif spécifique.
  /// 
  /// Vérifie d'abord le cache. Si le cache est expiré ou absent, appelle l'API.
  /// Un système de rafraîchissement espacé est utilisé :
  /// - 10 minutes d'expiration pour les données "chaudes" (ex: vues principales, actifs détenus)
  /// - 1 heure d'expiration pour le reste.
  Future<void> loadAsset(String symbol, {bool isHot = false}) async {
    _setState(DataState.loading);

    try {
      final cachedAsset = await cacheService.getAsset(symbol);
      final lastUpdated = await cacheService.getLastUpdated(symbol);
      final now = DateTime.now();

      bool needsRefresh = true;

      if (cachedAsset != null && lastUpdated != null) {
        final difference = now.difference(lastUpdated);
        final threshold = isHot ? const Duration(minutes: 10) : const Duration(hours: 1);

        if (difference < threshold) {
          needsRefresh = false;
        }
      }

      if (needsRefresh) {
        try {
          final asset = await apiService.fetchAssetData(symbol);
          await cacheService.saveAsset(asset);
          _assets[symbol] = asset;
          _setState(DataState.success);
        } catch (apiError) {
          // Si l'API échoue, on tente d'utiliser le cache comme solution de secours.
          if (cachedAsset != null) {
            _assets[symbol] = cachedAsset;
            _setState(DataState.offline, error: 'Données hors-connexion. Impossible d\'actualiser.');
          } else {
            _setState(DataState.error, error: apiError.toString());
          }
        }
      } else {
        // Le cache est toujours valide
        _assets[symbol] = cachedAsset!;
        _setState(DataState.success);
      }
    } catch (e) {
      _setState(DataState.error, error: 'Erreur système: $e');
    }
  }
}
