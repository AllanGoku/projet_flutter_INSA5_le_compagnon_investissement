// [AI-GENERATED] Migration Twelve Data, Agent, 2025-02-23
import 'price_point.dart';

/// Modèle représentant un actif financier (Action, ETF, etc.).
///
/// Ce modèle typé est utilisé pour représenter les données récupérées
/// depuis l'API Alpha Vantage ou le stockage local. Il inclut les informations de base
/// nécessaires à l'affichage et aux calculs, ainsi que l'historique complet
/// OHLCV (PricePoint) pour l'affichage hors-connexion et la variation en pourcentage.
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

  /// Variation en pourcentage (%) optionnelle ou explicite de l'actif.
  final double? changePercentage;
  
  /// La devise d'origine de l'actif (ex: USD, EUR).
  final String originalCurrency;
  
  /// Le prix dans la devise d'origine, avant conversion en Euros.
  final double originalPrice;

  Asset({
    required this.symbol,
    required this.name,
    required this.currentPrice,
    required this.type,
    required this.description,
    required this.marketOpen,
    required this.timezone,
    required this.timeSeries,
    this.changePercentage,
    this.originalCurrency = 'EUR',
    this.originalPrice = 0.0,
  });

  /// Calcule la variation quotidienne/récente (%) de l'actif.
  ///
  /// Si [changePercentage] est défini explicitement, l'utilise en priorité.
  /// Sinon, si l'historique [timeSeries] contient au moins 2 points, calcule :
  /// `((dernier_cours - cours_precedent) / cours_precedent) * 100`.
  double get dailyChangePercentage {
    if (changePercentage != null) return changePercentage!;
    if (timeSeries.length >= 2) {
      final points = timeSeries.values.toList();
      final double latestPrice = points[0].close;
      final double previousPrice = points[1].close;
      if (previousPrice != 0.0) {
        return ((latestPrice - previousPrice) / previousPrice) * 100;
      }
    }
    return 0.0;
  }

  /// Crée une instance [Asset] directement à partir de la réponse brute JSON de l'API Twelve Data.
  ///
  /// Le JSON combiné contient 'time_series' (données de l'endpoint /time_series) 
  /// et 'quote' (données de l'endpoint /quote).
  factory Asset.fromApiJson(
    Map<String, dynamic> json, {
    String name = '',
    String type = 'Stock',
    String description = '',
    bool marketOpen = true,
  }) {
    final timeSeriesMap = json['time_series'] as Map<String, dynamic>? ?? {};
    final quoteMap = json['quote'] as Map<String, dynamic>? ?? {};

    final metaData = timeSeriesMap['meta'] as Map<String, dynamic>? ?? {};
    final symbol = metaData['symbol'] as String? ?? quoteMap['symbol'] as String? ?? '';
    final timezone = metaData['exchange_timezone'] as String? ?? quoteMap['exchange_timezone'] as String? ?? 'UTC';
    final originalCurrency = metaData['currency'] as String? ?? quoteMap['currency'] as String? ?? 'USD';

    // Taux de conversion statique vers l'Euro (EUR) pour une utilisation éducative 
    // afin d'économiser les requêtes API (1 appel = 1 crédit)
    double conversionRate = 1.0;
    if (originalCurrency == 'USD') {
      conversionRate = 0.92;
    } else if (originalCurrency == 'GBP') {
      conversionRate = 1.17;
    } else if (originalCurrency == 'CHF') {
      conversionRate = 1.05;
    } else if (originalCurrency == 'JPY') {
      conversionRate = 0.0061;
    } else if (originalCurrency == 'CNY') {
      conversionRate = 0.13;
    }

    final Map<String, PricePoint> timeSeries = {};
    double currentOriginalPrice = double.tryParse(quoteMap['close']?.toString() ?? '') ?? 0.0;
    double currentPrice = currentOriginalPrice * conversionRate;
    double? computedChange = double.tryParse(quoteMap['percent_change']?.toString() ?? '');

    final valuesList = timeSeriesMap['values'] as List? ?? [];
    for (var item in valuesList) {
      if (item is Map<String, dynamic> || item is Map) {
        final itemMap = item is Map<String, dynamic> ? item : item.cast<String, dynamic>();
        final timestamp = itemMap['datetime'] as String? ?? '';
        if (timestamp.isNotEmpty) {
          final originalPoint = PricePoint.fromApiJson(itemMap);
          timeSeries[timestamp] = PricePoint(
            open: originalPoint.open * conversionRate,
            high: originalPoint.high * conversionRate,
            low: originalPoint.low * conversionRate,
            close: originalPoint.close * conversionRate,
            volume: originalPoint.volume,
          );
        }
      }
    }

    return Asset(
      symbol: symbol,
      name: name.isNotEmpty ? name : (quoteMap['name'] as String? ?? symbol),
      currentPrice: currentPrice,
      type: type,
      description: description,
      marketOpen: marketOpen,
      timezone: timezone,
      timeSeries: timeSeries,
      changePercentage: computedChange,
      originalCurrency: originalCurrency,
      originalPrice: currentOriginalPrice,
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
      changePercentage: (json['changePercentage'] as num?)?.toDouble(),
      originalCurrency: json['originalCurrency'] as String? ?? 'EUR',
      originalPrice: (json['originalPrice'] as num?)?.toDouble() ?? (json['currentPrice'] as num).toDouble(),
    );
  }

  /// Sérialise l'instance [Asset] en une map JSON standard pour la persistance locale.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonMap = {
      'symbol': symbol,
      'name': name,
      'currentPrice': currentPrice,
      'type': type,
      'description': description,
      'marketOpen': marketOpen,
      'timezone': timezone,
      'timeSeries': timeSeries.map((key, value) => MapEntry(key, value.toJson())),
      'originalCurrency': originalCurrency,
      'originalPrice': originalPrice,
    };
    if (changePercentage != null) {
      jsonMap['changePercentage'] = changePercentage;
    }
    return jsonMap;
  }
}
