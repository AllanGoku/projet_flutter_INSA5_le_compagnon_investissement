## 1. Philosophie et TDD (Test-Driven Development)
- **TDD Obligatoire :** Les tests doivent être rédigés *avant* l'implémentation du code métier (TDD). L'agent doit d'abord générer un test qui échoue, puis écrire le code pour le faire passer.
- **Indépendance :** Chaque test doit être indépendant (pas d'état partagé ou d'effets de bord avec un autre test).

## 2. Organisation et Emplacement
- Les fichiers de test doivent être placés dans le dossier `test/`, en reflétant exactement l'arborescence du dossier `lib/`.
- **Convention de nommage :** Le nom du fichier de test doit correspondre au fichier source avec le suffixe `_test.dart` (exemple : pour `lib/models/dca_calculator.dart`, le test sera `test/models/dca_calculator_test.dart`).

## 3. Logique Métier à Couvrir (Unit Tests)
Les tests unitaires doivent cibler en priorité absolue les fonctions pures et les calculs métier isolés de l'interface utilisateur.
Les calculs suivants doivent être couverts à 100% :
- **Performance de l'investissement (%) :** `((valeur finale - valeur initiale) / valeur initiale) * 100`.
- **Plus-value / Moins-value :** `valeur actuelle - montant investi`.
- **Valeur du portefeuille :** `Somme (quantité x cours actuel)`.
- **Simulation DCA :** Cumul des quantités achetées périodiquement valorisées au cours final.

## 4. Gestion des Cas Limites (Edge Cases)
Pour chaque calcul métier, l'agent doit explicitement créer des tests pour les cas limites suivants:
- Historique de données vide ou manquant.
- Montant d'investissement nul (0 €).
- Division par zéro (ex: calcul de performance si la valeur initiale est de 0).
- Valeurs manquantes ou dates incohérentes.

## 5. Tests d'Intégration et API
- **Règle de Non-Mocking des services internes :** Un test d'intégration entre le cache local (SQLite/SharedPreferences) et la couche de logique ne doit pas utiliser de mock pour le cache. Il doit utiliser une base de données en mémoire ou locale réelle.
- Les appels réseau externes (Alpha Vantage) doivent en revanche être moqués à l'aide de fausses données JSON (fixtures) pour garantir que les tests fonctionnent hors-connexion.

## 6. Précision Numérique
- En Flutter/Dart, pour tester l'égalité de montants financiers ou de pourcentages (flottants), ne jamais utiliser une égalité stricte (`expect(a, b)`).
- Utiliser la fonction `closeTo` pour tolérer les erreurs d'arrondi typiques des flottants (l'équivalent de `assertAlmostEqual` exigé par l'architecture).

## 7. Exécution et Validation
- **Commande :** `flutter test`
- Le code ne peut être considéré comme valide (et soumis en Commit/Pull Request) que si l'intégralité de la suite de tests s'exécute sans erreur et sans avertissement.

Attention ! : les commentaires de tests doivent être en français.