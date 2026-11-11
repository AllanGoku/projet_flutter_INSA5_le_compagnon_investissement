// [AI-GENERATED] Migration Twelve Data, Agent, 2025-02-23
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:le_compagnon_investissement/services/api_service.dart';

void main() {
  group('ApiService Tests', () {
    setUpAll(() {
      // Injection de la clé API pour les tests
      dotenv.loadFromString(envString: 'TWELVEDATA_API_KEY=fake_test_key');
    });

    test('fetchAssetData retourne un Asset si la requête réussit', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('/time_series')) {
          return http.Response('''
          {
            "meta": {
              "symbol": "AAPL",
              "interval": "1wk",
              "currency": "USD",
              "exchange_timezone": "America/New_York",
              "exchange": "NASDAQ",
              "mic_code": "XNAS",
              "type": "Common Stock"
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
            "exchange": "NASDAQ",
            "mic_code": "XNAS",
            "currency": "USD",
            "datetime": "2024-05-24",
            "timestamp": 1716580800,
            "open": "190.0",
            "high": "191.0",
            "low": "189.0",
            "close": "189.5",
            "volume": "10000",
            "previous_close": "188.0",
            "change": "1.5",
            "percent_change": "0.79",
            "average_volume": "50000",
            "is_market_open": true
          }
          ''', 200);
        }
        return http.Response('Not found', 404);
      });

      final apiService = ApiService(client: mockClient);
      final asset = await apiService.fetchAssetData('AAPL');

      expect(asset.symbol, 'AAPL');
      expect(asset.timezone, 'America/New_York');
      expect(asset.currentPrice, closeTo(189.5 * 0.92, 0.001));
      expect(asset.timeSeries.length, 1);
      expect(
        asset.timeSeries['2024-05-24']?.open,
        closeTo(190.0 * 0.92, 0.001),
      );
      expect(asset.changePercentage, closeTo(0.79, 0.001));
    });

    test(
      'fetchAssetData lance une exception en cas de limite atteinte',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response('''
        {
          "status": "error",
          "code": 429,
          "message": "You have reached your API call limit."
        }
        ''', 200); // L'API renvoie parfois 200 avec le status error
        });

        final apiService = ApiService(client: mockClient);

        expect(() => apiService.fetchAssetData('AAPL'), throwsException);
      },
    );

    test('fetchAssetData lance une exception si le statut HTTP est différent de 200', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final apiService = ApiService(client: mockClient);

      expect(() => apiService.fetchAssetData('AAPL'), throwsException);
    });
  });
}
