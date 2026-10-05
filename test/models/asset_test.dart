// [AI-GENERATED] Setup, Agent, 2025-02-23
import 'package:flutter_test/flutter_test.dart';
import 'package:le_compagnon_investissement/models/asset.dart';
import 'package:le_compagnon_investissement/models/portfolio_position.dart';

void main() {
  group('Asset', () {
    test('should parse directly from Alpha Vantage API JSON format', () {
      final apiJson = {
        "Meta Data": {
          "1. Information": "Intraday (5min) open, high, low, close prices and volume",
          "2. Symbol": "IBM",
          "3. Last Refreshed": "2026-10-02 19:55:00",
          "4. Interval": "5min",
          "5. Output Size": "Compact",
          "6. Time Zone": "US/Eastern"
        },
        "Time Series (5min)": {
          "2026-10-02 19:55:00": {
            "1. open": "222.6300",
            "2. high": "222.6300",
            "3. low": "222.4964",
            "4. close": "222.4964",
            "5. volume": "281"
          },
          "2026-10-02 19:50:00": {
            "1. open": "222.6300",
            "2. high": "222.6300",
            "3. low": "222.5886",
            "4. close": "222.6000",
            "5. volume": "293"
          }
        }
      };

      final asset = Asset.fromApiJson(apiJson, name: 'International Business Machines', type: 'Stock');

      expect(asset.symbol, 'IBM');
      expect(asset.name, 'International Business Machines');
      expect(asset.timezone, 'US/Eastern');
      expect(asset.currentPrice, 222.4964);
      expect(asset.timeSeries.length, 2);
      expect(asset.timeSeries['2026-10-02 19:55:00']?.close, 222.4964);
      expect(asset.timeSeries['2026-10-02 19:50:00']?.volume, 293);
    });

    test('should serialize and deserialize from internal JSON with PricePoint timeSeries', () {
      final json = {
        'symbol': 'AAPL',
        'name': 'Apple Inc.',
        'currentPrice': 150.0,
        'type': 'Stock',
        'description': 'Tech company',
        'marketOpen': true,
        'timezone': 'America/New_York',
        'timeSeries': {
          '2025-02-23T10:00:00Z': {
            'open': 149.0,
            'high': 150.0,
            'low': 148.5,
            'close': 149.5,
            'volume': 1000,
          },
        },
      };

      final asset = Asset.fromJson(json);

      expect(asset.symbol, 'AAPL');
      expect(asset.name, 'Apple Inc.');
      expect(asset.currentPrice, 150.0);
      expect(asset.type, 'Stock');
      expect(asset.description, 'Tech company');
      expect(asset.marketOpen, true);
      expect(asset.timezone, 'America/New_York');
      expect(asset.timeSeries.length, 1);
      
      final pricePoint = asset.timeSeries['2025-02-23T10:00:00Z'];
      expect(pricePoint, isNotNull);
      expect(pricePoint!.close, 149.5);
      expect(pricePoint.volume, 1000);

      final serialized = asset.toJson();
      expect(serialized, json);
    });
  });

  group('PortfolioPosition', () {
    test('should serialize and deserialize from JSON', () {
      final assetJson = {
        'symbol': 'VOO',
        'name': 'Vanguard S&P 500 ETF',
        'currentPrice': 400.0,
        'type': 'ETF',
        'description': 'S&P 500 index ETF',
        'marketOpen': false,
        'timezone': 'America/New_York',
        'timeSeries': <String, dynamic>{},
      };

      final json = {
        'asset': assetJson,
        'quantity': 10.5,
        'averagePurchasePrice': 380.0,
      };

      final position = PortfolioPosition.fromJson(json);

      expect(position.quantity, 10.5);
      expect(position.averagePurchasePrice, 380.0);
      expect(position.asset.symbol, 'VOO');
      expect(position.asset.name, 'Vanguard S&P 500 ETF');
      expect(position.asset.timezone, 'America/New_York');

      final serialized = position.toJson();
      expect(serialized, json);
    });
  });
}
