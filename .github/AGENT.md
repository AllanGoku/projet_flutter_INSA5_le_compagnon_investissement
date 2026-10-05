# AGENT.md - Contrat du projet Le compagnon d'investissement

## Identité du projet
Application mobile éducative en Flutter (compagnon d'investissement fictif). Aucune transaction financière réelle n'est autorisée.
Le context du projet est également énoncé dans le fichier : `.github/CONTEXT.md`

## Conventions de code (Flutter/Dart)
Suivi les conventions dans le dossier suivant : `.github/RULES`:
- `ARCHITECTURE.md` : Architecture du projet.
- `TEST.md` : Conventions de test.
et le fichier `.github/copilot-instructions.md`
- ...

## Dépendances autorisées (Sécurité)
- **Liste blanche :** `flutter`, `provider` (ou `flutter_riverpod`), `http`, `fl_chart`, `shared_preferences` (ou `sqflite`).
- **Verrouillage :** N'ajoutez AUCUNE nouvelle dépendance dans `pubspec.yaml` sans demander l'autorisation explicite.

## Règles de Sécurité
- **Secrets :** Aucune clé API (comme celle d'Alpha Vantage) en dur dans le code. Utiliser `.env`.
- **Validation :** Valider systématiquement les champs des formulaires d'ajout au portefeuille fictif avant traitement.

## Audit et Traçabilité IA
- **Marqueur de génération :** Tout code généré doit inclure l'en-tête suivant :
  `// [AI-GENERATED] Issue #N, Agent, Date`.
- **Commentaires :** Documenter les fonctions clés (DartDoc) en explicitant le "pourquoi" algorithmique.