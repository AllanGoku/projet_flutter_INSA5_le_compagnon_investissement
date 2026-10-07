// [AI-GENERATED] Setup, Agent, 2025-02-23
import 'package:flutter_test/flutter_test.dart';
import 'package:le_compagnon_investissement/models/price_point.dart';

void main() {
  group('PricePoint', () {
    test('should parse from Twelve Data API JSON format', () {
      final apiJson = {
        'open': '222.6300',
        'high': '222.6300',
        'low': '222.4964',
        'close': '222.4964',
        'volume': '281',
      };

      final pricePoint = PricePoint.fromApiJson(apiJson);

      expect(pricePoint.open, 222.6300);
      expect(pricePoint.high, 222.6300);
      expect(pricePoint.low, 222.4964);
      expect(pricePoint.close, 222.4964);
      expect(pricePoint.volume, 281);
    });

    test('should serialize and deserialize standard internal JSON', () {
      final json = {
        'open': 100.0,
        'high': 105.0,
        'low': 98.0,
        'close': 102.5,
        'volume': 1500,
      };

      final pricePoint = PricePoint.fromJson(json);

      expect(pricePoint.open, 100.0);
      expect(pricePoint.high, 105.0);
      expect(pricePoint.low, 98.0);
      expect(pricePoint.close, 102.5);
      expect(pricePoint.volume, 1500);

      final serialized = pricePoint.toJson();
      expect(serialized, json);
    });
  });
}
