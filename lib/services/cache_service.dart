// [AI-GENERATED] Phase 9, Agent, 2025-02-23
import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/asset.dart';
import '../models/portfolio_position.dart';
import '../models/portfolio_transaction.dart';
import '../models/achievement.dart';

/// Service responsable de la persistance locale des actifs (actions/ETF),
/// des positions du portefeuille, des transactions et des succès de CHAQUE utilisateur.
/// Utilise SQLite avec isolation par `userEmail` pour permettre la gestion multi-utilisateur.
class CacheService {
  Database? _database;

  /// Initialise la connexion à la base de données SQLite.
  Future<void> initDB({bool inMemory = false}) async {
    if (_database != null) return;

    if (inMemory) {
      _database = await openDatabase(
        inMemoryDatabasePath,
        version: 1,
        onCreate: _onCreate,
      );
    } else {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'compagnon_investissement.db');
      _database = await openDatabase(path, version: 1, onCreate: _onCreate);
    }

    // S'assurer que les tables existent
    await _database!.execute('''
      CREATE TABLE IF NOT EXISTS assets(
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

    await _database!.execute('''
      CREATE TABLE IF NOT EXISTS portfolio(
        symbol TEXT,
        userEmail TEXT,
        quantity REAL,
        averagePurchasePrice REAL,
        PRIMARY KEY (symbol, userEmail)
      )
    ''');

    await _database!.execute('''
      CREATE TABLE IF NOT EXISTS transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userEmail TEXT,
        symbol TEXT,
        assetName TEXT,
        type TEXT,
        quantity REAL,
        price REAL,
        timestamp INTEGER,
        realizedGain REAL
      )
    ''');

    await _database!.execute('''
      CREATE TABLE IF NOT EXISTS settings(
        key TEXT PRIMARY KEY,
        value REAL
      )
    ''');

    await _database!.execute('''
      CREATE TABLE IF NOT EXISTS achievements(
        id TEXT,
        userEmail TEXT,
        title TEXT,
        description TEXT,
        iconName TEXT,
        xpReward INTEGER,
        isUnlocked INTEGER,
        unlockedAt TEXT,
        PRIMARY KEY (id, userEmail)
      )
    ''');

    // Migrations de structure
    try {
      await _database!.execute(
        'ALTER TABLE assets ADD COLUMN changePercentage REAL',
      );
    } catch (_) {}
    try {
      await _database!.execute(
        'ALTER TABLE assets ADD COLUMN originalCurrency TEXT',
      );
    } catch (_) {}
    try {
      await _database!.execute(
        'ALTER TABLE assets ADD COLUMN originalPrice REAL',
      );
    } catch (_) {}
    try {
      await _database!.execute(
        'ALTER TABLE transactions ADD COLUMN realizedGain REAL',
      );
    } catch (_) {}
    try {
      await _database!.execute(
        "ALTER TABLE portfolio ADD COLUMN userEmail TEXT DEFAULT 'guest@app.local'",
      );
    } catch (_) {}
    try {
      await _database!.execute(
        "ALTER TABLE transactions ADD COLUMN userEmail TEXT DEFAULT 'guest@app.local'",
      );
    } catch (_) {}
    try {
      await _database!.execute(
        "ALTER TABLE achievements ADD COLUMN userEmail TEXT DEFAULT 'guest@app.local'",
      );
    } catch (_) {}
  }

  /// Fournit l'instance de la base de données.
  Future<Database> get db async {
    if (_database == null) {
      await initDB();
    }
    if (_database == null) {
      throw Exception('Database not initialized');
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
        symbol TEXT,
        userEmail TEXT,
        quantity REAL,
        averagePurchasePrice REAL,
        PRIMARY KEY (symbol, userEmail)
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userEmail TEXT,
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

    await db.execute('''
      CREATE TABLE achievements(
        id TEXT,
        userEmail TEXT,
        title TEXT,
        description TEXT,
        iconName TEXT,
        xpReward INTEGER,
        isUnlocked INTEGER,
        unlockedAt TEXT,
        PRIMARY KEY (id, userEmail)
      )
    ''');
  }

  /// Migre automatiquement les données pré-existantes (sauvegardées sous 'guest@app.local' ou sans email) vers le compte utilisateur actif s'il n'a pas encore de données.
  Future<void> migrateLegacyDataIfNeeded(String targetUserEmail) async {
    if (targetUserEmail.isEmpty || targetUserEmail == 'guest@app.local') return;

    try {
      final database = await db;

      // Vérifie si l'utilisateur actif a déjà des données de portefeuille
      final userPositions = await database.query(
        'portfolio',
        where: 'userEmail = ?',
        whereArgs: [targetUserEmail],
      );

      if (userPositions.isEmpty) {
        // Vérifie s'il existe des positions héritées sous 'guest@app.local' ou sans email
        final legacyPositions = await database.query(
          'portfolio',
          where: "userEmail = 'guest@app.local' OR userEmail IS NULL OR userEmail = ''",
        );

        if (legacyPositions.isNotEmpty) {
          // Migre les positions
          await database.update(
            'portfolio',
            {'userEmail': targetUserEmail},
            where: "userEmail = 'guest@app.local' OR userEmail IS NULL OR userEmail = ''",
          );

          // Migre les transactions
          await database.update(
            'transactions',
            {'userEmail': targetUserEmail},
            where: "userEmail = 'guest@app.local' OR userEmail IS NULL OR userEmail = ''",
          );

          // Migre les succès
          await database.update(
            'achievements',
            {'userEmail': targetUserEmail},
            where: "userEmail = 'guest@app.local' OR userEmail IS NULL OR userEmail = ''",
          );

          // Migre le solde de liquidités et l'XP s'ils existent sous l'ancienne clé
          final legacyCash = await database.query(
            'settings',
            where: "key = 'cashBalance' OR key = 'cashBalance_guest@app.local'",
          );
          if (legacyCash.isNotEmpty && legacyCash.first['value'] != null) {
            final val = (legacyCash.first['value'] as num).toDouble();
            await saveCashBalance(val, targetUserEmail);
          }

          final legacyXp = await database.query(
            'settings',
            where: "key = 'userXp' OR key = 'userXp_guest@app.local'",
          );
          if (legacyXp.isNotEmpty && legacyXp.first['value'] != null) {
            final val = (legacyXp.first['value'] as num).toInt();
            await saveUserXp(val, targetUserEmail);
          }
        }
      }
    } catch (e) {
      // Ignorer les erreurs non critiques lors de la migration
    }
  }

  /// Sauvegarde un [Asset] dans le cache local.
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
      'lastUpdated': lastUpdatedMillis ?? asset.lastUpdated?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
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

  /// Récupère un [Asset] depuis le cache.
  Future<Asset?> getAsset(String symbol) async {
    try {
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
    } catch (e) {
      // Ignorer les erreurs d'accès DB non initialisée
    }
    return null;
  }

  /// Récupère l'ensemble des actifs enregistrés.
  Future<List<Asset>> getAllAssets() async {
    try {
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
    } catch (e) {
      return [];
    }
  }

  /// Sauvegarde les positions du portefeuille spécifiques à un `userEmail`.
  Future<void> savePortfolioPositions(
    List<PortfolioPosition> positions, [
    String userEmail = 'guest@app.local',
  ]) async {
    final database = await db;
    await database.transaction((txn) async {
      await txn.delete(
        'portfolio',
        where: 'userEmail = ?',
        whereArgs: [userEmail],
      );
      for (var pos in positions) {
        final Map<String, dynamic> assetMap = {
          'symbol': pos.asset.symbol,
          'name': pos.asset.name,
          'currentPrice': pos.asset.currentPrice,
          'type': pos.asset.type,
          'description': pos.asset.description,
          'marketOpen': pos.asset.marketOpen ? 1 : 0,
          'timezone': pos.asset.timezone,
          'timeSeries': jsonEncode(pos.asset.toJson()['timeSeries']),
          'lastUpdated': pos.asset.lastUpdated?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
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

        await txn.insert('portfolio', {
          'symbol': pos.asset.symbol,
          'userEmail': userEmail,
          'quantity': pos.quantity,
          'averagePurchasePrice': pos.averagePurchasePrice,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  /// Récupère toutes les positions du portefeuille spécifiques à un `userEmail`.
  Future<List<PortfolioPosition>> getPortfolioPositions([
    String userEmail = 'guest@app.local',
  ]) async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query(
      'portfolio',
      where: 'userEmail = ?',
      whereArgs: [userEmail],
    );
    final List<PortfolioPosition> positions = [];

    for (var map in maps) {
      final String symbol = map['symbol'] as String;
      final double quantity = (map['quantity'] as num).toDouble();
      final double averagePurchasePrice = (map['averagePurchasePrice'] as num)
          .toDouble();

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

      positions.add(
        PortfolioPosition(
          asset: asset,
          quantity: quantity,
          averagePurchasePrice: averagePurchasePrice,
        ),
      );
    }

    return positions;
  }

  /// Récupère la date de dernière mise à jour d'un actif.
  Future<DateTime?> getLastUpdated(String symbol) async {
    try {
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
    } catch (e) {
      // Ignorer si la base de données n'est pas initialisée
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

  /// Supprime les données du portefeuille et transactions pour un `userEmail`.
  Future<void> clearPortfolioAndTransactions([
    String userEmail = 'guest@app.local',
  ]) async {
    final database = await db;
    await database.delete(
      'portfolio',
      where: 'userEmail = ?',
      whereArgs: [userEmail],
    );
    await database.delete(
      'transactions',
      where: 'userEmail = ?',
      whereArgs: [userEmail],
    );
    await saveCashBalance(1000.0, userEmail);
  }

  /// Vide la table des succès et réinitialise l'XP d'un `userEmail`.
  Future<void> clearAchievements([String userEmail = 'guest@app.local']) async {
    final database = await db;
    await database.delete(
      'achievements',
      where: 'userEmail = ?',
      whereArgs: [userEmail],
    );
    await saveUserXp(0, userEmail);
  }

  /// Sauvegarde une transaction pour un `userEmail`.
  Future<void> saveTransaction(
    PortfolioTransaction transaction, [
    String userEmail = 'guest@app.local',
  ]) async {
    final database = await db;
    final map = transaction.toMap();
    map['userEmail'] = userEmail;
    await database.insert(
      'transactions',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Récupère toutes les transactions enregistrées pour un `userEmail`.
  Future<List<PortfolioTransaction>> getTransactions([
    String userEmail = 'guest@app.local',
  ]) async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query(
      'transactions',
      where: 'userEmail = ?',
      whereArgs: [userEmail],
      orderBy: 'timestamp DESC',
    );
    return maps.map((map) => PortfolioTransaction.fromMap(map)).toList();
  }

  /// Supprime la position d'un actif du portefeuille pour un `userEmail`.
  Future<void> deletePortfolioPosition(
    String symbol, [
    String userEmail = 'guest@app.local',
  ]) async {
    final database = await db;
    await database.delete(
      'portfolio',
      where: 'symbol = ? AND userEmail = ?',
      whereArgs: [symbol, userEmail],
    );
  }

  /// Sauvegarde le solde de liquidités pour un `userEmail`.
  Future<void> saveCashBalance(
    double balance, [
    String userEmail = 'guest@app.local',
  ]) async {
    final database = await db;
    await database.insert('settings', {
      'key': 'cashBalance_$userEmail',
      'value': balance,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Récupère le solde de liquidités pour un `userEmail`. Default = 1000.0.
  Future<double> getCashBalance([String userEmail = 'guest@app.local']) async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query(
      'settings',
      where: 'key = ?',
      whereArgs: ['cashBalance_$userEmail'],
    );
    if (maps.isNotEmpty && maps.first['value'] != null) {
      return (maps.first['value'] as num).toDouble();
    }
    return 1000.0;
  }

  /// Ferme la connexion à la base de données.
  Future<void> close() async {
    final database = await db;
    await database.close();
    _database = null;
  }

  /// Sauvegarde un [Achievement] pour un `userEmail`.
  Future<void> saveAchievement(
    Achievement achievement, [
    String userEmail = 'guest@app.local',
  ]) async {
    final database = await db;
    final map = achievement.toMap();
    map['userEmail'] = userEmail;
    await database.insert(
      'achievements',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Récupère la liste des [Achievement] d'un `userEmail`.
  Future<List<Achievement>> getAchievements([
    String userEmail = 'guest@app.local',
  ]) async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query(
      'achievements',
      where: 'userEmail = ?',
      whereArgs: [userEmail],
    );
    return maps.map((map) => Achievement.fromMap(map)).toList();
  }

  /// Récupère l'XP total d'un `userEmail`.
  Future<int> getUserXp([String userEmail = 'guest@app.local']) async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query(
      'settings',
      where: 'key = ?',
      whereArgs: ['userXp_$userEmail'],
    );
    if (maps.isNotEmpty && maps.first['value'] != null) {
      return (maps.first['value'] as num).toInt();
    }
    return 0;
  }

  /// Sauvegarde l'XP total d'un `userEmail`.
  Future<void> saveUserXp(
    int xp, [
    String userEmail = 'guest@app.local',
  ]) async {
    final database = await db;
    await database.insert('settings', {
      'key': 'userXp_$userEmail',
      'value': xp,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
