// [AI-GENERATED] Phase 4, Agent, 2025-02-23

/// Type d'opération de transaction sur le portefeuille.
enum TransactionType {
  buy,
  sell,
}

/// Modèle représentant une transaction fictive d'achat ou de revente d'actif.
///
/// Stocké dans la table SQLite `transactions` pour conserver le journal de bord
/// des opérations effectuées par l'utilisateur.
class PortfolioTransaction {
  final int? id;
  final String symbol;
  final String assetName;
  final TransactionType type;
  final double quantity;
  final double price;
  final DateTime timestamp;
  final double? realizedGain;

  PortfolioTransaction({
    this.id,
    required this.symbol,
    required this.assetName,
    required this.type,
    required this.quantity,
    required this.price,
    required this.timestamp,
    this.realizedGain,
  });

  /// Indique s'il s'agit d'une opération d'achat.
  bool get isBuy => type == TransactionType.buy;

  /// Indique s'il s'agit d'une opération de revente.
  bool get isSell => type == TransactionType.sell;

  /// Montant total de la transaction (quantité * prix d'exécution).
  double get totalAmount => quantity * price;

  /// Convertit la transaction en une Map pour SQLite ou JSON.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'symbol': symbol,
      'assetName': assetName,
      'type': type.name,
      'quantity': quantity,
      'price': price,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
    if (id != null) {
      map['id'] = id;
    }
    if (realizedGain != null) {
      map['realizedGain'] = realizedGain;
    }
    return map;
  }

  /// Alias de [toMap] pour la compatibilité JSON.
  Map<String, dynamic> toJson() => toMap();

  /// Construit une [PortfolioTransaction] à partir d'une Map issue de SQLite ou JSON.
  factory PortfolioTransaction.fromMap(Map<String, dynamic> map) {
    final String typeStr = map['type'] as String? ?? 'buy';
    return PortfolioTransaction(
      id: map['id'] as int?,
      symbol: map['symbol'] as String,
      assetName: map['assetName'] as String? ?? map['symbol'] as String,
      type: typeStr == 'sell' ? TransactionType.sell : TransactionType.buy,
      quantity: (map['quantity'] as num).toDouble(),
      price: (map['price'] as num).toDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      realizedGain: map['realizedGain'] != null ? (map['realizedGain'] as num).toDouble() : null,
    );
  }

  /// Alias de [fromMap] pour la compatibilité JSON.
  factory PortfolioTransaction.fromJson(Map<String, dynamic> json) =>
      PortfolioTransaction.fromMap(json);
}
