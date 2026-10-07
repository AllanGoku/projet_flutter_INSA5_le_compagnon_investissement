# ARCHITECTURE.md - Architecture du projet Le Compagnon d'Investissement

Ce document fournit la cartographie logicielle de l'application mobile Flutter "Le Compagnon d'Investissement".

## 1. Vue d'ensemble du système (Modèle MVC à 3 Tiers)

L'application adopte une architecture **Modèle-Vue-Contrôleur (MVC)** adaptée au développement mobile et découplée en trois couches strictes :

1. **Couche 1 : Présentation / Vue (`lib/views/`)**
   - Composants d'interface (Widgets, Pages).
   - Gestion exclusive de l'affichage, des formulaires et des animations programmées (`AnimationController`, `Tween`).
   - **Interdiction :** Aucun appel HTTP direct, aucun accès direct à la base locale, aucun calcul mathématique dans la méthode `build()`.

2. **Couche 2 : Contrôle et Services (`lib/controllers/` & `lib/services/`)**
   - **Contrôleurs :** Gestion de l'état applicatif (`ChangeNotifier`), écoute des événements utilisateurs et pilotage des flux (`AuthController`, `DataController`, `PortfolioController`).
   - **Services :** Client HTTP externe (`ApiService` pour Alpha Vantage), persistance sécurisée (`AuthService`) et gestionnaire de cache/persistance locale SQLite (`CacheService` pour `sqflite`).
   - Gestion explicite des états de chargement (`Initial`, `Loading`, `Success/Data`, `Error`, `Offline`).

3. **Couche 3 : Moteur Métier et Données (`lib/models/`)**
   - Modèles de données typés avec sérialisation JSON (`fromJson` / `toJson`).
   - Fonctions pures et calculs financiers isolés dans `FinancialCalculator` (PMPA, DCA, performance %, valorisation du portefeuille fictif).

---

## 2. Structure de répertoires de référence

```text
le_compagnon_investissement/
|--.github/
|   |-- AGENT.md                   # Contrat architectural et mémoire de l'agent
|   |-- CONTEXT.md                 # Contexte du projet et contexte d'utilisation
|   |-- MODIFICATIONS.md           # Journal des modifications du projet
|   |-- implementation_plan_project.md # Suivi d'avancement des phases du projet
|   |-- copilot-instructions.md     # Instructions pour l'agent
|   |-- RULES
|   |   |-- ARCHITECTURE.md        # Présente cartographie du projet
|   |   `-- TEST.md                # Stratégie et exigences des tests unitaires
|-- pubspec.yaml                   # Dépendances verrouillées
|
|-- lib/
|   |-- models/                    # [M] Données & Fonctions pures de calcul
|   |   |-- asset.dart             # Modèle d'actif (Action, ETF, variation %)
|   |   |-- price_point.dart       # Point de donnée boursier (OHLCV)
|   |   |-- portfolio_position.dart# Ligne du portefeuille fictif (PMPA, quantité)
|   |   |-- user_profile.dart      # Modèle de profil utilisateur
|   |   `-- financial_calculator.dart # Calculs financiers purs (Plus-value, PMPA, DCA, etc.)
|   |
|   |-- views/                     # [V] Interface utilisateur & Widgets
|   |   |-- screens/               # Écrans principaux (dashboard_screen.dart, login_screen.dart, register_screen.dart, design_showcase_screen.dart)
|   |   `-- widgets/               # Composants réutilisables (flip_gain_counter.dart, hero_asset_card.dart, asset_grid_section.dart, market_movers_section.dart, buy_asset_sheet.dart, purchase_animation.dart, performance_text.dart, soft_card.dart, textured_button.dart)
|   |
|   |-- controllers/               # [C] Contrôleurs et gestion d'état
|   |   |-- auth_controller.dart   # Contrôleur d'authentification
|   |   |-- data_controller.dart   # Contrôleur de données financières (API & Cache)
|   |   |-- portfolio_controller.dart # Contrôleur du portefeuille fictif (PMPA & SQLite)
|   |   `-- data_state.dart        # Enumération des états asynchrones
|   |
|   |-- services/                  # E/S, Réseau & Stockage local
|   |   |-- api_service.dart       # Service d'appel à l'API Alpha Vantage
|   |   |-- auth_service.dart      # Service gérant la persistance d'authentification
|   |   `-- cache_service.dart     # Service de cache local SQLite (sqflite)
|   |
|   |-- utils/                     # Constantes, thèmes et formateurs monétaires
|   |   |-- app_theme.dart         # Thème global (Material 3, Google Fonts)
|   |   |-- formatters.dart        # Formatage des montants et pourcentages
|   |   `-- validators.dart        # Validation des données de formulaire
|   |
|   |-- images/                    # Images, logos, illustrations
|   |
|   `-- main.dart                  # Point d'entrée de l'application
|
`-- test/                          # Tests unitaires et d'intégration (miroir de lib)
    |-- models/                    # Ex: financial_calculator_test.dart, asset_test.dart
    |-- controllers/               # Ex: data_controller_test.dart, portfolio_controller_test.dart
    |-- services/                  # Ex: api_service_test.dart, cache_service_test.dart, auth_service_test.dart
    |-- utils/                     # Ex: validators_test.dart
    `-- views/                     # Ex: buy_asset_sheet_test.dart, dashboard_screen_test.dart
```
