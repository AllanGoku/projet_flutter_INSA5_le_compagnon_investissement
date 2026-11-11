// [AI-GENERATED] Issue #5, Agent, 2025-02-23

import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../models/financial_calculator.dart';

/// Contrôleur gérant l'état de l'authentification et du profil utilisateur.
///
/// Gère la connexion, la déconnexion, ainsi que la progression de l'utilisateur (XP, Niveaux).
class AuthController extends ChangeNotifier {
  final AuthService _authService;

  bool _isLoading = false;
  String? _error;
  UserProfile? _currentUser;

  AuthController({AuthService? authService})
    : _authService = authService ?? AuthService();

  bool get isLoading => _isLoading;
  String? get error => _error;
  UserProfile? get currentUser => _currentUser;

  /// Tente de vérifier si un utilisateur avait demandé à maintenir sa connexion.
  Future<bool> checkKeepLoggedIn() async {
    try {
      final bool keep = await _authService.isKeepLoggedIn();
      if (keep) {
        _currentUser = await _authService.getCurrentUser();
        if (_currentUser != null) {
          await _processLoginStreak();
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Inscrit un nouvel utilisateur.
  Future<bool> register(UserProfile user, String password) async {
    _setLoading(true);
    _error = null;
    try {
      await _authService.register(user, password);
      // Après inscription, on connecte directement l'utilisateur
      await login(user.email, password, false);
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Connecte un utilisateur existant.
  Future<bool> login(String email, String password, bool keepLoggedIn) async {
    _setLoading(true);
    _error = null;
    try {
      _currentUser = await _authService.login(email, password, keepLoggedIn);
      await _processLoginStreak();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Gère la série de connexions quotidiennes et attribue l'XP correspondant.
  Future<void> _processLoginStreak() async {
    if (_currentUser == null) return;

    final now = DateTime.now();
    final lastLogin = _currentUser!.lastLoginDate;

    int newStreak = _currentUser!.streak;
    int xpGained = 0;

    if (lastLogin == null) {
      // Première connexion
      newStreak = 1;
      xpGained = FinancialCalculator.calculateStreakBonus(newStreak);
    } else {
      final difference = DateTime(now.year, now.month, now.day)
          .difference(DateTime(lastLogin.year, lastLogin.month, lastLogin.day))
          .inDays;

      if (difference == 1) {
        // Connexion consécutive
        newStreak += 1;
        xpGained = FinancialCalculator.calculateStreakBonus(newStreak);
      } else if (difference > 1) {
        // Série brisée
        newStreak = 1;
        xpGained = FinancialCalculator.calculateStreakBonus(newStreak);
      }
      // Si difference == 0, déjà connecté aujourd'hui, pas de bonus
    }

    if (xpGained > 0 ||
        lastLogin == null ||
        newStreak != _currentUser!.streak) {
      await addXp(xpGained, newStreak: newStreak, newLoginDate: now);
    }
  }

  /// Ajoute de l'XP à l'utilisateur et met à jour ses records et son niveau.
  Future<void> addXp(
    int amount, {
    int? newStreak,
    DateTime? newLoginDate,
  }) async {
    if (_currentUser == null ||
        amount < 0 && newStreak == null && newLoginDate == null)
      return;

    final int newXp = (_currentUser!.xp + amount).clamp(
      0,
      double.maxFinite.toInt(),
    );
    final int newLevel = FinancialCalculator.calculateLevel(newXp);

    final int highestXp = newXp > _currentUser!.highestXpReached
        ? newXp
        : _currentUser!.highestXpReached;
    final int highestLevel = newLevel > _currentUser!.highestLevelReached
        ? newLevel
        : _currentUser!.highestLevelReached;

    final updatedUser = _currentUser!.copyWith(
      xp: newXp,
      level: newLevel,
      highestXpReached: highestXp,
      highestLevelReached: highestLevel,
      streak: newStreak ?? _currentUser!.streak,
      lastLoginDate: newLoginDate ?? _currentUser!.lastLoginDate,
    );

    await _authService.updateUser(updatedUser);
    _currentUser = updatedUser;
    notifyListeners();
  }

  /// Synchronise l'XP de l'utilisateur avec la valeur centrale du GamificationController.
  Future<void> syncXp(int targetXp) async {
    if (_currentUser == null) return;
    if (_currentUser!.xp == targetXp) return;

    final int newLevel = FinancialCalculator.calculateLevel(targetXp);
    final int highestXp = targetXp > _currentUser!.highestXpReached
        ? targetXp
        : _currentUser!.highestXpReached;
    final int highestLevel = newLevel > _currentUser!.highestLevelReached
        ? newLevel
        : _currentUser!.highestLevelReached;

    final updatedUser = _currentUser!.copyWith(
      xp: targetXp,
      level: newLevel,
      highestXpReached: highestXp,
      highestLevelReached: highestLevel,
    );

    await _authService.updateUser(updatedUser);
    _currentUser = updatedUser;
    notifyListeners();
  }

  /// Met à jour le record de la valeur du portefeuille si la nouvelle valeur est plus élevée.
  Future<void> updateHighestPortfolioValue(double value) async {
    if (_currentUser == null) return;
    if (value > _currentUser!.highestPortfolioValueReached) {
      final updatedUser = _currentUser!.copyWith(
        highestPortfolioValueReached: value,
      );
      await _authService.updateUser(updatedUser);
      _currentUser = updatedUser;
      // On ne notifie pas forcément pour ne pas surcharger, sauf si affiché
      notifyListeners();
    }
  }

  /// Bascule l'affichage des conseils pédagogiques.
  Future<void> toggleShowTips(bool show) async {
    if (_currentUser == null) return;
    final updatedUser = _currentUser!.copyWith(showTips: show);
    await _authService.updateUser(updatedUser);
    _currentUser = updatedUser;
    notifyListeners();
  }

  /// Réinitialise le compte utilisateur (XP, Niveau) en gardant les records et le streak.
  Future<void> resetAccount() async {
    if (_currentUser == null) return;
    final updatedUser = _currentUser!.copyWith(
      xp: 0,
      level: 1,
      // On garde highestLevelReached, highestXpReached, highestPortfolioValueReached, streak
    );
    await _authService.updateUser(updatedUser);
    _currentUser = updatedUser;
    notifyListeners();
  }

  /// Déconnecte l'utilisateur.
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
