// [AI-GENERATED] Issue #2, Agent, 2024-05-24
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
// ignore: implementation_imports
import 'package:sqflite_common/src/mixin/factory.dart';
import 'package:le_compagnon_investissement/services/cache_service.dart';
import 'package:le_compagnon_investissement/models/asset.dart';
import 'package:le_compagnon_investissement/models/price_point.dart';

void main() {
  group('CacheService Tests', () {
    late CacheService cacheService;
    final Map<String, Map<String, dynamic>> inMemoryStorage = {};

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
            if (args != null && args['arguments'] != null) {
              final list = args['arguments'] as List;
              // Ordre des arguments: symbol, name, currentPrice, type, description, marketOpen, timezone, timeSeries, lastUpdated
              final row = <String, dynamic>{
                'symbol': list[0],
                'name': list[1],
                'currentPrice': list[2],
                'type': list[3],
                'description': list[4],
                'marketOpen': list[5],
                'timezone': list[6],
                'timeSeries': list[7],
                'lastUpdated': list[8],
              };
              inMemoryStorage[list[0] as String] = row;
            }
            return 1;
          }
          if (method == 'query') {
            if (args != null && args['sql'] != null) {
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
          '2024-05-24': PricePoint(open: 195.0, high: 205.0, low: 190.0, close: 200.0, volume: 5000)
        },
      );

      await cacheService.saveAsset(asset);
      final retrievedAsset = await cacheService.getAsset('TSLA');

      expect(retrievedAsset, isNotNull);
      expect(retrievedAsset!.symbol, 'TSLA');
      expect(retrievedAsset.name, 'Tesla');
      expect(retrievedAsset.currentPrice, closeTo(200.0, 0.001));
      expect(retrievedAsset.timeSeries.containsKey('2024-05-24'), isTrue);
      expect(retrievedAsset.timeSeries['2024-05-24']!.open, closeTo(195.0, 0.001));
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
  });
}
