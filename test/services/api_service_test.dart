// [AI-GENERATED] Issue #2, Agent, 2024-05-24
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:le_compagnon_investissement/services/api_service.dart';

void main() {
  group('ApiService Tests', () {
    setUpAll(() {
      // Injection de la clé API pour les tests
      dotenv.loadFromString(envString: 'ALPHA_VANTAGE_API_KEY=fake_test_key');
    });

    test('fetchAssetData retourne un Asset si la requête réussit', () async {
      final mockClient = MockClient((request) async {
        return http.Response('''
        {
          "Meta Data": {
            "1. Information": "Daily Prices (open, high, low, close) and Volumes",
            "2. Symbol": "AAPL",
            "3. Last Refreshed": "2024-05-24",
            "4. Output Size": "Compact",
            "5. Time Zone": "US/Eastern"
          },
          "Time Series (Daily)": {
            "2024-05-24": {
              "1. open": "190.0",
              "2. high": "191.0",
              "3. low": "189.0",
              "4. close": "189.5",
              "5. volume": "10000"
            }
          }
        }
        ''', 200);
      });

      final apiService = ApiService(client: mockClient);
      final asset = await apiService.fetchAssetData('AAPL');

      expect(asset.symbol, 'AAPL');
      expect(asset.timezone, 'US/Eastern');
      expect(asset.currentPrice, closeTo(189.5, 0.001));
      expect(asset.timeSeries.length, 1);
      expect(asset.timeSeries['2024-05-24']?.open, closeTo(190.0, 0.001));
    });

    test('fetchAssetData lance une exception en cas de limite atteinte', () async {
      final mockClient = MockClient((request) async {
        return http.Response('''
        {
          "Note": "Thank you for using Alpha Vantage! Our standard API call frequency is 5 calls per minute and 500 calls per day."
        }
        ''', 200);
      });

      final apiService = ApiService(client: mockClient);

      expect(() => apiService.fetchAssetData('AAPL'), throwsException);
    });

    test('fetchAssetData lance une exception si le statut HTTP est différent de 200', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final apiService = ApiService(client: mockClient);

      expect(() => apiService.fetchAssetData('AAPL'), throwsException);
    });
  });
}
