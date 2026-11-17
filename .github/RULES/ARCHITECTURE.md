# ARCHITECTURE.md - Architecture du projet Le Compagnon d'Investissement

Ce document fournit la cartographie logicielle complète de l'application mobile Flutter "Le Compagnon d'Investissement".

## 1. Vue d'ensemble du système (Modèle MVC à 3 Tiers)

L'application adopte une architecture **Modèle-Vue-Contrôleur (MVC)** adaptée au développement mobile et découplée en trois couches strictes :

1. **Couche 1 : Présentation / Vue (`lib/views/`)**
   - Écrans et composants d'interface (Widgets, Screens).
   - Gestion exclusive de l'affichage, des formulaires et des animations programmées (`AnimationController`, `Tween`, `AnimatedFlipCounter`).
   - **Interdiction :** Aucun appel HTTP direct, aucun accès direct à la base locale, aucun calcul mathématique dans la méthode `build()`.

2. **Couche 2 : Contrôle et Services (`lib/controllers/` & `lib/services/`)**
   - **Contrôleurs :** Gestion de l'état applicatif (`ChangeNotifier`), écoute des événements utilisateurs et pilotage des flux (`AuthController`, `DataController`, `PortfolioController`, `GamificationController`).
   - **Services :** Client HTTP externe (`ApiService` pour Twelve Data), persistance sécurisée (`AuthService`) et gestionnaire de cache/persistance locale SQLite (`CacheService` pour `sqflite`).
   - Gestion explicite des états de chargement (`Initial`, `Loading`, `Success/Data`, `Error`, `Offline`).

3. **Couche 3 : Moteur Métier et Données (`lib/models/`)**
   - Modèles de données typés avec sérialisation JSON (`fromJson` / `toJson`).
   - Fonctions pures et calculs financiers et de gamification isolés dans `FinancialCalculator` (PMPA, plus-value latente/réalisée, allocation %, DCA, performance %, calculs d'XP, niveaux, streaks).

---

## 2. Structure de répertoires de référence

```text
le_compagnon_investissement/
|-- .github/
|   |-- AGENT.md                   # Contrat architectural et mémoire de l'agent
|   |-- CONTEXT.md                 # Contexte du projet et contexte d'utilisation
|   |-- MODIFICATIONS.md           # Journal des modifications du projet
|   |-- implementation_plan_project.md # Suivi d'avancement des phases du projet
|   |-- copilot-instructions.md     # Instructions pour l'agent
|   |-- RULES/
|   |   |-- ARCHITECTURE.md        # Présente cartographie du projet
|   |   `-- TEST.md                # Stratégie et exigences des tests unitaires
|-- pubspec.yaml                   # Dépendances verrouillées
|
|-- lib/
|   |-- models/                    # [M] Données & Fonctions pures de calcul
|   |   |-- achievement.dart       # Modèle de succès/badge avec critères et déblocage
|   |   |-- asset.dart             # Modèle d'actif (Action, ETF, variation %, capitalisation)
|   |   |-- financial_calculator.dart # Calculs financiers purs (Plus-value, PMPA, DCA, XP, Streaks)
|   |   |-- leaderboard_entry.dart # Modèle d'entrée du classement fictif
|   |   |-- lexicon_item.dart      # Modèle de terme et définition du lexique financier
|   |   |-- portfolio_position.dart# Ligne du portefeuille fictif (PMPA, quantité)
|   |   |-- portfolio_transaction.dart# Transaction d'achat ou de revente
|   |   |-- price_point.dart       # Point de donnée boursier (OHLCV)
|   |   `-- user_profile.dart      # Modèle de profil utilisateur (XP, niveau, solde, records)
|   |
|   |-- views/                     # [V] Interface utilisateur & Widgets
|   |   |-- screens/               # Écrans principaux
|   |   |   |-- achievements_screen.dart   # Suivi et déblocage des succès
|   |   |   |-- asset_detail_screen.dart   # Détails d'un actif (cours, graphique interactif)
|   |   |   |-- dashboard_screen.dart      # Accueil principal / Tableau de bord synthétique
|   |   |   |-- dca_simulator_screen.dart  # Simulateur d'investissement périodique (DCA)
|   |   |   |-- design_showcase_screen.dart# Showcase des composants UI
|   |   |   |-- leaderboard_screen.dart   # Classement ludique fictif
|   |   |   |-- lexicon_screen.dart       # Lexique financier pédagogique
|   |   |   |-- login_screen.dart         # Écran de connexion
|   |   |   |-- portfolio_screen.dart     # Suivi du portefeuille et positions
|   |   |   |-- profile_screen.dart       # Profil utilisateur et progression XP
|   |   |   |-- register_screen.dart      # Création de compte utilisateur
|   |   |   `-- search_screen.dart        # Recherche et exploration d'actifs
|   |   `-- widgets/               # Composants UI réutilisables
|   |       |-- achievement_badge_card.dart     # Carte de badge de succès
|   |       |-- achievement_unlock_dialog.dart # Pop-up de déblocage de succès
|   |       |-- asset_grid_section.dart        # Grille d'actifs par catégorie
|   |       |-- asset_historical_chart.dart    # Graphique d'historique boursier (fl_chart)
|   |       |-- buy_asset_sheet.dart           # Formulaire d'achat d'actif
|   |       |-- cash_balance_card.dart         # Carte synthétique des liquidités
|   |       |-- contextual_tip_card.dart       # Carte de conseils pédagogiques
|   |       |-- flip_gain_counter.dart         # Compteur animé de gains (€ / %)
|   |       |-- hero_asset_card.dart           # Carte d'actif mise en avant
|   |       |-- interactive_flip_asset_card.dart # Carte d'actif à retournement recto/verso
|   |       |-- market_movers_section.dart     # Top des hausses/baisses du marché
|   |       |-- market_term_help_button.dart   # Bouton d'aide avec bulle explicative
|   |       |-- performance_text.dart          # Affichage formaté de la performance
|   |       |-- portfolio_allocation_chart.dart# Graphique camembert d'allocation
|   |       |-- portfolio_position_card.dart   # Carte d'une position détenue
|   |       |-- purchase_animation.dart        # Animation d'achat/vente (glissement CB)
|   |       |-- sell_asset_sheet.dart          # Formulaire de revente d'actif
|   |       |-- soft_card.dart                 # Container doux/neumorphique réutilisable
|   |       |-- textured_button.dart           # Bouton stylisé avec effets visuels
|   |       |-- transaction_detail_sheet.dart  # Modal de détail d'une transaction
|   |       `-- transaction_history_section.dart# Historique chronologique des transactions
|   |
|   |-- controllers/               # [C] Contrôleurs et gestion d'état (ChangeNotifier)
|   |   |-- auth_controller.dart         # Authentification, session et profil utilisateur
|   |   |-- data_controller.dart         # Données financières (API Twelve Data & Cache SQLite)
|   |   |-- data_state.dart              # Enumération des états asynchrones
|   |   |-- gamification_controller.dart # Système de succès, XP, niveau, streak et classement
|   |   `-- portfolio_controller.dart    # Portefeuille fictif et liquidités (PMPA, solde, SQLite)
|   |
|   |-- services/                  # E/S, Réseau & Stockage local
|   |   |-- api_service.dart       # Service HTTP d'appel à l'API Twelve Data
|   |   |-- auth_service.dart      # Service de persistance sécurisée d'authentification
|   |   `-- cache_service.dart     # Service de cache et persistance SQLite (sqflite)
|   |
|   |-- utils/                     # Constantes, thèmes et formateurs
|   |   |-- app_theme.dart         # Thème global (Material 3, Google Fonts)
|   |   |-- formatters.dart        # Formatage des monnaies (€) et pourcentages (%)
|   |   `-- validators.dart        # Validation des formulaires (email, mot de passe, montants)
|   |
|   |-- images/                    # Images, illustrations et ressources graphiques
|   |
|   `-- main.dart                  # Point d'entrée Flutter & injection des providers
|
`-- test/                          # Suite de tests unitaires et d'intégration (miroir de lib)
    |-- controllers/               # Tests des contrôleurs (auth, data, gamification, portfolio)
    |-- models/                    # Tests des modèles et calculs (achievement, asset, financial_calculator, etc.)
    |-- screens/                   # Tests d'écrans (leaderboard_screen_test.dart)
    |-- services/                  # Tests des services (api_service, auth_service, cache_service)
    |-- utils/                     # Tests des utilitaires (validators_test.dart)
    |-- views/
    |   |-- screens/               # Tests d'écrans (asset_detail, dashboard, dca_simulator, lexicon, portfolio, profile, search)
    |   `-- widgets/               # Tests de widgets (chart, sheets, cards, buttons, etc.)
    |-- widgets/                   # Tests des widgets additionnels (achievement_badge_card_test.dart)
    `-- widget_test.dart           # Test de démarrage de l'application
```
