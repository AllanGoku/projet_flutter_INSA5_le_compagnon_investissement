// [AI-GENERATED] Phase 9, Agent, 2025-02-23
import 'dart:async';
import 'package:flutter/foundation.dart';

import 'data_state.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../models/asset.dart';

/// Élément représentant une requête de mise à jour d'actif dans la file d'attente.
class _QueueItem {
  final String symbol;
  final bool isHot;
  final String? name;
  final String? type;
  final String? description;
  final bool force;
  final Completer<void> completer;

  _QueueItem({
    required this.symbol,
    this.isHot = false,
    this.name,
    this.type,
    this.description,
    this.force = false,
    required this.completer,
  });
}

/// Contrôleur gérant la récupération, la mise en cache SQLite et la distribution des données
/// financières réelles de l'application avec gestion du Rate-Limiting et file d'attente échelonnée.
///
/// Implémente la stratégie Cache-First (Stale-While-Revalidate) et respecte le quota d'API (8 req/min max).
class DataController extends ChangeNotifier {
  final ApiService apiService;
  final CacheService cacheService;

  DataState _state = DataState.initial;
  String _errorMessage = '';

  // Dictionnaire local des actifs réels récupérés depuis SQLite ou l'API
  final Map<String, Asset> _assets = {};

  // File d'attente échelonnée pour respecter le Rate-Limiting
  final List<_QueueItem> _queue = [];
  final Set<String> _refreshingSymbols = {};
  DateTime? _lastApiCallTime;
  bool _isProcessingQueue = false;

  DataController({required this.apiService, required this.cacheService});

  DataState get state => _state;
  String get errorMessage => _errorMessage;
  Map<String, Asset> get assets => Map.unmodifiable(_assets);

  /// Indique le nombre de requêtes actuellement en attente dans la file échelonnée.
  int get queueLength => _queue.length;

  /// Indique si un actif spécifique est actuellement en cours de rafraîchissement réseau.
  bool isSymbolRefreshing(String symbol) => _refreshingSymbols.contains(symbol);

  /// Ensemble non modifiable des symboles actuellement en cours de rafraîchissement.
  Set<String> get refreshingSymbols => Set.unmodifiable(_refreshingSymbols);

  /// Met à jour l'état interne et notifie les écouteurs (vues).
  void _setState(DataState newState, {String error = ''}) {
    _state = newState;
    _errorMessage = error;
    notifyListeners();
  }

  /// Charge tous les actifs actuellement enregistrés en base de données SQLite dans la mémoire locale.
  /// Initialise un catalogue de 8 actifs majeurs par défaut au premier démarrage si le cache est vide.
  Future<void> loadAllCachedAssets() async {
    try {
      final cachedList = await cacheService.getAllAssets();
      for (var asset in cachedList) {
        _assets[asset.symbol] = asset;
      }
      if (_assets.isEmpty) {
        await seedDefaultAssetsIfNeeded();
      } else {
        if (_state != DataState.success) {
          _state = DataState.success;
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Erreur lors du chargement initial du cache SQLite: $e");
      if (_assets.isEmpty) {
        await seedDefaultAssetsIfNeeded();
      }
    }
  }

  /// Initialise et sauvegarde un catalogue de 5 actifs réalistes (AAPL, MSFT, AMZN, NVDA, IBM) si le cache est vide.
  Future<void> seedDefaultAssetsIfNeeded() async {
    if (_assets.isNotEmpty) return;

    final defaultList = [
      Asset(
        symbol: 'AAPL',
        name: 'Apple Inc.',
        currentPrice: 175.50,
        type: 'Stock',
        description:
            'Leader mondial des technologies grand public et des services informatiques.',
        marketOpen: true,
        timezone: 'US/Eastern',
        timeSeries: {},
        lastUpdated: DateTime.now(),
      ),
      Asset(
        symbol: 'MSFT',
        name: 'Microsoft Corp.',
        currentPrice: 380.00,
        type: 'Stock',
        description:
            'Éditeur de logiciels, services cloud Azure et intelligence artificielle.',
        marketOpen: true,
        timezone: 'US/Eastern',
        timeSeries: {},
        lastUpdated: DateTime.now(),
      ),
      Asset(
        symbol: 'AMZN',
        name: 'Amazon.com Inc.',
        currentPrice: 175.00,
        type: 'Stock',
        description: 'Géant mondial du e-commerce et des services cloud AWS.',
        marketOpen: true,
        timezone: 'US/Eastern',
        timeSeries: {},
        lastUpdated: DateTime.now(),
      ),
      Asset(
        symbol: 'NVDA',
        name: 'NVIDIA Corp.',
        currentPrice: 850.00,
        type: 'Stock',
        description:
            'Concepteur majeur de processeurs pour l\'intelligence artificielle.',
        marketOpen: true,
        timezone: 'US/Eastern',
        timeSeries: {},
        lastUpdated: DateTime.now(),
      ),
      Asset(
        symbol: 'IBM',
        name: 'IBM Corp.',
        currentPrice: 185.00,
        type: 'Stock',
        description:
            'Multinationale des services informatiques, du conseil et du cloud hybride.',
        marketOpen: true,
        timezone: 'US/Eastern',
        timeSeries: {},
        lastUpdated: DateTime.now(),
      ),
    ];

    for (var asset in defaultList) {
      _assets[asset.symbol] = asset;
      try {
        await cacheService.saveAsset(asset);
      } catch (e) {
        debugPrint(
          "Erreur lors de la sauvegarde initiale de ${asset.symbol}: $e",
        );
      }
    }
    _state = DataState.success;
    notifyListeners();
  }

  /// Récupère 60 actifs réels du marché en **1 seul appel API** (TOP_GAINERS_LOSERS).
  ///
  /// Économise le quota quotidien (25 requêtes/jour) tout en alimentant SQLite.
  Future<void> loadTopMarketMovers() async {
    _setState(DataState.loading);
    try {
      final fetchedAssets = await apiService.fetchTopGainersLosers();
      _lastApiCallTime = DateTime.now();
      for (var asset in fetchedAssets) {
        await cacheService.saveAsset(asset);
        _assets[asset.symbol] = asset;
      }
      _setState(DataState.success);
    } catch (e) {
      debugPrint("Info API Market Movers: $e");
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

  /// Charge un actif spécifique en appliquant la stratégie Cache-First (Stale-While-Revalidate).
  ///
  /// Chargement immédiat depuis le cache SQLite s'il est disponible, puis mise en file d'attente
  /// échelonnée pour rafraîchissement en arrière-plan si la donnée est obsolète (> 24h) ou si [isHot] est vrai.
  Future<void> loadAsset(
    String symbol, {
    bool isHot = false,
    String? name,
    String? type,
    String? description,
  }) async {
    // Passer immédiatement en état loading si aucun actif n'est en mémoire
    if (_assets.isEmpty && _state == DataState.initial) {
      _setState(DataState.loading);
    }

    // 1. Affichage immédiat du cache SQLite si disponible
    if (!_assets.containsKey(symbol)) {
      try {
        final cachedAsset = await cacheService.getAsset(symbol);
        if (cachedAsset != null) {
          _assets[symbol] = cachedAsset;
          if (_state != DataState.success) {
            _setState(DataState.success);
          } else {
            notifyListeners();
          }
        }
      } catch (e) {
        debugPrint("Erreur de lecture du cache pour $symbol: $e");
      }
    }

    final cachedAsset = _assets[symbol];
    final lastUpdated =
        cachedAsset?.lastUpdated ?? await cacheService.getLastUpdated(symbol);
    final now = DateTime.now();

    bool needsRefresh = false;

    if (cachedAsset == null ||
        lastUpdated == null ||
        cachedAsset.timeSeries.isEmpty ||
        lastUpdated.millisecondsSinceEpoch == 0) {
      needsRefresh = true;
    } else {
      final difference = now.difference(lastUpdated);
      final threshold =
          isHot ? const Duration(minutes: 15) : const Duration(hours: 24);
      if (difference >= threshold) {
        needsRefresh = true;
      }
    }

    if (!needsRefresh) {
      if (_state != DataState.success) {
        _setState(DataState.success);
      }
      return;
    }

    // Si aucune donnée locale n'est disponible et que l'état est initial, passer en chargement
    if (_assets.isEmpty && _state == DataState.initial) {
      _setState(DataState.loading);
    }

    // 2. Ajouter la requête dans la file d'attente API échelonnée
    return _enqueueRequest(
      symbol: symbol,
      isHot: isHot,
      name: name,
      type: type,
      description: description,
    );
  }

  /// Rafraîchit un actif spécifique en forçant le passage prioritaire en file d'attente.
  Future<void> refreshAsset(
    String symbol, {
    bool force = false,
    String? name,
    String? type,
    String? description,
  }) async {
    return _enqueueRequest(
      symbol: symbol,
      isHot: true,
      name: name,
      type: type,
      description: description,
      force: force,
    );
  }

  /// Rafraîchit l'ensemble des symboles spécifiés en arrière-plan avec échelonnement.
  Future<void> refreshAll(List<String> symbols, {bool force = false}) async {
    for (var symbol in symbols) {
      await refreshAsset(symbol, force: force);
    }
  }

  /// Ajoute une requête à la file d'attente échelonnée (Haute priorité si [isHot] est true).
  Future<void> _enqueueRequest({
    required String symbol,
    bool isHot = false,
    String? name,
    String? type,
    String? description,
    bool force = false,
  }) {
    final existingIndex = _queue.indexWhere((item) => item.symbol == symbol);
    if (existingIndex != -1) {
      final existingItem = _queue[existingIndex];
      if (isHot && !existingItem.isHot) {
        _queue.removeAt(existingIndex);
        final newItem = _QueueItem(
          symbol: symbol,
          isHot: true,
          name: name ?? existingItem.name,
          type: type ?? existingItem.type,
          description: description ?? existingItem.description,
          force: force || existingItem.force,
          completer: existingItem.completer,
        );
        _queue.insert(0, newItem);
      }
      _processQueue();
      return existingItem.completer.future;
    }

    final completer = Completer<void>();
    final newItem = _QueueItem(
      symbol: symbol,
      isHot: isHot,
      name: name,
      type: type,
      description: description,
      force: force,
      completer: completer,
    );

    if (isHot) {
      _queue.insert(0, newItem);
    } else {
      _queue.add(newItem);
    }

    _processQueue();
    return completer.future;
  }

  /// Boucle d'exécution échelonnée respectant les contraintes de délai minimum entre requêtes API.
  Future<void> _processQueue() async {
    if (_isProcessingQueue) return;
    _isProcessingQueue = true;

    while (_queue.isNotEmpty) {
      final item = _queue.removeAt(0);

      final minDelay = item.isHot
          ? const Duration(seconds: 8)
          : const Duration(seconds: 15);

      if (_lastApiCallTime != null) {
        final elapsed = DateTime.now().difference(_lastApiCallTime!);
        if (elapsed < minDelay) {
          final waitTime = minDelay - elapsed;
          await Future.delayed(waitTime);
        }
      }

      _refreshingSymbols.add(item.symbol);
      notifyListeners();

      try {
        final cached = _assets[item.symbol];
        final asset = await apiService.fetchAssetData(
          item.symbol,
          name: item.name ?? cached?.name ?? item.symbol,
          type: item.type ?? cached?.type ?? 'Stock',
          description: item.description ?? cached?.description ?? '',
        );
        _lastApiCallTime = DateTime.now();
        await cacheService.saveAsset(asset);
        _assets[item.symbol] = asset;
        _setState(DataState.success);
      } catch (apiError) {
        debugPrint(
          "Erreur API lors de la récupération de ${item.symbol} : $apiError",
        );
        if (_assets.containsKey(item.symbol)) {
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
      } finally {
        _refreshingSymbols.remove(item.symbol);
        notifyListeners();
        if (!item.completer.isCompleted) {
          item.completer.complete();
        }
      }
    }

    _isProcessingQueue = false;
  }
}
