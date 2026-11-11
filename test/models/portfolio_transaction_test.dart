// [AI-GENERATED] Phase 4, Agent, 2025-02-23
import 'package:flutter_test/flutter_test.dart';
import 'package:le_compagnon_investissement/models/portfolio_transaction.dart';

void main() {
  group('PortfolioTransaction Tests', () {
    test('Création et sérialisation d\'une transaction d\'achat', () {
      final now = DateTime.now();
      final transaction = PortfolioTransaction(
        id: 1,
        symbol: 'AAPL',
        assetName: 'Apple Inc.',
        type: TransactionType.buy,
        quantity: 5.0,
        price: 150.0,
        timestamp: now,
      );

      expect(transaction.id, equals(1));
      expect(transaction.symbol, equals('AAPL'));
      expect(transaction.assetName, equals('Apple Inc.'));
      expect(transaction.type, equals(TransactionType.buy));
      expect(transaction.quantity, equals(5.0));
      expect(transaction.price, equals(150.0));
      expect(transaction.timestamp, equals(now));
      expect(transaction.totalAmount, equals(750.0));
      expect(transaction.isBuy, isTrue);
      expect(transaction.isSell, isFalse);

      final map = transaction.toMap();
      expect(map['id'], equals(1));
      expect(map['symbol'], equals('AAPL'));
      expect(map['type'], equals('buy'));
      expect(map['quantity'], equals(5.0));
      expect(map['price'], equals(150.0));
      expect(map['timestamp'], equals(now.millisecondsSinceEpoch));

      final restored = PortfolioTransaction.fromMap(map);
      expect(restored.id, equals(1));
      expect(restored.symbol, equals('AAPL'));
      expect(restored.assetName, equals('Apple Inc.'));
      expect(restored.type, equals(TransactionType.buy));
      expect(restored.quantity, equals(5.0));
      expect(restored.price, equals(150.0));
      expect(
        restored.timestamp.millisecondsSinceEpoch,
        equals(now.millisecondsSinceEpoch),
      );
    });

    test('Création et sérialisation d\'une transaction de vente', () {
      final now = DateTime.now();
      final transaction = PortfolioTransaction(
        symbol: 'MSFT',
        assetName: 'Microsoft Corp.',
        type: TransactionType.sell,
        quantity: 2.0,
        price: 300.0,
        timestamp: now,
      );

      expect(transaction.id, isNull);
      expect(transaction.isSell, isTrue);
      expect(transaction.isBuy, isFalse);
      expect(transaction.totalAmount, equals(600.0));

      final jsonMap = transaction.toJson();
      expect(jsonMap['type'], equals('sell'));

      final restored = PortfolioTransaction.fromJson(jsonMap);
      expect(restored.symbol, equals('MSFT'));
      expect(restored.type, equals(TransactionType.sell));
    });
  });
}
