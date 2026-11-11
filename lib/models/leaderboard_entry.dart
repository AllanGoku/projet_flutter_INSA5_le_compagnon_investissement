// [AI-GENERATED] Issue #7, Agent, 2025-02-23
/// Les critères de tri du classement (Leaderboard).
enum LeaderboardSortCriteria { xp, portfolioValue, performance }

/// Modèle représentant une entrée dans le tableau de classement (Leaderboard).
/// Il permet de structurer les données d'un investisseur (fictif ou l'utilisateur actuel).
class LeaderboardEntry {
  /// Le rang dans le classement.
  final int rank;

  /// Le nom de l'investisseur.
  final String name;

  /// Les initiales pour l'avatar.
  final String avatarInitials;

  /// Le niveau calculé à partir de l'XP.
  final int level;

  /// Le nombre total de points d'expérience.
  final int xp;

  /// La valeur totale du portefeuille.
  final double portfolioValue;

  /// Le pourcentage de performance globale.
  final double performancePercentage;

  /// Vrai s'il s'agit de l'utilisateur actuel, faux pour les PNJ fictifs.
  final bool isCurrentUser;

  /// Crée une nouvelle instance de [LeaderboardEntry].
  LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.avatarInitials,
    required this.level,
    required this.xp,
    required this.portfolioValue,
    required this.performancePercentage,
    this.isCurrentUser = false,
  });
}
