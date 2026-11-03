// [AI-GENERATED] Phase 2, Agent, 2025-02-23
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/asset.dart';
import '../models/portfolio_position.dart';
import '../models/portfolio_transaction.dart';

/// Service responsable de la persistance locale des actifs (actions/ETF)
/// et des positions du portefeuille fictif.
/// Utilise SQLite pour stocker de manière robuste les données et l'historique
/// des cours afin de limiter les requêtes API (Twelve Data) et permettre
/// un fonctionnement hors-connexion.
class CacheService {
  Database? _database;

  /// Initialise la connexion à la base de données SQLite.
  /// Crée les tables 'assets' et 'portfolio' si elles n'existent pas et pré-alimente la base.
  Future<void> initDB({bool inMemory = false}) async {
    if (_database != null) return;

    if (inMemory) {
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

    // S'assurer que la table portfolio existe même si la base existait déjà
    await _database!.execute('''
      CREATE TABLE IF NOT EXISTS portfolio(
        symbol TEXT PRIMARY KEY,
        quantity REAL,
        averagePurchasePrice REAL
      )
    ''');

    // S'assurer que la table transactions existe
    await _database!.execute('''
      CREATE TABLE IF NOT EXISTS transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        symbol TEXT,
        assetName TEXT,
        type TEXT,
        quantity REAL,
        price REAL,
        timestamp INTEGER,
        realizedGain REAL
      )
    ''');

    // S'assurer que la table settings existe pour les paramètres globaux (ex: solde de liquidités)
    await _database!.execute('''
      CREATE TABLE IF NOT EXISTS settings(
        key TEXT PRIMARY KEY,
        value REAL
      )
    ''');

    // Migrations de structure pour s'assurer que les nouvelles colonnes existent sur les bases préexistantes
    try {
      await _database!.execute('ALTER TABLE assets ADD COLUMN changePercentage REAL');
    } catch (_) {}
    try {
      await _database!.execute('ALTER TABLE assets ADD COLUMN originalCurrency TEXT');
    } catch (_) {}
    try {
      await _database!.execute('ALTER TABLE assets ADD COLUMN originalPrice REAL');
    } catch (_) {}
    try {
      await _database!.execute('ALTER TABLE transactions ADD COLUMN realizedGain REAL');
    } catch (_) {}

    // Pré-alimentation initiale supprimée (utilisation de l'API)
    if (!inMemory) {
      // Les données sont maintenant dynamiquement chargées depuis l'API.
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
        lastUpdated INTEGER,
        changePercentage REAL,
        originalCurrency TEXT,
        originalPrice REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE portfolio(
        symbol TEXT PRIMARY KEY,
        quantity REAL,
        averagePurchasePrice REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        symbol TEXT,
        assetName TEXT,
        type TEXT,
        quantity REAL,
        price REAL,
        timestamp INTEGER,
        realizedGain REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE settings(
        key TEXT PRIMARY KEY,
        value REAL
      )
    ''');
  }

  /// Sauvegarde un [Asset] dans le cache local (insert ou replace).
  Future<void> saveAsset(Asset asset, {int? lastUpdatedMillis}) async {
    final database = await db;
    final Map<String, dynamic> assetMap = {
      'symbol': asset.symbol,
      'name': asset.name,
      'currentPrice': asset.currentPrice,
      'type': asset.type,
      'description': asset.description,
      'marketOpen': asset.marketOpen ? 1 : 0,
      'timezone': asset.timezone,
      'timeSeries': jsonEncode(asset.toJson()['timeSeries']),
      'lastUpdated': lastUpdatedMillis ?? DateTime.now().millisecondsSinceEpoch,
      'originalCurrency': asset.originalCurrency,
      'originalPrice': asset.originalPrice,
    };

    if (asset.changePercentage != null) {
      assetMap['changePercentage'] = asset.changePercentage;
    }

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
      if (data['timeSeries'] != null) {
        data['timeSeries'] = jsonDecode(data['timeSeries'] as String);
      } else {
        data['timeSeries'] = {};
      }
      data['marketOpen'] = (data['marketOpen'] as int?) == 1;
      return Asset.fromJson(data);
    }
    return null;
  }

  /// Récupère l'ensemble des actifs enregistrés dans la table 'assets' de la base SQLite.
  Future<List<Asset>> getAllAssets() async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query('assets');
    final List<Asset> assets = [];

    for (var map in maps) {
      final data = Map<String, dynamic>.from(map);
      if (data['timeSeries'] != null) {
        data['timeSeries'] = jsonDecode(data['timeSeries'] as String);
      } else {
        data['timeSeries'] = {};
      }
      data['marketOpen'] = (data['marketOpen'] as int?) == 1;
      assets.add(Asset.fromJson(data));
    }

    return assets;
  }

  /// Sauvegarde l'ensemble des positions du portefeuille fictif dans SQLite.
  ///
  /// Met à jour la table 'portfolio' et s'assure également de conserver la fiche de
  /// chaque actif [Asset] dans la table 'assets'.
  Future<void> savePortfolioPositions(List<PortfolioPosition> positions) async {
    final database = await db;
    await database.transaction((txn) async {
      await txn.delete('portfolio');
      for (var pos in positions) {
        // Sauvegarde de l'actif associé
        final Map<String, dynamic> assetMap = {
          'symbol': pos.asset.symbol,
          'name': pos.asset.name,
          'currentPrice': pos.asset.currentPrice,
          'type': pos.asset.type,
          'description': pos.asset.description,
          'marketOpen': pos.asset.marketOpen ? 1 : 0,
          'timezone': pos.asset.timezone,
          'timeSeries': jsonEncode(pos.asset.toJson()['timeSeries']),
          'lastUpdated': DateTime.now().millisecondsSinceEpoch,
          'originalCurrency': pos.asset.originalCurrency,
          'originalPrice': pos.asset.originalPrice,
        };
        if (pos.asset.changePercentage != null) {
          assetMap['changePercentage'] = pos.asset.changePercentage;
        }

        await txn.insert(
          'assets',
          assetMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Sauvegarde de la ligne du portefeuille
        await txn.insert(
          'portfolio',
          {
            'symbol': pos.asset.symbol,
            'quantity': pos.quantity,
            'averagePurchasePrice': pos.averagePurchasePrice,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  /// Récupère toutes les positions du portefeuille fictif enregistrées en SQLite.
  ///
  /// Pour chaque position, tente de charger l'actif complet [Asset] depuis la table 'assets'.
  /// Si l'actif n'est pas trouvé dans la table 'assets', construit une instance par défaut.
  Future<List<PortfolioPosition>> getPortfolioPositions() async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query('portfolio');
    final List<PortfolioPosition> positions = [];

    for (var map in maps) {
      final String symbol = map['symbol'] as String;
      final double quantity = (map['quantity'] as num).toDouble();
      final double averagePurchasePrice = (map['averagePurchasePrice'] as num).toDouble();

      Asset? asset = await getAsset(symbol);
      asset ??= Asset(
        symbol: symbol,
        name: symbol,
        currentPrice: averagePurchasePrice,
        type: 'Stock',
        description: '',
        marketOpen: true,
        timezone: 'UTC',
        timeSeries: {},
      );

      positions.add(PortfolioPosition(
        asset: asset,
        quantity: quantity,
        averagePurchasePrice: averagePurchasePrice,
      ));
    }

    return positions;
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
  
  /// Vide la base de données pour réinitialiser le cache (assets compris).
  Future<void> clearCache() async {
    final database = await db;
    await database.delete('assets');
    await database.delete('portfolio');
    await database.delete('transactions');
  }

  /// Vide uniquement le portefeuille et l'historique de transactions (réinitialisation de compte).
  Future<void> clearPortfolioAndTransactions() async {
    final database = await db;
    await database.delete('portfolio');
    await database.delete('transactions');
    await saveCashBalance(1000.0);
  }

  /// Sauvegarde une transaction (achat ou revente) dans la table SQLite `transactions`.
  Future<void> saveTransaction(PortfolioTransaction transaction) async {
    final database = await db;
    await database.insert(
      'transactions',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Récupère toutes les transactions enregistrées en SQLite, triées de la plus récente à la plus ancienne.
  Future<List<PortfolioTransaction>> getTransactions() async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query(
      'transactions',
      orderBy: 'timestamp DESC',
    );
    return maps.map((map) => PortfolioTransaction.fromMap(map)).toList();
  }

  /// Supprime la position d'un actif du portefeuille dans SQLite (utilisé lors d'une revente totale).
  Future<void> deletePortfolioPosition(String symbol) async {
    final database = await db;
    await database.delete(
      'portfolio',
      where: 'symbol = ?',
      whereArgs: [symbol],
    );
  }

  /// Sauvegarde le solde de liquidités disponible en Euros (€) dans la table `settings`.
  Future<void> saveCashBalance(double balance) async {
    final database = await db;
    await database.insert(
      'settings',
      {'key': 'cashBalance', 'value': balance},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Récupère le solde de liquidités disponible en Euros (€).
  /// Retourne un solde initial par défaut de 1 000,00 € si aucun solde n'a été enregistré.
  Future<double> getCashBalance() async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query(
      'settings',
      where: 'key = ?',
      whereArgs: ['cashBalance'],
    );
    if (maps.isNotEmpty && maps.first['value'] != null) {
      return (maps.first['value'] as num).toDouble();
    }
    return 1000.0;
  }

  /// Ferme la connexion à la base de données (utile pour les tests).
  Future<void> close() async {
    final database = await db;
    await database.close();
    _database = null;
  }
}
