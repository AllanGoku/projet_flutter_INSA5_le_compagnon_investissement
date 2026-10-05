// [AI-GENERATED] Setup, Agent, 2025-02-23

/// Modèle représentant un point de données boursier (OHLCV : Open, High, Low, Close, Volume).
///
/// Permet de conserver la totalité des informations fournies par l'API Alpha Vantage
/// pour afficher des graphiques avancés (ex: chandelier japonais / candlesticks, volume)
/// et conserver un historique complet en mode hors-ligne.
class PricePoint {
  final double open;
  final double high;
  final double low;
  final double close;
  final int volume;

  PricePoint({
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  /// Parse les données brutes renvoyées par l'API Alpha Vantage (clés numérotées)
  factory PricePoint.fromApiJson(Map<String, dynamic> json) {
    return PricePoint(
      open: double.tryParse(json['1. open']?.toString() ?? '') ?? 0.0,
      high: double.tryParse(json['2. high']?.toString() ?? '') ?? 0.0,
      low: double.tryParse(json['3. low']?.toString() ?? '') ?? 0.0,
      close: double.tryParse(json['4. close']?.toString() ?? '') ?? 0.0,
      volume: int.tryParse(json['5. volume']?.toString() ?? '') ?? 0,
    );
  }

  /// Parse un objet JSON déjà sérialisé en interne
  factory PricePoint.fromJson(Map<String, dynamic> json) {
    return PricePoint(
      open: (json['open'] as num?)?.toDouble() ?? 0.0,
      high: (json['high'] as num?)?.toDouble() ?? 0.0,
      low: (json['low'] as num?)?.toDouble() ?? 0.0,
      close: (json['close'] as num?)?.toDouble() ?? 0.0,
      volume: (json['volume'] as num?)?.toInt() ?? 0,
    );
  }

  /// Sérialise l'instance [PricePoint] en map JSON standard
  Map<String, dynamic> toJson() {
    return {
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'volume': volume,
    };
  }
}
