// [AI-GENERATED] Issue #1, Agent, 2025-02-23

/// Classe utilitaire pour valider les données de formulaires.
/// Les méthodes sont statiques pour faciliter leur utilisation dans les validateurs de champs (TextFormField).
class Validators {
  /// Vérifie qu'une adresse email a un format valide via une expression régulière.
  /// L'objectif est d'éviter les erreurs de saisie basiques et d'assurer une donnée propre.
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    final RegExp emailRegex = RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// Vérifie que le mot de passe est suffisamment long (ici, 6 caractères minimum).
  /// Cela garantit un niveau basique de sécurité pour les données locales.
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  /// Vérifie que deux mots de passe sont identiques (utile pour la confirmation de mot de passe).
  static bool passwordsMatch(String password, String confirmPassword) {
    return password == confirmPassword;
  }

  /// Vérifie qu'un champ texte n'est pas vide (les espaces seuls sont considérés comme vides).
  static bool isNotEmpty(String value) {
    return value.trim().isNotEmpty;
  }
}
