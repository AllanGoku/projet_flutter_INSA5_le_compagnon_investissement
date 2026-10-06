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

## [Implémentation de l'authentification locale] - 2025-02-23

### 1. Ajout de la logique de validation (`../lib/utils/validators.dart`)
- **`validators.dart`** : Création d'une classe de validation pour les formulaires avec validation en temps réel (email, mots de passe).
  - *Pourquoi ?* : Assurer une saisie des données propre avant traitement, améliorer l'expérience utilisateur avec des retours instantanés (`AutovalidateMode.onUserInteraction`). Testé à 100%.

### 2. Modèle Utilisateur et Service d'Authentification (`../lib/models` & `../lib/services`)
- **`user_profile.dart`** : Modèle de profil utilisateur avec sérialisation JSON.
  - *Pourquoi ?* : Représenter les données de compte pour la persistance locale.
- **`auth_service.dart`** : Service gérant la persistance via `SharedPreferencesAsync` et `flutter_secure_storage`.
  - *Pourquoi ?* : Mimer un backend d'authentification pour cette application éducative en enregistrant les paramètres de session et le mot de passe de manière sécurisée et asynchrone (respect du projet). Testé à 100%.

### 3. Contrôleur et Vues d'authentification (`../lib/controllers` & `../lib/views`)
- **`auth_controller.dart`** : Contrôleur gérant l'état d'authentification (`ChangeNotifier`).
  - *Pourquoi ?* : Faire le lien de manière réactive entre les actions UI et le service `AuthService`.
- **`login_screen.dart` & `register_screen.dart`** : Écrans de connexion et d'inscription.
  - *Pourquoi ?* : Interface permettant à l'utilisateur de simuler son entrée dans l'app, avec option "Maintenir la connexion".

### 4. Injection et Routage (`../lib/main.dart`)
- **`main.dart`** : Ajout du `MultiProvider` et d'une logique de vérification au lancement.
  - *Pourquoi ?* : Assurer que l'application détecte si un compte est "maintenu connecté" pour router intelligemment soit vers le tableau de bord soit vers l'écran de connexion.

## [Mise à jour du Thème et Ajout des Composants UI (Design)] - 2026-10-06

### 1. Mise à jour du Thème Visuel (`../lib/utils/app_theme.dart`)
- **`app_theme.dart`** : Enrichissement du thème avec de nouvelles couleurs, typographies (Google Fonts `Space Grotesk`), et styles de texte.
  - *Pourquoi ?* : Pour moderniser l'interface et lui donner une identité visuelle forte et unique, orientée "investisseur" avec un design plus affirmé (utilisation de `google_fonts`).

### 2. Création de Widgets Réutilisables (`../lib/views/widgets/`)
- **`performance_text.dart`** : Création d'un widget pour afficher les pourcentages de performance.
  - *Pourquoi ?* : Standardiser l'affichage des performances avec un code couleur automatique (vert pour positif, rouge pour négatif) et une mise en forme cohérente.
- **`soft_card.dart`** : Création d'un composant de carte avec une esthétique "soft/neumorphique".
  - *Pourquoi ?* : Fournir un conteneur visuellement agréable et cohérent avec le nouveau thème pour afficher les informations de manière élégante.
- **`textured_button.dart`** : Création d'un bouton avec effet de texture.
  - *Pourquoi ?* : Ajouter un élément d'interaction distinctif et qualitatif, en phase avec la nouvelle direction artistique de l'application.

## [Implémentation du Cœur de Données (Réseau & Cache) et Test API] - 2026-10-06

### 1. Couche Réseau & Cache (`../lib/services/`)
- **`api_service.dart`** : Service HTTP se connectant à l'API Alpha Vantage.
  - *Pourquoi ?* : Permettre la récupération sécurisée des données de marché en temps réel et de l'historique de cours (OHLCV) en s'appuyant sur les clés API du fichier `.env`.
- **`cache_service.dart`** : Service de stockage local SQLite basé sur `sqflite`.
  - *Pourquoi ?* : Stocker de manière robuste les données et l'historique des actifs (sur au moins 7 jours) pour limiter les requêtes API et permettre le fonctionnement hors-connexion.

### 2. Gestion de l'État Asynchrone (`../lib/controllers/`)
- **`data_state.dart`** : Enumération des états asynchrones (`initial`, `loading`, `success`, `error`, `offline`).
  - *Pourquoi ?* : Standardiser et expliciter la représentation des états de chargement pour l'interface utilisateur.
- **`data_controller.dart`** : Contrôleur principal de données (`ChangeNotifier`).
  - *Pourquoi ?* : Piloter la récupération des données et implémenter une stratégie de rafraîchissement espacé (10 min pour les données chaudes, 1h pour le reste) afin de respecter les quotas d'API.

### 3. Ajustements de l'Application & Bac à Sable (`../lib/main.dart` & `../lib/views/screens/design_showcase_screen.dart`)
- **`main.dart` & `pubspec.yaml`** : Déclaration de `.env` dans les `assets` et chargement sécurisé via `dotenv`. Injection de `DataController` dans le `MultiProvider`.
  - *Pourquoi ?* : Éviter les erreurs de démarrage et distribuer l'état de données dans toute l'application.
- **`design_showcase_screen.dart`** : Ajout d'une section interactive de test d'API Alpha Vantage avec saisie de symbole boursier.
  - *Pourquoi ?* : Offrir un moyen simple et visuel de tester la connexion réseau et le comportement du cache directement depuis l'application.