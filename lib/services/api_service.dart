// [AI-GENERATED] Issue #2, Agent, 2024-05-24
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/asset.dart';

/// Service gérant les appels réseau à l'API Alpha Vantage.
/// Permet de récupérer les données en temps réel et l'historique des actifs financiers.
class ApiService {
  final http.Client client;
  final String _baseUrl = 'https://www.alphavantage.co/query';

  ApiService({http.Client? client}) : client = client ?? http.Client();

  /// Récupère la clé API depuis le fichier .env (sécurité).
  String get _apiKey {
    final key = dotenv.env['ALPHA_VANTAGE_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception("La clé API Alpha Vantage n'est pas configurée dans le fichier .env");
    }
    return key;
  }

  /// Récupère les détails et l'historique d'un actif (Action/ETF) depuis Alpha Vantage.
  /// 
  /// Utilise TIME_SERIES_DAILY pour obtenir l'historique complet (OHLCV).
  /// [symbol] : Le symbole boursier de l'actif (ex: 'AAPL').
  Future<Asset> fetchAssetData(String symbol) async {
    final uri = Uri.parse(
      '$_baseUrl?function=TIME_SERIES_DAILY&symbol=$symbol&apikey=$_apiKey'
    );

    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      
      // Vérifier si l'API a renvoyé une erreur (ex: limite atteinte ou symbole invalide)
      if (json.containsKey('Error Message')) {
        throw Exception('Erreur API: Symbole invalide ou introuvable.');
      }
      if (json.containsKey('Information') || json.containsKey('Note')) {
        throw Exception('Erreur API: Limite de requêtes atteinte.');
      }

      // Par défaut, l'API ne fournit pas le nom complet ni la description via l'endpoint TIME_SERIES_DAILY,
      // on peut utiliser le symbole par défaut, le vrai nom pourrait être récupéré via SYMBOL_SEARCH ou OVERVIEW.
      return Asset.fromApiJson(json);
    } else {
      throw Exception('Erreur réseau lors de la récupération des données (code: ${response.statusCode})');
    }
  }
}
