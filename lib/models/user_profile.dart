// [AI-GENERATED] Issue #5, Agent, 2025-02-23

/// Modèle représentant le profil de l'utilisateur.
/// 
/// L'objectif de cette classe est de stocker les informations du compte,
/// de gérer la progression via un système d'expérience (XP) et de maintenir 
/// l'historique des records (gamification).
class UserProfile {
  final String firstName;
  final String lastName;
  final String email;
  final String country;
  
  // Phase 5: Gamification et progression
  final int xp;
  final int level;
  final int highestLevelReached;
  final int highestXpReached;
  final double highestPortfolioValueReached;
  final int streak;
  final DateTime? lastLoginDate;
  final bool showTips;

  UserProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.country,
    this.xp = 0,
    this.level = 1,
    this.highestLevelReached = 1,
    this.highestXpReached = 0,
    this.highestPortfolioValueReached = 0.0,
    this.streak = 0,
    this.lastLoginDate,
    this.showTips = true,
  });

  /// Crée une instance de [UserProfile] depuis un objet JSON.
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      country: json['country'] as String,
      xp: json['xp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      highestLevelReached: json['highestLevelReached'] as int? ?? 1,
      highestXpReached: json['highestXpReached'] as int? ?? 0,
      highestPortfolioValueReached: (json['highestPortfolioValueReached'] as num?)?.toDouble() ?? 0.0,
      streak: json['streak'] as int? ?? 0,
      lastLoginDate: json['lastLoginDate'] != null ? DateTime.tryParse(json['lastLoginDate'] as String) : null,
      showTips: json['showTips'] as bool? ?? true,
    );
  }

  /// Convertit l'instance courante de [UserProfile] en dictionnaire JSON.
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'country': country,
      'xp': xp,
      'level': level,
      'highestLevelReached': highestLevelReached,
      'highestXpReached': highestXpReached,
      'highestPortfolioValueReached': highestPortfolioValueReached,
      'streak': streak,
      'lastLoginDate': lastLoginDate?.toIso8601String(),
      'showTips': showTips,
    };
  }

  /// Retourne une nouvelle instance de [UserProfile] avec certaines propriétés modifiées.
  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? country,
    int? xp,
    int? level,
    int? highestLevelReached,
    int? highestXpReached,
    double? highestPortfolioValueReached,
    int? streak,
    DateTime? lastLoginDate,
    bool? showTips,
  }) {
    return UserProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      country: country ?? this.country,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      highestLevelReached: highestLevelReached ?? this.highestLevelReached,
      highestXpReached: highestXpReached ?? this.highestXpReached,
      highestPortfolioValueReached: highestPortfolioValueReached ?? this.highestPortfolioValueReached,
      streak: streak ?? this.streak,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      showTips: showTips ?? this.showTips,
    );
  }
}
