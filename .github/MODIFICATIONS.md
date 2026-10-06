# Modifications du Projet

Ce fichier documente les modifications apportées au projet "Le Compagnon d'Investissement" ainsi que les raisons de ces changements.

## [Initialisation de la base métier et UI] - 2025-02-23

### 1. Ajout des Modèles de Données (`../lib/models`)
- **`asset.dart`** : Création du modèle `Asset` pour représenter un actif financier (Action, ETF).
  - *Pourquoi ?* : Pour encapsuler la réponse brute de l'API (Alpha Vantage) et fournir un typage fort dans l'application, rendant la manipulation des actifs sécurisée.
- **`price_point.dart`** : Création du modèle `PricePoint` (OHLCV).
  - *Pourquoi ?* : Pour conserver l'historique détaillé des cours (Open, High, Low, Close, Volume) afin d'afficher des graphiques avancés et pour pouvoir fonctionner en mode hors-connexion.
- **`portfolio_position.dart`** : Création du modèle `PortfolioPosition`.
  - *Pourquoi ?* : Pour représenter une ligne dans le portefeuille fictif de l'utilisateur (associe un `Asset`, une quantité, et un prix d'achat moyen).

### 2. Ajout de la Logique Métier (`../lib/models/financial_calculator.dart`)
- **`financial_calculator.dart`** : Implémentation des fonctions pures de calcul financier (plus-value, valeur du portefeuille, performance, simulation DCA).
  - *Pourquoi ?* : Pour isoler strictement les calculs complexes de l'interface utilisateur (UI), facilitant ainsi l'écriture de tests unitaires fiables (conformément au TDD et au pattern MVC choisi).

### 3. Utilitaires de l'Interface Utilisateur (`../lib/utils`)
- **`app_theme.dart`** : Définition du thème visuel global basé sur Material 3.
  - *Pourquoi ?* : Pour garantir une interface cohérente, apaisante et éducative dans toute l'application (couleurs vertes et bleues prédominantes).
- **`formatters.dart`** : Ajout d'outils de formatage pour l'affichage (devises et pourcentages).
  - *Pourquoi ?* : Pour standardiser l'affichage financier (espacements pour les milliers, ajout de "€" ou "%") sans avoir à dupliquer ce code dans chaque widget.

### 4. Vue Initiale (`../lib/main.dart` & `../lib/views/screens/dashboard_screen.dart`)
- **`main.dart` & `dashboard_screen.dart`** : Mise en place du point d'entrée de l'application pointant vers un tableau de bord (Dashboard) initial.
  - *Pourquoi ?* : Fournir une base fonctionnelle pour l'application Flutter et prouver que l'intégration du thème `AppTheme` fonctionne.

### 5. Mise à jour de la documentation (`RULES`)
- **`ARCHITECTURE.md`** et **`TEST.md`** : Mises à jour.
  - *Pourquoi ?* : Pour que la documentation corresponde exactement à l'arborescence réelle actuelle des fichiers, garantissant que l'architecture décrite soit fidèle au code (notamment la mention explicite de `financial_calculator.dart`).
