// [AI-GENERATED] Issue #2, Agent, 2024-05-24
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
// ignore: implementation_imports
import 'package:sqflite_common/src/mixin/factory.dart';
import 'package:le_compagnon_investissement/services/cache_service.dart';
import 'package:le_compagnon_investissement/models/asset.dart';
import 'package:le_compagnon_investissement/models/price_point.dart';
import 'package:le_compagnon_investissement/models/portfolio_transaction.dart';

void main() {
  group('CacheService Tests', () {
    late CacheService cacheService;
    final Map<String, Map<String, dynamic>> inMemoryStorage = {};
    final List<Map<String, dynamic>> transactionsList = [];

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();

      databaseFactory = buildDatabaseFactory(
        invokeMethod: (String method, [Object? arguments]) async {
          final args = arguments as Map<dynamic, dynamic>?;

          if (method == 'openDatabase') {
            return <String, dynamic>{'id': 1};
          }
          if (method == 'execute') {
            return null;
          }
          if (method == 'insert') {
            if (args != null && args['sql'] != null) {
              final sql = args['sql'] as String;
              if (sql.contains('INTO transactions') &&
                  args['arguments'] != null) {
                final list = args['arguments'] as List;
                transactionsList.add({
                  'symbol': list[0],
                  'assetName': list[1],
                  'type': list[2],
                  'quantity': list[3],
                  'price': list[4],
                  'timestamp': list[5],
                });
                return 1;
              }
            }
            if (args != null && args['arguments'] != null) {
              final list = args['arguments'] as List;
              if (list.isNotEmpty && list[0] is String) {
                final row = <String, dynamic>{
                  'symbol': list[0],
                  'name': list.length > 1 ? list[1] : list[0],
                  'currentPrice': list.length > 2 ? list[2] : 0.0,
                  'type': list.length > 3 ? list[3] : 'Stock',
                  'description': list.length > 4 ? list[4] : '',
                  'marketOpen': list.length > 5 ? list[5] : 1,
                  'timezone': list.length > 6 ? list[6] : 'UTC',
                  'timeSeries': list.length > 7 ? list[7] : '{}',
                  'lastUpdated': list.length > 8
                      ? list[8]
                      : DateTime.now().millisecondsSinceEpoch,
                };
                inMemoryStorage[list[0] as String] = row;
              }
            }
            return 1;
          }
          if (method == 'query') {
            if (args != null && args['sql'] != null) {
              final sql = args['sql'] as String;
              if (sql.contains('FROM transactions')) {
                return transactionsList;
              }
              final bindArgs = args['arguments'] as List?;
              if (bindArgs != null && bindArgs.isNotEmpty) {
                final symbol = bindArgs.first as String;
                if (inMemoryStorage.containsKey(symbol)) {
                  return [inMemoryStorage[symbol]!];
                }
              }
            }
            return <Map<String, dynamic>>[];
          }
          if (method == 'delete') {
            inMemoryStorage.clear();
            transactionsList.clear();
            return 1;
          }
          if (method == 'closeDatabase') {
            return null;
          }
          return null;
        },
      );
    });

    setUp(() async {
      inMemoryStorage.clear();
      cacheService = CacheService();
      await cacheService.initDB(inMemory: true);
    });

    test('Sauvegarde et récupération d\'un Asset', () async {
      final asset = Asset(
        symbol: 'TSLA',
        name: 'Tesla',
        currentPrice: 200.0,
        type: 'Stock',
        description: 'Constructeur auto',
        marketOpen: true,
        timezone: 'US/Eastern',
        timeSeries: {
          '2024-05-24': PricePoint(
            open: 195.0,
            high: 205.0,
            low: 190.0,
            close: 200.0,
            volume: 5000,
          ),
        },
      );

      await cacheService.saveAsset(asset);
      final retrievedAsset = await cacheService.getAsset('TSLA');

      expect(retrievedAsset, isNotNull);
      expect(retrievedAsset!.symbol, 'TSLA');
      expect(retrievedAsset.name, 'Tesla');
      expect(retrievedAsset.currentPrice, closeTo(200.0, 0.001));
      expect(retrievedAsset.timeSeries.containsKey('2024-05-24'), isTrue);
      expect(
        retrievedAsset.timeSeries['2024-05-24']!.open,
        closeTo(195.0, 0.001),
      );
    });

    test('getAsset renvoie null si l\'actif n\'existe pas', () async {
      final retrievedAsset = await cacheService.getAsset('INCONNU');
      expect(retrievedAsset, isNull);
    });

    test('getLastUpdated renvoie la date correcte', () async {
      final asset = Asset(
        symbol: 'AAPL',
        name: 'Apple',
        currentPrice: 150.0,
        type: 'Stock',
        description: 'Tech',
        marketOpen: true,
        timezone: 'UTC',
        timeSeries: {},
      );

      await cacheService.saveAsset(asset);
      final lastUpdated = await cacheService.getLastUpdated('AAPL');

      expect(lastUpdated, isNotNull);
      final diff = DateTime.now().difference(lastUpdated!);
      expect(diff.inSeconds, lessThan(2));
    });

    test('Sauvegarde et récupération des transactions', () async {
      final now = DateTime.now();
      final tx = PortfolioTransaction(
        symbol: 'AAPL',
        assetName: 'Apple Inc.',
        type: TransactionType.buy,
        quantity: 10.0,
        price: 150.0,
        timestamp: now,
      );

      await cacheService.saveTransaction(tx);
      final transactions = await cacheService.getTransactions();

      expect(transactions, isNotEmpty);
      expect(transactions.first.symbol, equals('AAPL'));
      expect(transactions.first.quantity, equals(10.0));
      expect(transactions.first.type, equals(TransactionType.buy));
    });

    test('Suppression d\'une position du portefeuille', () async {
      await cacheService.deletePortfolioPosition('AAPL');
      // On s'assure qu'aucune exception n'est levée
      expect(true, isTrue);
    });
  });
}
