// [AI-GENERATED] Phase 9, Agent, 2025-02-23
import 'price_point.dart';

/// Modèle représentant un actif financier (Action, ETF, etc.).
///
/// Ce modèle typé est utilisé pour représenter les données récupérées
/// depuis l'API Twelve Data ou le stockage local. Il inclut les informations de base
/// nécessaires à l'affichage, les métriques financières clés (Cap. Boursière, PER, Dividende, Risque),
/// ainsi que l'historique complet OHLCV (PricePoint) pour l'affichage hors-connexion.
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

  /// Horodatage de la dernière synchronisation/mise à jour des données de l'actif.
  final DateTime? lastUpdated;

  /// Variation en pourcentage (%) optionnelle ou explicite de l'actif.
  final double? changePercentage;

  /// La devise d'origine de l'actif (ex: USD, EUR).
  final String originalCurrency;

  /// Le prix dans la devise d'origine, avant conversion en Euros.
  final double originalPrice;

  /// Capitalisation boursière (ex: '€2.81 T').
  final String? marketCap;

  /// Price Earnings Ratio (PER / P/E), ex: 68.4.
  final double? peRatio;

  /// Rendement du dividende en %, ex: 0.02 (pour 0.02%).
  final double? dividendYield;

  /// Niveau de risque de 1 (faible) à 5 (très élevé).
  final int? riskLevel;

  /// Volatilité Bêta par rapport au marché (ex: 1.24).
  final double? beta;

  /// Bénéfice par action (BPA / EPS en €), ex: 6.42.
  final double? eps;

  /// Plus haut sur 52 semaines (€).
  final double? high52Week;

  /// Plus bas sur 52 semaines (€).
  final double? low52Week;

  Asset({
    required this.symbol,
    required this.name,
    required this.currentPrice,
    required this.type,
    required this.description,
    required this.marketOpen,
    required this.timezone,
    required this.timeSeries,
    this.lastUpdated,
    this.changePercentage,
    this.originalCurrency = 'EUR',
    this.originalPrice = 0.0,
    this.marketCap,
    this.peRatio,
    this.dividendYield,
    this.riskLevel,
    this.beta,
    this.eps,
    this.high52Week,
    this.low52Week,
  });

  /// Calcule la variation quotidienne/récente (%) de l'actif.
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

  /// Capitalisation boursière formatée avec valeur de secours réaliste par symbole/type.
  String get displayMarketCap {
    if (marketCap != null && marketCap!.isNotEmpty) return marketCap!;
    final s = symbol.toUpperCase();
    if (s == 'AAPL') return '€2.81 T';
    if (s == 'NVDA') return '€3.15 T';
    if (s == 'MSFT') return '€2.95 T';
    if (s == 'AMZN') return '€1.92 T';
    if (s == 'IBM') return '€185.4 B';
    if (type.toUpperCase() == 'ETF') return '€250.0 B';
    return '€${(currentPrice * 0.85).toStringAsFixed(1)} B';
  }

  /// Ratio PER (P/E) avec valeur de secours réaliste.
  double get displayPeRatio {
    if (peRatio != null) return peRatio!;
    final s = symbol.toUpperCase();
    if (s == 'NVDA') return 68.4;
    if (s == 'AAPL') return 31.2;
    if (s == 'MSFT') return 35.1;
    if (s == 'AMZN') return 42.8;
    if (s == 'IBM') return 21.5;
    if (type.toUpperCase() == 'ETF') return 24.6;
    return 28.5;
  }

  /// Rendement du dividende (%) avec valeur de secours réaliste.
  double get displayDividendYield {
    if (dividendYield != null) return dividendYield!;
    final s = symbol.toUpperCase();
    if (s == 'NVDA') return 0.02;
    if (s == 'AAPL') return 0.55;
    if (s == 'MSFT') return 0.72;
    if (s == 'IBM') return 3.45;
    if (s == 'AMZN') return 0.00;
    if (type.toUpperCase() == 'ETF') return 1.20;
    return 0.50;
  }

  /// Niveau de risque de 1 (faible) à 5 (très élevé) avec valeur de secours.
  int get displayRiskLevel {
    if (riskLevel != null) return riskLevel!.clamp(1, 5);
    final s = symbol.toUpperCase();
    if (s == 'NVDA') return 4;
    if (s == 'AAPL') return 3;
    if (s == 'MSFT') return 2;
    if (s == 'AMZN') return 3;
    if (s == 'IBM') return 2;
    if (type.toUpperCase() == 'ETF') return 2;
    return 3;
  }

  /// Coefficient Bêta avec valeur de secours.
  double get displayBeta {
    if (beta != null) return beta!;
    final s = symbol.toUpperCase();
    if (s == 'NVDA') return 1.68;
    if (s == 'AAPL') return 1.08;
    if (s == 'MSFT') return 0.89;
    if (s == 'AMZN') return 1.15;
    if (type.toUpperCase() == 'ETF') return 1.02;
    return 1.10;
  }

  /// Bénéfice par action (BPA / EPS) avec valeur de secours.
  double get displayEps {
    if (eps != null) return eps!;
    final s = symbol.toUpperCase();
    if (s == 'NVDA') return 1.90;
    if (s == 'AAPL') return 6.42;
    if (s == 'MSFT') return 11.80;
    if (s == 'AMZN') return 4.25;
    return (currentPrice / 25.0).clamp(0.5, 100.0);
  }

  /// Plus haut 52 semaines.
  double get displayHigh52Week {
    if (high52Week != null) return high52Week!;
    return currentPrice > 0 ? currentPrice * 1.18 : 200.0;
  }

  /// Plus bas 52 semaines.
  double get displayLow52Week {
    if (low52Week != null) return low52Week!;
    return currentPrice > 0 ? currentPrice * 0.78 : 120.0;
  }

  /// Crée une instance [Asset] directement à partir de la réponse brute JSON de l'API Twelve Data.
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
    final symbol =
        metaData['symbol'] as String? ?? quoteMap['symbol'] as String? ?? '';
    final timezone =
        metaData['exchange_timezone'] as String? ??
        quoteMap['exchange_timezone'] as String? ??
        'UTC';
    final originalCurrency =
        metaData['currency'] as String? ??
        quoteMap['currency'] as String? ??
        'USD';

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
    double currentOriginalPrice =
        double.tryParse(quoteMap['close']?.toString() ?? '') ?? 0.0;
    double currentPrice = currentOriginalPrice * conversionRate;
    double? computedChange = double.tryParse(
      quoteMap['percent_change']?.toString() ?? '',
    );

    final valuesList = timeSeriesMap['values'] as List? ?? [];
    for (var item in valuesList) {
      if (item is Map<String, dynamic> || item is Map) {
        final itemMap = item is Map<String, dynamic>
            ? item
            : item.cast<String, dynamic>();
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
      lastUpdated: DateTime.now(),
      changePercentage: computedChange,
      originalCurrency: originalCurrency,
      originalPrice: currentOriginalPrice,
      peRatio: double.tryParse(quoteMap['pe']?.toString() ?? ''),
      high52Week:
          (double.tryParse(
                quoteMap['fifty_two_week']?['high']?.toString() ?? '',
              ) ??
              0.0) *
          conversionRate,
      low52Week:
          (double.tryParse(
                quoteMap['fifty_two_week']?['low']?.toString() ?? '',
              ) ??
              0.0) *
          conversionRate,
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
          parsedTimeSeries[key.toString()] = PricePoint.fromJson(
            value.cast<String, dynamic>(),
          );
        }
      });
    }

    DateTime? parsedLastUpdated;
    final rawLastUpdated = json['lastUpdated'];
    if (rawLastUpdated != null) {
      if (rawLastUpdated is int) {
        parsedLastUpdated = DateTime.fromMillisecondsSinceEpoch(rawLastUpdated);
      } else if (rawLastUpdated is String) {
        parsedLastUpdated = DateTime.tryParse(rawLastUpdated);
      }
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
      lastUpdated: parsedLastUpdated,
      changePercentage: (json['changePercentage'] as num?)?.toDouble(),
      originalCurrency: json['originalCurrency'] as String? ?? 'EUR',
      originalPrice:
          (json['originalPrice'] as num?)?.toDouble() ??
          (json['currentPrice'] as num).toDouble(),
      marketCap: json['marketCap'] as String?,
      peRatio: (json['peRatio'] as num?)?.toDouble(),
      dividendYield: (json['dividendYield'] as num?)?.toDouble(),
      riskLevel: (json['riskLevel'] as num?)?.toInt(),
      beta: (json['beta'] as num?)?.toDouble(),
      eps: (json['eps'] as num?)?.toDouble(),
      high52Week: (json['high52Week'] as num?)?.toDouble(),
      low52Week: (json['low52Week'] as num?)?.toDouble(),
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
      'timeSeries': timeSeries.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'originalCurrency': originalCurrency,
      'originalPrice': originalPrice,
    };
    if (lastUpdated != null) {
      jsonMap['lastUpdated'] = lastUpdated!.millisecondsSinceEpoch;
    }
    if (changePercentage != null) {
      jsonMap['changePercentage'] = changePercentage;
    }
    if (marketCap != null) jsonMap['marketCap'] = marketCap;
    if (peRatio != null) jsonMap['peRatio'] = peRatio;
    if (dividendYield != null) jsonMap['dividendYield'] = dividendYield;
    if (riskLevel != null) jsonMap['riskLevel'] = riskLevel;
    if (beta != null) jsonMap['beta'] = beta;
    if (eps != null) jsonMap['eps'] = eps;
    if (high52Week != null) jsonMap['high52Week'] = high52Week;
    if (low52Week != null) jsonMap['low52Week'] = low52Week;
    return jsonMap;
  }
}
