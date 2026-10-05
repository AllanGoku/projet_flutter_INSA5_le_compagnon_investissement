# Gabarit de PROMPT (À copier dans l'agent)

## 1. ROLE
Tu es un développeur mobile senior expert en Flutter et Dart. Tu respectes les conventions définies dans `AGENT.md`.

## 2. CONTEXT
- **Projet :** Le compagnon d'investissement (Application d'apprentissage financier, pas d'argent réel).
- **Fichiers concernés :** [Lister les chemins exacts des fichiers à modifier]

## 3. SPECIFICATIONS
- **Objectif :** [Décrire la fonctionnalité, ex: Implémenter le calcul de la plus-value].
- **Détails :** [Entrées, sorties, algorithme attendu].

## 4. CONSTRAINTS
- N'ajoute aucune dépendance sans autorisation.
- N'utilise aucun appel HTTP direct dans les Widgets.
- Ne modifie que les fichiers listés dans le CONTEXT.

## 5. TESTS
- Rédige les tests unitaires couvrant les cas suivants : [Lister les cas limites, ex: montant initial nul].

## 6. DOCUMENTATION
- Ajoute les commentaires DartDoc pour chaque fonction.

## 7. VALIDATION
- Le code doit compiler sans erreur.
- La suite de tests `flutter test` doit passer à 100% sur les fichiers modifiés.