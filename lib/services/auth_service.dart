// [AI-GENERATED] Issue #1 & Multi-Account Email Uniqueness & Leaderboard Users, Agent, 2025-02-23

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user_profile.dart';

/// Service gérant l'authentification simulée en local avec gestion d'unicité d'email et liste multi-utilisateurs.
class AuthService {
  final SharedPreferencesAsync _prefs;
  final FlutterSecureStorage _secureStorage;

  static const String _userKey = 'user_profile';
  static const String _passwordKey = 'user_password';
  static const String _keepLoggedInKey = 'keep_logged_in';

  AuthService({
    SharedPreferencesAsync? prefs,
    FlutterSecureStorage? secureStorage,
  }) : _prefs = prefs ?? SharedPreferencesAsync(),
       _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Enregistre un e-mail dans la liste globale des comptes créés.
  Future<void> _trackRegisteredEmail(String emailKey) async {
    final String? currentListJson = await _prefs.getString(
      'registered_user_emails_list',
    );
    List<String> emails = [];
    if (currentListJson != null && currentListJson.isNotEmpty) {
      try {
        emails = List<String>.from(jsonDecode(currentListJson));
      } catch (_) {}
    }
    if (!emails.contains(emailKey)) {
      emails.add(emailKey);
      await _prefs.setString('registered_user_emails_list', jsonEncode(emails));
    }
  }

  /// Récupère la liste de tous les comptes d'utilisateurs enregistrés sur cet appareil.
  Future<List<UserProfile>> getAllUsers() async {
    final List<UserProfile> users = [];
    final String? currentListJson = await _prefs.getString(
      'registered_user_emails_list',
    );
    List<String> emails = [];

    if (currentListJson != null && currentListJson.isNotEmpty) {
      try {
        emails = List<String>.from(jsonDecode(currentListJson));
      } catch (_) {}
    }

    for (var emailKey in emails) {
      final String? userJson = await _prefs.getString('user_profile_$emailKey');
      if (userJson != null) {
        try {
          users.add(UserProfile.fromJson(jsonDecode(userJson)));
        } catch (_) {}
      }
    }

    // Si aucun compte dans la liste mais qu'un compte courant existe
    if (users.isEmpty) {
      final currentUser = await getCurrentUser();
      if (currentUser != null) {
        users.add(currentUser);
        await _trackRegisteredEmail(currentUser.email.trim().toLowerCase());
      }
    }

    return users;
  }

  /// Inscrit un nouvel utilisateur en vérifiant l'unicité de son e-mail.
  Future<void> register(UserProfile user, String password) async {
    final String emailKey = user.email.trim().toLowerCase();

    // Vérification de l'unicité de l'email
    final String? existingJson = await _prefs.getString(
      'user_profile_$emailKey',
    );
    if (existingJson != null) {
      throw Exception(
        'Un compte avec l\'adresse email "${user.email}" existe déjà.',
      );
    }

    final String userJson = jsonEncode(user.toJson());
    await _prefs.setString('user_profile_$emailKey', userJson);
    await _secureStorage.write(key: 'user_password_$emailKey', value: password);
    await _prefs.setString('active_user_email', emailKey);
    await _trackRegisteredEmail(emailKey);

    // Compatibilité rétroactive mono-utilisateur
    await _prefs.setString(_userKey, userJson);
    await _secureStorage.write(key: _passwordKey, value: password);
  }

  /// Connecte l'utilisateur en vérifiant les identifiants fournis.
  Future<UserProfile> login(
    String email,
    String password,
    bool keepLoggedIn,
  ) async {
    final String emailKey = email.trim().toLowerCase();

    String? userJson = await _prefs.getString('user_profile_$emailKey');
    String? storedPassword = await _secureStorage.read(
      key: 'user_password_$emailKey',
    );

    // Récupération rétroactive pour les anciens comptes pré-existants
    if (userJson == null) {
      final String? legacyJson = await _prefs.getString(_userKey);
      if (legacyJson != null) {
        final Map<String, dynamic> legacyMap = jsonDecode(legacyJson);
        final UserProfile legacyUser = UserProfile.fromJson(legacyMap);
        if (legacyUser.email.trim().toLowerCase() == emailKey) {
          userJson = legacyJson;
          storedPassword = await _secureStorage.read(key: _passwordKey);
          if (userJson != null) {
            await _prefs.setString('user_profile_$emailKey', userJson);
          }
          if (storedPassword != null) {
            await _secureStorage.write(
              key: 'user_password_$emailKey',
              value: storedPassword,
            );
          }
        }
      }
    }

    if (userJson == null || storedPassword == null) {
      throw Exception('Aucun compte trouvé avec l\'adresse email "$email".');
    }

    final Map<String, dynamic> userMap = jsonDecode(userJson);
    final UserProfile storedUser = UserProfile.fromJson(userMap);

    if (storedPassword != password) {
      throw Exception('Mot de passe incorrect.');
    }

    await _prefs.setBool(_keepLoggedInKey, keepLoggedIn);
    await _prefs.setString('active_user_email', emailKey);
    await _trackRegisteredEmail(emailKey);

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

  /// Met à jour le profil de l'utilisateur.
  Future<void> updateUser(UserProfile user) async {
    final String emailKey = user.email.trim().toLowerCase();
    final String userJson = jsonEncode(user.toJson());
    await _prefs.setString('user_profile_$emailKey', userJson);
    await _prefs.setString(_userKey, userJson);
    await _trackRegisteredEmail(emailKey);
  }

  /// Récupère le profil de l'utilisateur actuellement enregistré.
  Future<UserProfile?> getCurrentUser() async {
    final String? activeEmail = await _prefs.getString('active_user_email');
    if (activeEmail != null) {
      final String? userJson = await _prefs.getString(
        'user_profile_$activeEmail',
      );
      if (userJson != null) {
        return UserProfile.fromJson(jsonDecode(userJson));
      }
    }
    final String? legacyJson = await _prefs.getString(_userKey);
    if (legacyJson != null) {
      return UserProfile.fromJson(jsonDecode(legacyJson));
    }
    return null;
  }
}
