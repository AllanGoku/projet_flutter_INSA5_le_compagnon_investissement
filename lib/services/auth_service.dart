// [AI-GENERATED] Issue #1, Agent, 2025-02-23

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_profile.dart';

/// Service gérant l'authentification simulée en local.
///
/// Ce service persiste les données du profil utilisateur dans les SharedPreferences
/// et le mot de passe de façon sécurisée via flutter_secure_storage.
/// Il permet de mimer un backend d'authentification pour cette application éducative.
class AuthService {
  final SharedPreferencesAsync _prefs;
  final FlutterSecureStorage _secureStorage;

  static const String _userKey = 'user_profile';
  static const String _passwordKey = 'user_password';
  static const String _keepLoggedInKey = 'keep_logged_in';

  AuthService({
    SharedPreferencesAsync? prefs,
    FlutterSecureStorage? secureStorage,
  })  : _prefs = prefs ?? SharedPreferencesAsync(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Inscrit un nouvel utilisateur en sauvegardant son profil et son mot de passe.
  /// 
  /// Écrase l'utilisateur précédent s'il y en avait un (comportement d'app solo locale).
  Future<void> register(UserProfile user, String password) async {
    final String userJson = jsonEncode(user.toJson());
    await _prefs.setString(_userKey, userJson);
    await _secureStorage.write(key: _passwordKey, value: password);
  }

  /// Connecte l'utilisateur en vérifiant les identifiants fournis.
  ///
  /// Retourne le [UserProfile] si l'email et le mot de passe correspondent
  /// à ceux enregistrés. Renvoie une exception en cas d'erreur.
  Future<UserProfile> login(String email, String password, bool keepLoggedIn) async {
    final String? userJson = await _prefs.getString(_userKey);
    final String? storedPassword = await _secureStorage.read(key: _passwordKey);

    if (userJson == null || storedPassword == null) {
      throw Exception('Aucun compte trouvé.');
    }

    final Map<String, dynamic> userMap = jsonDecode(userJson);
    final UserProfile storedUser = UserProfile.fromJson(userMap);

    if (storedUser.email != email) {
      throw Exception('Email incorrect.');
    }

    if (storedPassword != password) {
      throw Exception('Mot de passe incorrect.');
    }

    // Sauvegarde de l'option "Maintenir la connexion"
    await _prefs.setBool(_keepLoggedInKey, keepLoggedIn);

    return storedUser;
  }

  /// Vérifie si l'utilisateur a choisi de maintenir sa connexion.
  Future<bool> isKeepLoggedIn() async {
    final bool? keep = await _prefs.getBool(_keepLoggedInKey);
    return keep ?? false;
  }

  /// Déconnecte l'utilisateur en effaçant le flag "Maintenir la connexion".
  Future<void> logout() async {
    await _prefs.setBool(_keepLoggedInKey, false);
  }

  /// Récupère le profil de l'utilisateur actuellement enregistré.
  Future<UserProfile?> getCurrentUser() async {
    final String? userJson = await _prefs.getString(_userKey);
    if (userJson != null) {
      return UserProfile.fromJson(jsonDecode(userJson));
    }
    return null;
  }
}
