// [AI-GENERATED] Migration Twelve Data, Agent, 2025-02-23
import 'package:flutter/foundation.dart';

import 'data_state.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../models/asset.dart';

/// Contrôleur gérant la récupération, la mise en cache SQLite et la distribution des données
/// financières réelles de l'application.
/// Gère explicitement l'état de chargement et le quota restreint de l'API (25 appels/jour).
class DataController extends ChangeNotifier {
  final ApiService apiService;
  final CacheService cacheService;

  DataState _state = DataState.initial;
  String _errorMessage = '';

  // Dictionnaire local des actifs réels récupérés depuis SQLite ou l'API
  final Map<String, Asset> _assets = {};

  DataController({required this.apiService, required this.cacheService});

  DataState get state => _state;
  String get errorMessage => _errorMessage;
  Map<String, Asset> get assets => Map.unmodifiable(_assets);

  /// Met à jour l'état interne et notifie les écouteurs (vues).
  void _setState(DataState newState, {String error = ''}) {
    _state = newState;
    _errorMessage = error;
    notifyListeners();
  }

  /// Charge tous les actifs actuellement enregistrés en base de données SQLite dans la mémoire locale.
  Future<void> loadAllCachedAssets() async {
    try {
      final cachedList = await cacheService.getAllAssets();
      for (var asset in cachedList) {
        _assets[asset.symbol] = asset;
      }
      if (_assets.isNotEmpty) {
        _state = DataState.success;
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur lors du chargement initial du cache SQLite: $e");
    }
  }

  /// Récupère 60 actifs réels du marché en **1 seul appel API** (TOP_GAINERS_LOSERS).
  ///
  /// Économise le quota quotidien (25 requêtes/jour) tout en alimentant SQLite.
  Future<void> loadTopMarketMovers() async {
    _setState(DataState.loading);
    try {
      final fetchedAssets = await apiService.fetchTopGainersLosers();
      for (var asset in fetchedAssets) {
        await cacheService.saveAsset(asset);
        _assets[asset.symbol] = asset;
      }
      _setState(DataState.success);
    } catch (e) {
      debugPrint("Info API Market Movers: $e");
      // S'il n'y a aucun actif dans le cache pour compenser l'erreur API, afficher l'erreur
      if (_assets.isEmpty) {
        _setState(
          DataState.error,
          error: e.toString().replaceAll('Exception: ', ''),
        );
      } else {
        _setState(
          DataState.offline,
          error:
              'Impossible de récupérer les mouvements de marché : ${e.toString().replaceAll('Exception: ', '')}',
        );
      }
    }
  }

  /// Charge un actif spécifique depuis SQLite ou l'API Twelve Data.
  ///
  /// Si la donnée en cache est une graine initiale (`timeSeries` vide ou `lastUpdated == 0`),
  /// force l'appel à l'API Twelve Data pour récupérer les vraies données de marché.
  Future<void> loadAsset(
    String symbol, {
    bool isHot = false,
    String? name,
    String? type,
    String? description,
  }) async {
    _setState(DataState.loading);

    try {
      final cachedAsset = await cacheService.getAsset(symbol);
      if (cachedAsset != null) {
        _assets[symbol] = cachedAsset;
      }

      final lastUpdated = await cacheService.getLastUpdated(symbol);
      final now = DateTime.now();

      bool needsRefresh = true;

      if (cachedAsset != null && lastUpdated != null) {
        final difference = now.difference(lastUpdated);
        final threshold = const Duration(hours: 24);

        // N'utiliser le cache SQLite sans appel API que si l'actif contient l'historique complet API
        // et que la dernière mise à jour date de moins de 24h.
        if (cachedAsset.timeSeries.isNotEmpty &&
            difference < threshold &&
            lastUpdated.millisecondsSinceEpoch > 0) {
          needsRefresh = false;
        }
      }

      if (needsRefresh) {
        try {
          final asset = await apiService.fetchAssetData(
            symbol,
            name: name ?? cachedAsset?.name ?? symbol,
            type: type ?? cachedAsset?.type ?? 'Stock',
            description: description ?? cachedAsset?.description ?? '',
          );
          await cacheService.saveAsset(asset);
          _assets[symbol] = asset;
          _setState(DataState.success);
        } catch (apiError) {
          debugPrint(
            "Erreur API lors de la récupération de $symbol : $apiError",
          );
          // Si l'API échoue ou quota atteint, conserver la donnée locale SQLite
          if (_assets.containsKey(symbol)) {
            _setState(
              DataState.offline,
              error:
                  'Données hors-connexion. Erreur: ${apiError.toString().replaceAll('Exception: ', '')}',
            );
          } else {
            _setState(
              DataState.error,
              error: apiError.toString().replaceAll('Exception: ', ''),
            );
          }
        }
      } else {
        // Le cache SQLite réel est valide
        _setState(DataState.success);
      }
    } catch (e) {
      _setState(DataState.error, error: 'Erreur système: $e');
    }
  }

  /// Rafraîchit un actif spécifique en forçant l'appel à l'API si [force] est à true.
  Future<void> refreshAsset(
    String symbol, {
    bool force = false,
    String? name,
    String? type,
    String? description,
  }) async {
    if (force) {
      _setState(DataState.loading);
      try {
        final cached = _assets[symbol];
        final asset = await apiService.fetchAssetData(
          symbol,
          name: name ?? cached?.name ?? symbol,
          type: type ?? cached?.type ?? 'Stock',
          description: description ?? cached?.description ?? '',
        );
        await cacheService.saveAsset(asset);
        _assets[symbol] = asset;
        _setState(DataState.success);
      } catch (apiError) {
        debugPrint(
          "Erreur API lors du rafraîchissement de $symbol : $apiError",
        );
        if (_assets.containsKey(symbol)) {
          _setState(
            DataState.offline,
            error:
                'Données hors-connexion. Erreur: ${apiError.toString().replaceAll('Exception: ', '')}',
          );
        } else {
          _setState(
            DataState.error,
            error: apiError.toString().replaceAll('Exception: ', ''),
          );
        }
      }
    } else {
      await loadAsset(
        symbol,
        isHot: true,
        name: name,
        type: type,
        description: description,
      );
    }
  }

  /// Rafraîchit l'ensemble des symboles d'actifs spécifiés dans [symbols].
  Future<void> refreshAll(List<String> symbols, {bool force = false}) async {
    for (var symbol in symbols) {
      await refreshAsset(symbol, force: force);
    }
  }
}
