// [AI-GENERATED] Issue #1, Agent, 2025-02-23

/// Modèle représentant le profil de l'utilisateur.
/// 
/// L'objectif de cette classe est de stocker les informations du compte
/// et de fournir les méthodes de sérialisation nécessaires pour l'enregistrement
/// en local (par exemple, dans SharedPreferences).
class UserProfile {
  final String firstName;
  final String lastName;
  final String email;
  final String country;

  UserProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.country,
  });

  /// Crée une instance de [UserProfile] depuis un objet JSON.
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      country: json['country'] as String,
    );
  }

  /// Convertit l'instance courante de [UserProfile] en dictionnaire JSON.
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'country': country,
    };
  }
}
