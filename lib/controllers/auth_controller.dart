// [AI-GENERATED] Issue #1, Agent, 2025-02-23

import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';

/// Contrôleur gérant l'état de l'authentification.
///
/// Utilise le pattern ChangeNotifier pour notifier les vues des changements d'état
/// (chargement en cours, succès de la connexion, ou affichage d'une erreur).
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
        return _currentUser != null;
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
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
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
