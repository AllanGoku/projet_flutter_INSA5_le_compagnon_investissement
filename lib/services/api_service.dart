// [AI-GENERATED] Migration Twelve Data, Agent, 2025-02-23
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/asset.dart';

/// Service gérant les appels réseau à l'API Twelve Data.
/// Permet de récupérer les données en temps réel et l'historique des actifs financiers.
class ApiService {
  final http.Client client;
  final String _baseUrl = 'https://api.twelvedata.com';

  ApiService({http.Client? client}) : client = client ?? http.Client();

  /// Récupère la clé API depuis le fichier .env (sécurité) en nettoyant d'éventuels guillemets.
  String get _apiKey {
    var key = dotenv.env['TWELVEDATA_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception(
        "La clé API Twelve Data n'est pas configurée dans le fichier .env",
      );
    }
    return key.replaceAll('"', '').replaceAll("'", '').trim();
  }

  /// Récupère les détails et l'historique d'un actif (Action/ETF) depuis Twelve Data.
  ///
  /// Utilise les endpoints `/time_series` et `/quote` pour obtenir l'historique et le prix courant.
  /// [symbol] : Le symbole boursier de l'actif (ex: 'AAPL').
  Future<Asset> fetchAssetData(
    String symbol, {
    String name = '',
    String type = 'Stock',
    String description = '',
  }) async {
    final timeSeriesUri = Uri.parse(
      '$_baseUrl/time_series?symbol=$symbol&interval=1day&start_date=2015-01-01&apikey=$_apiKey',
    );
    final quoteUri = Uri.parse(
      '$_baseUrl/quote?symbol=$symbol&apikey=$_apiKey',
    );

    final responses = await Future.wait([
      client.get(timeSeriesUri),
      client.get(quoteUri),
    ]);

    final timeSeriesResponse = responses[0];
    final quoteResponse = responses[1];

    // Helper pour extraire le message d'erreur d'une réponse, quel que soit le code HTTP
    String extractError(http.Response res) {
      try {
        final json = jsonDecode(res.body);
        if (json is Map && json['status'] == 'error') {
          return '${json['code'] ?? res.statusCode}: ${json['message'] ?? 'Erreur inconnue'}';
        }
        if (json is Map && json.containsKey('message')) {
          return json['message'].toString();
        }
      } catch (_) {}
      return 'Code HTTP ${res.statusCode}';
    }

    if (timeSeriesResponse.statusCode == 200 &&
        quoteResponse.statusCode == 200) {
      final timeSeriesJson = jsonDecode(timeSeriesResponse.body);
      final quoteJson = jsonDecode(quoteResponse.body);

      // Extraction explicite du message d'erreur de l'API Twelve Data (si status == 200 mais error en JSON)
      if (timeSeriesJson['status'] == 'error') {
        final code = timeSeriesJson['code'] ?? 'Inconnu';
        final message = timeSeriesJson['message'] ?? 'Erreur non spécifiée';
        throw Exception(
          'Erreur API Twelve Data (time_series) - Code $code : $message',
        );
      }

      if (quoteJson['status'] == 'error') {
        final code = quoteJson['code'] ?? 'Inconnu';
        final message = quoteJson['message'] ?? 'Erreur non spécifiée';
        throw Exception(
          'Erreur API Twelve Data (quote) - Code $code : $message',
        );
      }

      final combinedJson = {'time_series': timeSeriesJson, 'quote': quoteJson};

      return Asset.fromApiJson(
        combinedJson,
        name: name,
        type: type,
        description: description,
      );
    } else {
      String errorDetails = '';
      if (timeSeriesResponse.statusCode != 200) {
        errorDetails += 'TimeSeries (${extractError(timeSeriesResponse)}). ';
      }
      if (quoteResponse.statusCode != 200) {
        errorDetails += 'Quote (${extractError(quoteResponse)}).';
      }
      throw Exception('Erreur réseau API Twelve Data : $errorDetails');
    }
  }

  /// Récupère la liste globale des plus fortes hausses, baisses et volumes du marché US.
  ///
  /// Endpoint Twelve Data: `/market_movers/stocks`.
  Future<List<Asset>> fetchTopGainersLosers() async {
    final uri = Uri.parse('$_baseUrl/market_movers/stocks?apikey=$_apiKey');

    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      if (json['status'] == 'error') {
        final code = json['code'] ?? 'Inconnu';
        final message = json['message'] ?? 'Erreur non spécifiée';
        throw Exception('API Twelve Data ($code) : $message');
      }

      final List<Asset> assets = [];
      final values = json['values'] as List? ?? [];

      for (var item in values) {
        if (item is Map<String, dynamic>) {
          final symbol = item['symbol'] as String? ?? '';
          final assetName = item['name'] as String? ?? symbol;
          final price =
              double.tryParse(
                item['last']?.toString() ?? item['close']?.toString() ?? '0',
              ) ??
              0.0;
          final changeAmount = item['change']?.toString() ?? '0';
          final changePercentStr = (item['percent_change']?.toString() ?? '0')
              .replaceAll('%', '');
          final changePercent = double.tryParse(changePercentStr) ?? 0.0;

          if (symbol.isNotEmpty) {
            assets.add(
              Asset(
                symbol: symbol,
                name: assetName,
                currentPrice: price,
                type: 'Stock',
                description: 'Actif du marché US (Variation: $changeAmount \$)',
                marketOpen: true,
                timezone: 'US/Eastern',
                timeSeries: {},
                changePercentage: changePercent,
              ),
            );
          }
        }
      }
      return assets;
    } else {
      String errorMessage = 'Erreur réseau (code: ${response.statusCode})';
      try {
        final json = jsonDecode(response.body);
        if (json is Map && json['status'] == 'error') {
          errorMessage =
              'API Twelve Data (${json['code'] ?? response.statusCode}) : ${json['message'] ?? 'Erreur inconnue'}';
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }
}
