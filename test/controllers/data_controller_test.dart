// [AI-GENERATED] Migration Twelve Data, Agent, 2025-02-23
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sqflite/sqflite.dart';
// ignore: implementation_imports
import 'package:sqflite_common/src/mixin/factory.dart';
import 'package:le_compagnon_investissement/services/api_service.dart';
import 'package:le_compagnon_investissement/services/cache_service.dart';
import 'package:le_compagnon_investissement/controllers/data_controller.dart';
import 'package:le_compagnon_investissement/controllers/data_state.dart';

void main() {
  group('DataController Tests', () {
    late CacheService cacheService;
    final Map<String, Map<String, dynamic>> inMemoryStorage = {};

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      dotenv.loadFromString(envString: 'TWELVEDATA_API_KEY=fake_test_key');

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

    test('L\'état initial est DataState.initial', () {
      final controller = DataController(
        apiService: ApiService(),
        cacheService: cacheService,
      );

      expect(controller.state, DataState.initial);
    });

    test('loadAsset réussit et passe à l\'état success avec API', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('/time_series')) {
          return http.Response('''
          {
            "meta": {
              "symbol": "AAPL",
              "exchange_timezone": "US/Eastern"
            },
            "values": [
              {
                "datetime": "2024-05-24",
                "open": "190.0",
                "high": "191.0",
                "low": "189.0",
                "close": "189.5",
                "volume": "10000"
              }
            ],
            "status": "ok"
          }
          ''', 200);
        } else if (request.url.path.contains('/quote')) {
          return http.Response('''
          {
            "symbol": "AAPL",
            "name": "Apple Inc",
            "exchange_timezone": "US/Eastern",
            "close": "189.5",
            "percent_change": "0.5"
          }
          ''', 200);
        }
        return http.Response('Erreur', 404);
      });

      final apiService = ApiService(client: mockClient);
      final controller = DataController(
        apiService: apiService,
        cacheService: cacheService,
      );

      final future = controller.loadAsset('AAPL');

      expect(controller.state, DataState.loading);

      await future;

      expect(controller.state, DataState.success);
      expect(controller.assets.containsKey('AAPL'), isTrue);
      expect(
        controller.assets['AAPL']!.currentPrice,
        closeTo(189.5 * 0.92, 0.001),
      );
    });

    test('loadAsset passe en erreur si API échoue et pas de cache', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Erreur', 404);
      });

      final apiService = ApiService(client: mockClient);
      final controller = DataController(
        apiService: apiService,
        cacheService: cacheService,
      );

      await controller.loadAsset('AAPL');

      expect(controller.state, DataState.error);
    });
  });
}
