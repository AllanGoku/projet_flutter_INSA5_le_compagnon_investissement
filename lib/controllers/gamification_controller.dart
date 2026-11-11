// [AI-GENERATED] Issue #7 & Multi-User Isolation, Agent, 2025-02-23
import 'package:flutter/material.dart';

import '../models/achievement.dart';
import '../models/leaderboard_entry.dart';
import '../models/financial_calculator.dart';
import '../services/cache_service.dart';
import '../services/auth_service.dart';

/// Contrôleur responsable de la gestion d'état de la gamification (XP, Succès, Classement).
class GamificationController extends ChangeNotifier {
  final CacheService _cacheService;
  final AuthService _authService;

  int _userXp = 0;
  List<Achievement> _achievements = [];
  List<Achievement> _newlyUnlockedQueue = [];
  final Set<String> _viewedAssetSymbols = {};
  String _userEmail = 'guest@app.local';

  GamificationController(this._cacheService, {AuthService? authService})
    : _authService = authService ?? AuthService();

  /// Le nombre total d'XP de l'utilisateur.
  int get userXp => _userXp;

  /// Le niveau actuel de l'utilisateur.
  int get level => FinancialCalculator.calculateLevel(_userXp);

  /// Le titre honorifique actuel.
  String get title => FinancialCalculator.getTitleForLevel(level);

  /// Liste de tous les succès (débloqués ou non).
  List<Achievement> get achievements => _achievements;

  /// File d'attente des succès récemment débloqués, à afficher dans l'UI (modale + confettis).
  List<Achievement> get newlyUnlockedQueue => _newlyUnlockedQueue;

  /// Email de l'utilisateur actif.
  String get userEmail => _userEmail;

  /// Enregistre la consultation d'un actif et vérifie si le succès "L'œil du Lynx" (5 actifs consultés) est débloqué.
  Future<void> trackAssetView(
    String symbol, {
    required double portfolioValue,
    required double totalInvested,
    required int portfolioAssetCount,
  }) async {
    _viewedAssetSymbols.add(symbol);
    final totalUniqueAssets = _viewedAssetSymbols.length > portfolioAssetCount
        ? _viewedAssetSymbols.length
        : portfolioAssetCount;
    await checkAchievements(
      portfolioValue: portfolioValue,
      totalInvested: totalInvested,
      assetCount: totalUniqueAssets,
      hasSimulatedDCA: false,
      readLexicon: false,
    );
  }

  /// Réinitialise l'XP et l'état des succès pour un `userEmail`.
  Future<void> resetGamification({String? userEmail}) async {
    final email = userEmail ?? _userEmail;
    _userXp = 0;
    _newlyUnlockedQueue.clear();
    _viewedAssetSymbols.clear();
    await _cacheService.clearAchievements(email);
    _initDefaultAchievements();
    for (var ach in _achievements) {
      await _cacheService.saveAchievement(ach, email);
    }
    notifyListeners();
  }

  /// Initialise les données (XP et succès) depuis SQLite pour un `userEmail`.
  Future<void> loadData([String? userEmail]) async {
    if (userEmail != null && userEmail.isNotEmpty) {
      _userEmail = userEmail;
      try {
        await _cacheService.migrateLegacyDataIfNeeded(_userEmail);
      } catch (_) {}
    }
    try {
      _userXp = await _cacheService.getUserXp(_userEmail);
      _achievements = await _cacheService.getAchievements(_userEmail);
    } catch (e) {
      debugPrint("Erreur lors du chargement de la gamification: $e");
    }

    if (_achievements.isEmpty) {
      _initDefaultAchievements();
      try {
        for (var ach in _achievements) {
          await _cacheService.saveAchievement(ach, _userEmail);
        }
      } catch (_) {}
    }
    notifyListeners();
  }

  void _initDefaultAchievements() {
    _achievements = [
      Achievement(
        id: 'first_step',
        title: 'Premier Pas',
        description: 'Ouvrir l\'application pour la première fois.',
        iconName: 'directions_walk',
        xpReward: 50,
      ),
      Achievement(
        id: 'lynx_eye',
        title: 'L\'œil du Lynx',
        description: 'Consulter au moins 5 actifs différents.',
        iconName: 'visibility',
        xpReward: 100,
      ),
      Achievement(
        id: 'market_linguist',
        title: 'Linguiste des marchés',
        description: 'Lire un article du lexique financier.',
        iconName: 'menu_book',
        xpReward: 150,
      ),
      Achievement(
        id: 'dca_pioneer',
        title: 'Pionnier du DCA',
        description: 'Simuler un investissement programmé (DCA).',
        iconName: 'timeline',
        xpReward: 200,
      ),
      Achievement(
        id: 'diversified_investor',
        title: 'Investisseur Diversifié',
        description: 'Posséder au moins 3 actifs différents en portefeuille.',
        iconName: 'pie_chart',
        xpReward: 250,
      ),
      Achievement(
        id: 'cap_5k',
        title: 'Cap des 5k €',
        description: 'Atteindre une valeur de portefeuille de 5 000 €.',
        iconName: 'emoji_events',
        xpReward: 300,
      ),
      Achievement(
        id: 'master_profit',
        title: 'Maître du Profit',
        description: 'Générer plus de 1 000 € de plus-value.',
        iconName: 'trending_up',
        xpReward: 400,
      ),
      Achievement(
        id: 'golden_patience',
        title: 'Patience d\'Or',
        description: 'Cumuler 10 000 points d\'expérience.',
        iconName: 'hourglass_bottom',
        xpReward: 500,
      ),
    ];
  }

  /// Ajoute des points d'XP, les sauvegarde et notifie l'UI.
  Future<void> awardXp(int amount) async {
    if (amount <= 0) return;
    _userXp += amount;
    try {
      await _cacheService.saveUserXp(_userXp, _userEmail);
    } catch (_) {}
    notifyListeners();
    // Peut déclencher "Patience d'Or"
    await checkAchievements(
      portfolioValue: 0.0,
      totalInvested: 0.0,
      assetCount: 0,
      hasSimulatedDCA: false,
      readLexicon: false,
    );
  }

  /// Vérifie si de nouveaux succès sont débloqués en fonction de l'état actuel de l'utilisateur.
  Future<void> checkAchievements({
    required double portfolioValue,
    required double totalInvested,
    required int assetCount,
    required bool hasSimulatedDCA,
    required bool readLexicon,
  }) async {
    final newlyUnlockedIds = FinancialCalculator.checkAchievementUnlock(
      achievements: _achievements,
      userXp: _userXp,
      portfolioValue: portfolioValue,
      totalInvested: totalInvested,
      assetCount: assetCount,
      hasSimulatedDCA: hasSimulatedDCA,
      readLexicon: readLexicon,
    );

    if (newlyUnlockedIds.isNotEmpty) {
      for (var id in newlyUnlockedIds) {
        final index = _achievements.indexWhere((a) => a.id == id);
        if (index != -1) {
          final ach = _achievements[index];
          final updatedAch = ach.copyWith(
            isUnlocked: true,
            unlockedAt: DateTime.now(),
          );

          _achievements[index] = updatedAch;
          try {
            await _cacheService.saveAchievement(updatedAch, _userEmail);
          } catch (_) {}

          _newlyUnlockedQueue.add(updatedAch);

          // Gagner l'XP de la récompense (sans déclencher de boucle infinie sur checkAchievements)
          _userXp += updatedAch.xpReward;
          try {
            await _cacheService.saveUserXp(_userXp, _userEmail);
          } catch (_) {}
        }
      }
      notifyListeners();
    }
  }

  /// Vide la file d'attente une fois que les modales ont été affichées à l'utilisateur.
  void clearNewlyUnlockedQueue() {
    _newlyUnlockedQueue.clear();
    notifyListeners();
  }

  /// Récupère le classement (Leaderboard) de façon asynchrone en incluant tous les utilisateurs enregistrés.
  Future<List<LeaderboardEntry>> getLeaderboard(
    double userPortfolioValue,
    double userPerformancePercentage, {
    LeaderboardSortCriteria sortBy = LeaderboardSortCriteria.xp,
  }) async {
    final realEntries = <LeaderboardEntry>[];

    try {
      final allUsers = await _authService.getAllUsers();
      for (final u in allUsers) {
        final email = u.email.trim().toLowerCase();
        final isCurrent = email == _userEmail.trim().toLowerCase();

        double portValue = 0.0;
        double perf = 0.0;
        int xp = u.xp;

        if (isCurrent) {
          portValue = userPortfolioValue;
          perf = userPerformancePercentage;
          xp = _userXp;
        } else {
          final pos = await _cacheService.getPortfolioPositions(email);
          final mapPos = pos
              .map(
                (p) => {
                  'quantity': p.quantity,
                  'currentPrice': p.asset.currentPrice,
                  'averagePurchasePrice': p.averagePurchasePrice,
                },
              )
              .toList();

          portValue = FinancialCalculator.calculatePortfolioValue(mapPos);
          final totalInvested = FinancialCalculator.calculateTotalInvested(
            mapPos,
          );
          perf = FinancialCalculator.calculatePerformance(
            initialValue: totalInvested,
            currentValue: portValue,
          );
          final savedXp = await _cacheService.getUserXp(email);
          if (savedXp > xp) xp = savedXp;
        }

        final firstName = u.firstName.isNotEmpty ? u.firstName : 'Utilisateur';
        final lastNameInitial = u.lastName.isNotEmpty
            ? '${u.lastName[0]}.'
            : '';
        final initials =
            (firstName[0] + (u.lastName.isNotEmpty ? u.lastName[0] : ''))
                .toUpperCase();

        realEntries.add(
          LeaderboardEntry(
            rank: 0,
            name: isCurrent
                ? 'Vous ($firstName)'
                : '$firstName $lastNameInitial',
            avatarInitials: initials,
            level: FinancialCalculator.calculateLevel(xp),
            xp: xp,
            portfolioValue: portValue,
            performancePercentage: perf,
            isCurrentUser: isCurrent,
          ),
        );
      }
    } catch (e) {
      debugPrint(
        "Erreur lors du chargement multi-utilisateur du classement: $e",
      );
    }

    return FinancialCalculator.generateMockLeaderboardEntries(
      userXp: _userXp,
      userPortfolioValue: userPortfolioValue,
      userPerformancePercentage: userPerformancePercentage,
      sortBy: sortBy,
      realUsers: realEntries,
    );
  }
}
