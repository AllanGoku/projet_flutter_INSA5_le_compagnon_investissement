// [AI-GENERATED] Setup, Agent, 2025-02-23
import 'price_point.dart';

/// Modèle représentant un actif financier (Action, ETF, etc.).
///
/// Ce modèle typé est utilisé pour représenter les données récupérées
/// depuis l'API Alpha Vantage ou le stockage local. Il inclut les informations de base
/// nécessaires à l'affichage et aux calculs, ainsi que l'historique complet
/// OHLCV (PricePoint) pour l'affichage hors-connexion et les graphiques avancés.
class Asset {
  final String symbol;
  final String name;
  final double currentPrice;
  final String type;
  final String description;
  final bool marketOpen;
  
  /// Fuseau horaire du marché où l'actif est coté (ex: 'US/Eastern').
  final String timezone;
  
  /// Historique complet des cours (open, high, low, close, volume) associés aux horodatages.
  final Map<String, PricePoint> timeSeries;

  Asset({
    required this.symbol,
    required this.name,
    required this.currentPrice,
    required this.type,
    required this.description,
    required this.marketOpen,
    required this.timezone,
    required this.timeSeries,
  });

  /// Crée une instance [Asset] directement à partir de la réponse brute JSON de l'API Alpha Vantage.
  ///
  /// Extrait le symbole et le fuseau horaire depuis la section "Meta Data"
  /// et repère automatiquement la clé "Time Series (...)" quelle que soit l'intervalle.
  factory Asset.fromApiJson(
    Map<String, dynamic> json, {
    String name = '',
    String type = 'Stock',
    String description = '',
    bool marketOpen = true,
  }) {
    final metaData = json['Meta Data'] as Map<String, dynamic>? ?? {};
    final symbol = metaData['2. Symbol'] as String? ?? '';
    final timezone = metaData['6. Time Zone'] as String? ?? 'UTC';

    // Recherche dynamique de la clé Time Series (ex: "Time Series (5min)", "Time Series (Daily)", etc.)
    Map<String, dynamic>? timeSeriesMap;
    for (var entry in json.entries) {
      if (entry.key.startsWith('Time Series')) {
        timeSeriesMap = entry.value as Map<String, dynamic>?;
        break;
      }
    }

    final Map<String, PricePoint> timeSeries = {};
    double currentPrice = 0.0;

    if (timeSeriesMap != null && timeSeriesMap.isNotEmpty) {
      timeSeriesMap.forEach((timestamp, data) {
        if (data is Map<String, dynamic>) {
          timeSeries[timestamp] = PricePoint.fromApiJson(data);
        } else if (data is Map) {
          timeSeries[timestamp] = PricePoint.fromApiJson(data.cast<String, dynamic>());
        }
      });

      // Le premier élément renvoyé par l'API représente la donnée la plus récente
      final latestPoint = timeSeries.values.first;
      currentPrice = latestPoint.close;
    }

    return Asset(
      symbol: symbol,
      name: name.isNotEmpty ? name : symbol,
      currentPrice: currentPrice,
      type: type,
      description: description,
      marketOpen: marketOpen,
      timezone: timezone,
      timeSeries: timeSeries,
    );
  }

  /// Crée une instance [Asset] à partir d'une map JSON sérialisée en interne.
  factory Asset.fromJson(Map<String, dynamic> json) {
    final rawTimeSeries = json['timeSeries'] as Map?;
    final Map<String, PricePoint> parsedTimeSeries = {};

    if (rawTimeSeries != null) {
      rawTimeSeries.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          parsedTimeSeries[key.toString()] = PricePoint.fromJson(value);
        } else if (value is Map) {
          parsedTimeSeries[key.toString()] = PricePoint.fromJson(value.cast<String, dynamic>());
        }
      });
    }

    return Asset(
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      currentPrice: (json['currentPrice'] as num).toDouble(),
      type: json['type'] as String,
      description: json['description'] as String,
      marketOpen: json['marketOpen'] as bool,
      timezone: json['timezone'] as String? ?? 'UTC',
      timeSeries: parsedTimeSeries,
    );
  }

  /// Sérialise l'instance [Asset] en une map JSON standard pour la persistance locale.
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'currentPrice': currentPrice,
      'type': type,
      'description': description,
      'marketOpen': marketOpen,
      'timezone': timezone,
      'timeSeries': timeSeries.map((key, value) => MapEntry(key, value.toJson())),
    };
  }
}
