// [AI-GENERATED] Issue #2, Agent, 2024-05-24
/// Enumération représentant les différents états de chargement des données
/// dans l'application, afin d'afficher la bonne interface utilisateur (chargement, 
/// succès, erreur, mode hors-connexion).
enum DataState {
  /// État initial avant le premier chargement
  initial,
  /// Chargement des données en cours depuis l'API ou le cache
  loading,
  /// Succès de la récupération des données (API ou Cache)
  success,
  /// Erreur lors de la récupération (ex: problème réseau sans cache, erreur API)
  error,
  /// Données récupérées depuis le cache car hors-connexion
  offline,
}
