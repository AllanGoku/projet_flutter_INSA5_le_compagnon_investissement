# Modifications du Projet

Ce fichier documente les modifications apportées au projet "Le Compagnon d'Investissement" ainsi que les raisons de ces changements.

## [Initialisation de la base métier et UI] - 2025-02-23

### 1. Ajout des Modèles de Données (`../lib/models`)
- **`asset.dart`** : Création du modèle `Asset` pour représenter un actif financier (Action, ETF).
  - *Pourquoi ?* : Pour encapsuler la réponse brute de l'API (initialement Alpha Vantage, désormais Twelve Data) et fournir un typage fort dans l'application, rendant la manipulation des actifs sécurisée.
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
- **`api_service.dart`** : Service HTTP se connectant initialement à l'API Alpha Vantage, migré depuis vers Twelve Data.
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
- **`design_showcase_screen.dart`** : Ajout d'une section interactive de test d'API Twelve Data avec saisie de symbole boursier.
  - *Pourquoi ?* : Offrir un moyen simple et visuel de tester la connexion réseau et le comportement du cache directement depuis l'application.

## [Migration vers Twelve Data] - 2025-02-23

### 1. Remplacement de l'API (`../lib/services/api_service.dart`)
- **`api_service.dart`** : Migration complète de l'API Alpha Vantage vers l'API Twelve Data.
  - *Pourquoi ?* : Limitations de l'API Alpha Vantage, adoption des endpoints `/time_series` et `/quote` de Twelve Data. Ajout d'une gestion précise des erreurs (ex: 429 Trop de requêtes).

### 2. Modèles de données et Parsing (`../lib/models/asset.dart` & `../lib/models/price_point.dart`)
- **`asset.dart` & `price_point.dart`** : Adaptation du parsing JSON pour correspondre à la structure de Twelve Data.
  - *Pourquoi ?* : Intégration des métadonnées Twelve Data. Ajout du stockage de la devise originale (`originalCurrency`) et du prix brut (`originalPrice`), et implémentation d'un convertisseur statique interne vers l'Euro (EUR) pour limiter la consommation de l'API.

### 3. Ajustement de l'UI et Optimisation des Requêtes (`../lib/views/screens/dashboard_screen.dart`)
- **`dashboard_screen.dart`** : Restriction de l'affichage du Dashboard à 4 actifs majeurs (AAPL, MSFT, AMZN, IBM).
  - *Pourquoi ?* : Respecter le quota très strict de l'API gratuite de Twelve Data (8 requêtes par minute). Affichage dynamique des bannières d'erreur réseau issues de Twelve Data. Ajout de la devise originale en gris sous les prix convertis.

### 4. Mise à jour du Cache Local (`../lib/services/cache_service.dart`)
- **`cache_service.dart`** : Migration de la structure SQLite avec `ALTER TABLE` pour ajouter `originalCurrency` et `originalPrice`.
  - *Pourquoi ?* : Persister les nouvelles données de devise sans effacer le portefeuille existant.

## [Phase 2 : Dashboard & Gestion de Portefeuille Fictif] - 2025-02-23

### 1. Persistance Locale du Portefeuille (`../lib/services/cache_service.dart`)
- **`cache_service.dart`** : Ajout de la table `portfolio` dans SQLite (`symbol`, `quantity`, `averagePurchasePrice`) et implémentation de `savePortfolioPositions` / `getPortfolioPositions`.
  - *Pourquoi ?* : Assurer la persistance locale et la restauration des positions d'achat du portefeuille fictif hors-connexion.

### 2. Contrôleur de Portefeuille Fictif (`../lib/controllers/portfolio_controller.dart`)
- **`portfolio_controller.dart`** : Création du contrôleur de portefeuille (`ChangeNotifier`) avec gestion du Prix Moyen Pondéré d'Achat (PMPA).
  - *Pourquoi ?* : Piloter l'état du portefeuille de manière réactive, réévaluer les métriques en temps réel (valeur totale, montant investi, plus-values et performance %) via `FinancialCalculator`.

### 3. Modèle d'Actif Enrichi (`../lib/models/asset.dart`)
- **`asset.dart`** : Ajout du getter `dailyChangePercentage` et du champ `changePercentage`.
  - *Pourquoi ?* : Calculer dynamiquement la variation quotidienne exacte en % basée sur les cours reçus de l'API.

### 4. Nouveaux Widgets d'Interface (`../lib/views/widgets/`)
- **`flip_gain_counter.dart`** : Synthèse dynamique du portefeuille avec bascule animée entre pourcentages (%) et montants en euros (€) via `AnimatedFlipCounter`.
- **`hero_asset_card.dart`** : Carte "Actif à la loupe" au style dégradé mettant en avant l'actif phare NVIDIA.
- **`asset_grid_section.dart`** : Grille horizontale "À surveiller" avec cartes compactes, badges ETF et pilules de plus/moins-value réelles.
- **`market_movers_section.dart`** : Liste verticale des "Market Movers" avec variations réelles de marché.
- **`purchase_animation.dart`** : Animation de paiement sans-contact sur terminal TPE avec feux d'artifice de confettis (`flutter_confetti`).
- **`buy_asset_sheet.dart`** : Modale d'achat fictif avec validation de quantité (`Validators`) et boutons raccourcis (+1, +5, +10).

### 5. Restructuration du Tableau de Bord & Injection (`../lib/views/screens/dashboard_screen.dart` & `../lib/main.dart`)
- **`dashboard_screen.dart`** : Assemblage des 3 sections et de l'en-tête, connexion à `DataController` pour charger en direct les vraies données API et intégration de la barre de navigation.
- **`main.dart`** : Déclaration de `PortfolioController` dans le `MultiProvider` racine.

### 6. Tests Unitaires & Widgets (`../test/`)
- **`portfolio_controller_test.dart`**, **`buy_asset_sheet_test.dart`**, **`dashboard_screen_test.dart`** : Couverture complète des règles de calcul du PMPA, de la validation des formulaires et du rendu visuel (100% de succès sur `flutter test`).

## [Phase 4 : Vue & Gestion dédiée du Portefeuille] - 2025-02-23

### 1. Modèle de Transaction & Persistance (`../lib/models/portfolio_transaction.dart` & `../lib/services/cache_service.dart`)
- **`portfolio_transaction.dart`** : Création du modèle `PortfolioTransaction` pour consigner le journal d'achats/reventes (symbole, type d'opération `buy`/`sell`, quantité, prix d'exécution, horodatage, plus-value réalisée).
- **`cache_service.dart`** : Ajout de la table SQLite `transactions` et des méthodes `saveTransaction`, `getTransactions` et `deletePortfolioPosition`.
  - *Pourquoi ?* : Assurer la traçabilité complète de toutes les opérations fictives et persister l'historique d'investisseur en local hors-connexion.

### 2. Calculs Financiers Métier (`../lib/models/financial_calculator.dart`)
- **`financial_calculator.dart`** : Ajout de `calculateRealizedGain` pour calculer la plus-value réalisée lors d'une vente `(prix_vente - PMPA) * quantité` et `calculateAllocationPercentage` pour la répartition en pourcentages du portefeuille.
  - *Pourquoi ?* : Isoler la logique financière dans des fonctions pures testables sans dépendance graphique.

### 3. Contrôleur de Portefeuille Enrichi (`../lib/controllers/portfolio_controller.dart`)
- **`portfolio_controller.dart`** : Implémentation de la revente d'unités entières `sellAsset(asset, quantity)`.
  - *Pourquoi ?* : Garantir les règles de gestion strictes (pas de fractions d'unité, contrôle de quantité possédée, conservation du PMPA lors d'une vente partielle, suppression de la ligne en cas de revente totale) et comptabiliser le cumul des plus-values réalisées (`totalRealizedGain`).

### 4. Nouveaux Composants UI (`../lib/views/widgets/`)
- **`portfolio_allocation_chart.dart`** : Graphique Donut (PieChart via `fl_chart`) visualisant la répartition des actifs avec légende dynamique colorée.
- **`portfolio_position_card.dart`** : Cartes synthétiques des positions détenues affichant le PMPA, le cours actuel, la valeur globale, la plus/moins-value latente (€ et %) et le bouton d'action "Vendre".
- **`sell_asset_sheet.dart`** : Modale de revente partielle/totale avec saisie par entiers, Slider interactif, raccourci "Tout vendre", prévisualisation du gain estimé et validation.
- **`transaction_history_section.dart`** : Journal chronologique des opérations avec badges d'Achat/Vente et détails des prix d'exécution.

### 5. Écran Dédié du Portefeuille & Intégration (`../lib/views/screens/portfolio_screen.dart` & `dashboard_screen.dart`)
- **`portfolio_screen.dart`** : Écran complet réunissant le bandeau de synthèse globale, le donut chart, la liste des positions et l'historique.
- **`dashboard_screen.dart`** : Intégration de `PortfolioScreen` dans l'onglet dédié de la barre de navigation inférieure.

### 6. Validation & Tests TDD (`../test/`)
- **`portfolio_transaction_test.dart`**, **`financial_calculator_test.dart`**, **`cache_service_test.dart`**, **`portfolio_controller_test.dart`**, **`portfolio_allocation_chart_test.dart`**, **`portfolio_position_card_test.dart`**, **`sell_asset_sheet_test.dart`**, **`transaction_history_section_test.dart`**, **`portfolio_screen_test.dart`** : Couverture complète TDD avec 100% de réussite sur la suite `flutter test` (92 tests réussis).

## [Système de Liquidités & Animation des Compteurs] - 2025-02-23

### 1. Portefeuille de Liquidités (`../lib/controllers/portfolio_controller.dart` & `cache_service.dart`)
- **`cache_service.dart`** : Ajout de la table SQLite `settings` pour conserver le solde de liquidités disponible de l'utilisateur (`saveCashBalance`, `getCashBalance`).
- **`portfolio_controller.dart`** : Initialisation du solde de départ à **1 000,00 €**.
  - Débit automatique lors des achats fictifs d'actifs avec contrôle de solde (`cost <= cashBalance`).
  - Crédit automatique lors des reventes d'actifs (`cashBalance += saleProceeds`).
  - Sécurisation du contrôle des unités entières via test de tolérance `(quantity - quantity.round()).abs() < 0.0001`.

### 2. Composants UI & Animation des Chiffres (`../lib/views/widgets/`)
- **`cash_balance_card.dart`** : Création d'un composant dédié affichant le solde de liquidités avec compteur animé **`AnimatedFlipCounter`** (chiffres roulant de manière très fluide vers le haut ou vers le bas lors des crédits/débits).
- **`flip_gain_counter.dart`** : Intégration de la pilule de liquidités avec compteur animé sur le bandeau du tableau de bord.
- **`buy_asset_sheet.dart`** & **`sell_asset_sheet.dart`** : Affichage du solde disponible et du montant crédité/débité, avec gestion sécurisée des exceptions via `try / catch` et SnackBar de retour utilisateur.

### 3. Écran Dédié du Portefeuille (`../lib/views/screens/portfolio_screen.dart`)
- **`portfolio_screen.dart`** : Intégration de `CashBalanceCard` et recalcul du Patrimoine Total = `Valeur des Actifs + Liquidités`.

## [Phase 5 : Profil Utilisateur, Niveaux d'XP & Conseils Contextuels] - 2025-02-23

### 1. Modèle Utilisateur Enrichi & Progression (`../lib/models/user_profile.dart`)
- **`user_profile.dart`** : Ajout des attributs d'expérience (`xp`), de niveau (`level`), de série de connexions (`streak`), de date de dernière connexion (`lastLoginDate`), de préference d'astuces (`showTips`), ainsi que des 3 records personnels (`highestLevelReached`, `highestXpReached`, `highestPortfolioValueReached`). Ajout de la méthode `copyWith`.
  - *Pourquoi ?* : Permettre le suivi complet du système de gamification et de la progression de l'investisseur fictif.

### 2. Calculs Métier de Gamification & XP (`../lib/models/financial_calculator.dart`)
- **`financial_calculator.dart`** : Ajout des fonctions pures `calculateBuyXp` (+50 XP forfaitaires par achat d'actif réussi), `calculateSaleXp` (calcul de l'XP indexé sur la performance relative et multiplié par la durée de détention), `calculateStreakBonus` (+20/j, 7j: +50 XP, 30j: +200 XP), `calculateLevel` (1 niveau tous les 1000 XP), et `getTitleForLevel` (titres honorifiques tels que *Novice*, *Initié*, *Maître de Wall Street*).
  - *Pourquoi ?* : Encourager l'action et valoriser le *Long-Term Investing* en récompensant la durée de conservation des actifs tout en isolant les règles de progression dans des fonctions testables sans dépendance graphique.

### 3. Gestion d'État & Persistance (`../lib/controllers/` & `../lib/services/`)
- **`auth_controller.dart`** : Prise en charge automatique du streak quotidien lors du `login` ou `checkKeepLoggedIn`, gain d'XP via `addXp`, mise à jour du record de solde de portefeuille, toggle des astuces, et réinitialisation du compte (`resetAccount`) en conservant la trace des 3 records personnels.
- **`portfolio_controller.dart` & `cache_service.dart`** : Adaptation de `sellAsset` pour retourner les métriques de durée et performance requises au calcul de l'XP. Ajout de `resetPortfolio` et de la méthode `clearPortfolioAndTransactions` dans SQLite.
- **`buy_asset_sheet.dart` & `purchase_animation.dart`** : Déclenchement de l'attribution de `+50 XP` lors de chaque achat d'actif réussi et affichage du message visuel de confirmation `Achat Fictif Confirmé ! (+50 XP)`.

### 4. Nouveaux Composants & Écran de Profil (`../lib/views/`)
- **`contextual_tip_card.dart`** : Carte dynamique d'astuces financières affichée sur la page d'accueil (`DashboardScreen`) avec option de fermer ou masquer définitivement via les préférences.
- **`profile_screen.dart`** : Nouvel écran de profil utilisateur comprenant :
  - Informations personnelles en **lecture seule** (Email, Pays).
  - Avatar avec initiales dynamiques et jauge de progression vers le niveau suivant avec titre honorifique.
  - Cartes des 3 records personnels (Niveau max, XP max, Valeur max de portefeuille).
  - Commutateur de préférences pour activer/désactiver les conseils.
  - Boutons de réinitialisation de compte et de déconnexion avec modales de confirmation.
- **`flip_gain_counter.dart`** : Harmonisation du badge d'avatar de profil sur le bandeau de la page d'accueil avec affichage des initiales réelles et navigation tactile directe vers l'onglet Profil.

### 5. Correction des Débordements & Optimisations UI (`../lib/views/`)
- **`interactive_flip_asset_card.dart`**, **`asset_historical_chart.dart`**, **`buy_asset_sheet.dart`**, **`sell_asset_sheet.dart`**, **`profile_screen.dart`** : Correction des débordements visuels de mise en page (layout overflow fixes), ajustements des contraintes de défilement, et wrapping `Material` autour du `SwitchListTile`.

### 6. Validation par les Tests Unitaires & Widgets (`../test/`)
- **`user_profile_test.dart`**, **`auth_controller_test.dart`**, **`contextual_tip_card_test.dart`**, **`profile_screen_test.dart`**, **`flip_gain_counter_test.dart`** : Rédaction et mise à jour des suites de tests unitaires et de widgets avec **100% de succès sur `flutter test` (111 tests validés)**.



