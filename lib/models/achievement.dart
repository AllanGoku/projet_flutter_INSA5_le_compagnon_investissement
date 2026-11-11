// [AI-GENERATED] Issue #7, Agent, 2025-02-23
/// Modèle représentant un succès déblocable (badge) dans l'application.
/// Il permet de récompenser les actions clés de l'utilisateur par des points d'XP (expérience).
class Achievement {
  /// L'identifiant unique du succès (ex: 'first_step').
  final String id;

  /// Le titre affiché du succès.
  final String title;

  /// La description expliquant comment obtenir ce succès.
  final String description;

  /// Le nom de l'icône associée (ex: 'visibility').
  final String iconName;

  /// Le nombre de points d'expérience gagnés au déblocage.
  final int xpReward;

  /// Indique si l'utilisateur a débloqué ce succès.
  final bool isUnlocked;

  /// La date et heure à laquelle le succès a été débloqué, si c'est le cas.
  final DateTime? unlockedAt;

  /// Crée une nouvelle instance de [Achievement].
  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.xpReward,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  /// Convertit l'instance en Map pour la persistance locale via sqflite.
  /// Le booléen `isUnlocked` est stocké sous forme d'entier (0 ou 1).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconName': iconName,
      'xpReward': xpReward,
      'isUnlocked': isUnlocked ? 1 : 0,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  /// Instancie un [Achievement] à partir des données extraites de sqflite.
  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      iconName: map['iconName'],
      xpReward: map['xpReward'],
      isUnlocked: map['isUnlocked'] == 1,
      unlockedAt: map['unlockedAt'] != null
          ? DateTime.parse(map['unlockedAt'])
          : null,
    );
  }

  /// Retourne une copie de cet [Achievement] avec les propriétés modifiées spécifiées.
  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? iconName,
    int? xpReward,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      xpReward: xpReward ?? this.xpReward,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}
