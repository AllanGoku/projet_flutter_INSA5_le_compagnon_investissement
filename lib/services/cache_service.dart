// [AI-GENERATED] Issue #2, Agent, 2024-05-24
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/asset.dart';

/// Service responsable de la persistance locale des actifs (actions/ETF).
/// Utilise SQLite pour stocker de manière robuste les données et l'historique
/// des cours afin de limiter les requêtes API (Alpha Vantage) et permettre 
/// un fonctionnement hors-connexion.
class CacheService {
  Database? _database;

  /// Initialise la connexion à la base de données SQLite.
  /// Crée la table 'assets' si elle n'existe pas.
  Future<void> initDB({bool inMemory = false}) async {
    if (_database != null) return;

    if (inMemory) {
      // Pour les tests sans sqflite_common_ffi si possible, ou base en mémoire standard
      _database = await openDatabase(inMemoryDatabasePath, version: 1, onCreate: _onCreate);
    } else {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'compagnon_investissement.db');
      _database = await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
      );
    }
  }

  /// Fournit l'instance de la base de données.
  Future<Database> get db async {
    if (_database == null) {
      await initDB();
    }
    return _database!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE assets(
        symbol TEXT PRIMARY KEY,
        name TEXT,
        currentPrice REAL,
        type TEXT,
        description TEXT,
        marketOpen INTEGER,
        timezone TEXT,
        timeSeries TEXT,
        lastUpdated INTEGER
      )
    ''');
  }

  /// Sauvegarde un [Asset] dans le cache local (insert ou replace).
  Future<void> saveAsset(Asset asset) async {
    final database = await db;
    final Map<String, dynamic> assetMap = asset.toJson();
    // Sérialiser la map complète de timeSeries en String JSON pour SQLite
    assetMap['timeSeries'] = jsonEncode(assetMap['timeSeries']);
    assetMap['marketOpen'] = asset.marketOpen ? 1 : 0;
    assetMap['lastUpdated'] = DateTime.now().millisecondsSinceEpoch;

    await database.insert(
      'assets',
      assetMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Récupère un [Asset] depuis le cache en utilisant son [symbol].
  Future<Asset?> getAsset(String symbol) async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query(
      'assets',
      where: 'symbol = ?',
      whereArgs: [symbol],
    );

    if (maps.isNotEmpty) {
      final data = Map<String, dynamic>.from(maps.first);
      data['timeSeries'] = jsonDecode(data['timeSeries'] as String);
      data['marketOpen'] = (data['marketOpen'] as int) == 1;
      return Asset.fromJson(data);
    }
    return null;
  }

  /// Récupère la date de dernière mise à jour d'un actif dans le cache.
  Future<DateTime?> getLastUpdated(String symbol) async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query(
      'assets',
      columns: ['lastUpdated'],
      where: 'symbol = ?',
      whereArgs: [symbol],
    );

    if (maps.isNotEmpty) {
      final millis = maps.first['lastUpdated'] as int?;
      if (millis != null) {
        return DateTime.fromMillisecondsSinceEpoch(millis);
      }
    }
    return null;
  }
  
  /// Vide la base de données pour réinitialiser le cache.
  Future<void> clearCache() async {
    final database = await db;
    await database.delete('assets');
  }

  /// Ferme la connexion à la base de données (utile pour les tests).
  Future<void> close() async {
    final database = await db;
    await database.close();
    _database = null;
  }
}
