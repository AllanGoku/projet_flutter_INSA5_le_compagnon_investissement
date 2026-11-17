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

### 6. Implémentation du Simulateur DCA & Intérêts Composés (`Phase 6`)
- **`financial_calculator.dart`** : 
  - Implémentation de `simulateDcaCompound` pour calculer les intérêts composés.
  - Implémentation de `simulateDcaProjection` introduisant une projection probabiliste (scénarios Optimiste, Neutre, Pessimiste) basée sur la volatilité.
  - Implémentation de `calculateAssetAnnualizedReturn` pour calculer dynamiquement le rendement annualisé (CAGR) selon les données réelles de l'actif (historique, plus bas 52 semaines, etc.).
- **`dca_simulator_screen.dart`** :
  - Création de l'écran du simulateur avec champs de saisie (montant, durée).
  - Ajout d'une option de "Taux personnalisé" avec un curseur interactif.
  - Intégration d'un graphique de projection (Cône des scénarios) en utilisant `fl_chart`.
  - Intégration de la modale d'achat direct (`BuyAssetSheet`).
  - Correctifs appliqués contre les débordements de texte (overflow).
- **`dashboard_screen.dart`** & **`asset_detail_screen.dart`** : Ajout des boutons et cartes d'accès rapide au simulateur DCA.
- **`market_term_help_button.dart`** : Ajout des définitions pour les termes "DCA" et "Taux de rendement".

### 7. Verrouillage de l'Orientation et Corrections Transversales
- **`main.dart`** : 
  - Application du blocage d'orientation en mode portrait uniquement via `SystemChrome.setPreferredOrientations`.
  - Fiabilisation du chargement initial (garantie de fermeture du loader) et correction du problème de redirection à la déconnexion (`Navigator.pushAndRemoveUntil`).
- **`sell_asset_sheet.dart`** & **`buy_asset_sheet.dart`** : Ajout de `SingleChildScrollView` avec `BouncingScrollPhysics` pour éviter l'écrasement de la modale lors de l'ouverture du clavier virtuel.

### 8. Validation par les Tests Unitaires & Widgets (`../test/`)
- Mises à jour des suites de tests existantes et création de **`dca_simulator_screen_test.dart`**.
- L'ensemble du projet valide à **100% de succès sur `flutter test` (125 tests validés)**.

## [Phase 7 : Gamification - Succès & Classement Multi-Utilisateur] - 2025-02-23

### 1. Modèles de Données & Calculs Métier (`../lib/models/`)
- **`achievement.dart`** : Création du modèle `Achievement` (id, title, description, iconName, xpReward, isUnlocked, unlockedAt) avec méthodes `toMap`, `fromMap` et `copyWith`.
- **`leaderboard_entry.dart`** : Création du modèle `LeaderboardEntry` (rank, name, avatarInitials, level, xp, portfolioValue, performancePercentage, isCurrentUser) et énumération `LeaderboardSortCriteria` (`xp`, `portfolioValue`, `performance`).
- **`financial_calculator.dart`** :
  - Ajout de `generateMockLeaderboardEntries` pour construire un classement comparatif équitable mêlant l'utilisateur courant, les autres comptes utilisateurs enregistrés sur l'appareil et des investisseurs fictifs PNJ (Warren B., Charlie M., etc.), triés selon le critère choisi (`LeaderboardSortCriteria`).
  - Ajout de `checkAchievementUnlock` pour évaluer de façon pure et isolée les conditions de déblocage des 8 succès uniques (*Premier Pas*, *L'œil du Lynx*, *Linguiste des marchés*, *Pionnier du DCA*, *Investisseur Diversifié*, *Cap des 5k €*, *Maître du Profit*, *Patience d'Or*).

### 2. Service de Persistance Local & Isolation Multi-Utilisateur (`../lib/services/`)
- **`cache_service.dart`** :
  - Création de la table SQLite `achievements` pour conserver l'état et la date d'obtention des badges.
  - Migration de la base de données vers une **isolation multi-utilisateur complète rattachée à `userEmail`** pour le portefeuille, les liquidités, l'historique de transactions, l'XP et les succès.
  - Ajout de `migrateLegacyDataIfNeeded` pour migrer automatiquement les données d'un portefeuille existant pré-migration vers le premier compte connecté sans aucune perte d'actifs.

### 3. Contrôleurs d'État & Authentification (`../lib/controllers/` & `../lib/services/`)
- **`gamification_controller.dart`** : Création du contrôleur centralisant l'attribution d'XP, la vérification réactive des succès et la gestion de la file d'attente de célébration `newlyUnlockedQueue`.
- **`auth_service.dart` & `auth_controller.dart`** :
  - Garantie d'unicité stricte de l'e-mail lors de l'inscription (rejet de la création de doublons).
  - Ajout de `getAllUsers` dans `AuthService` pour récupérer l'ensemble des comptes créés sur l'appareil et les afficher dans le classement.
  - Ajout de `syncXp` dans `AuthController` pour maintenir une synchronisation parfaite en temps réel de l'XP entre le profil et le classement.

### 4. Composants Visuels & Écrans (`../lib/views/`)
- **`achievement_badge_card.dart`** : Carte de présentation des badges avec distinction visuelle claire et haut niveau de contraste/lisibilité pour les badges verrouillés (fond grisé, icône de cadenas et textes sombres).
- **`achievement_unlock_dialog.dart`** : Dialogue de célébration déclenchant une animation de confettis en surimpression via `flutter_confetti`.
- **`achievements_screen.dart`** : Écran récapitulatif des badges débloqués/verrouillés avec jauge de progression globale.
- **`leaderboard_screen.dart`** : Écran de classement proposant :
  - Un sélecteur de critères par onglets/segments (`XP`, `Portefeuille`, `Perf %`).
  - Un podium visuel pour le Top 3.
  - Une carte d'utilisateur personnellement épinglée en bas et protégée par `SafeArea` contre les chevauchements avec la barre de navigation système.
  - Le chargement asynchrone via `FutureBuilder` pour afficher tous les vrais comptes créés sur le téléphone.
- **`dashboard_screen.dart`** : Intégration du `Classement` dans la barre de navigation principale à 5 destinations (Accueil, Explorer, Portefeuille, Classement, Profil), écoute dynamique de la file d'attente pour déclencher les confettis et vérification automatique des succès au démarrage.
- **`buy_asset_sheet.dart` & `sell_asset_sheet.dart`** : Déclenchement automatique du gain d'XP et de la vérification instantanée des succès lors des opérations d'achat et de revente d'actifs.
- **`dca_simulator_screen.dart` & `market_term_help_button.dart` & `asset_detail_screen.dart`** : Déclenchement réactif des succès lors de la simulation DCA (*Pionnier du DCA*), la consultation du lexique (*Linguiste des marchés*) et la consultation d'actifs (*L'œil du Lynx*).

### 5. Validation par les Tests Unitaires & Widgets (`../test/`)
- Ajout de nouvelles suites de tests : `achievement_test.dart`, `leaderboard_entry_test.dart`, `financial_calculator_gamification_test.dart`, `gamification_controller_test.dart`, `achievement_badge_card_test.dart`, et `leaderboard_screen_test.dart`.
- Mise à jour des fakes/mocks pour supporter le multi-utilisateur et les signatures de méthodes.
- L'ensemble du projet valide à **100% de succès sur `flutter test` (142 tests validés)**.

## [Phase 8 : Aide, Lexique Financier & Calculs Métier] - 2025-02-23

### 1. Modèle de Données & Dictionnaire Centralisé (`../lib/models/lexicon_item.dart`)
- **`lexicon_item.dart`** :
  - Création du modèle `LexiconItem` avec les champs `id`, `term`, `category`, `shortDefinition`, `detailedDefinition`, `aliases`, `example`, `formula`, `actionRoute` et `actionLabel`.
  - Création de l'énumération `LexiconCategory` (`market`, `portfolio`, `strategy`, `formulas`).
  - Implémentation du dictionnaire répertoriant 21 termes et formules métier (`LexiconRepository.defaultItems`), enrichi d'un système d'alias et synonymes (ex: `"Cap. Boursière"` $\rightarrow$ **Capitalisation Boursière**, `"PER (P/E)"` $\rightarrow$ **PER**, `"BPA"` $\rightarrow$ **BPA (EPS)**).

### 2. Écran Dédié du Lexique (`../lib/views/screens/lexicon_screen.dart`)
- **`lexicon_screen.dart`** :
  - Barre de recherche interactive avec normalisation textuelle (tolérance aux accents, tirets, points et minuscules).
  - Puces de sélections (`ChoiceChip`) pour le filtrage rapide par thématique (*Tous*, *Marché*, *Portefeuille*, *DCA & Stratégies*, *Formules App*).
  - Cartes accordéons Soft UI dépliables avec définition courte, explication détaillée, exemple concret chiffré et formule mathématique.
  - Boutons d'action contextuels ouvrant directement l'outil concerné (ex: `DcaSimulatorScreen`, `PortfolioScreen`, etc.).
  - **Dépliement automatique intelligent** : Lorsqu'un utilisateur accède au lexique à partir d'une bulle d'aide, la fiche correspondante s'ouvre automatiquement dépliée pour un accès direct sans clic supplémentaire.
  - Déclenchement réactif de `GamificationController.checkAchievements(readLexicon: true)` à l'ouverture pour attribuer le succès *Linguiste des marchés* (+150 XP).

### 3. Intégrations & Correctifs UI (`../lib/views/`)
- **`market_term_help_button.dart`** : Ajout du bouton d'action *"Voir le Lexique"* dans la modale d'aide redirigeant dynamiquement vers `LexiconScreen(initialSearchQuery: term)`.
- **`profile_screen.dart`** : Ajout de l'entrée *"Lexique & Aide Financière"* dans le menu Profil.
- **`flip_gain_counter.dart` & `dashboard_screen.dart`** :
  - Encapsulation du titre de l'en-tête dans un `Expanded` avec ellipses (`TextOverflow.ellipsis`) pour corriger l'erreur de rendu `RenderFlex overflow`.
  - Correction de l'index de navigation du bouton de profil vers `_currentNavIndex = 4` (Profil).

### 4. Validation par les Tests Unitaires & Widgets (`../test/views/screens/lexicon_screen_test.dart`)
- Création de la suite de tests de widgets `lexicon_screen_test.dart` couvrant le filtrage par mot-clé, les alias de termes (ex: `"Cap. Boursière"`), les chips de catégorie, l'ouverture des cartes accordéons, l'état vide et la gamification.
- Validation à **100% de succès sur `flutter test` (148 tests validés)**.

## [Mise à jour et vérification de la cartographie de l'architecture] - 2025-02-23

### 1. Audit et révision de la documentation d'architecture (`.github/RULES/ARCHITECTURE.md`)
- **`ARCHITECTURE.md`** :
  - Vérification complète de la structure des répertoires `lib/` (54 fichiers source) et `test/` (40+ fichiers de test).
  - Ajout des éléments manquants dans la description de la Couche 2 (`GamificationController`) et de la Couche 3 (`Achievement`, `LeaderboardEntry`, `LexiconItem`).
  - Cartographie exhaustive de l'ensemble des 12 Écrans (`screens/`), 21 Widgets (`widgets/`), 5 Contrôleurs (`controllers/`), 9 Modèles (`models/`), 3 Services (`services/`), 3 Utilitaires (`utils/`) et de l'arborescence des tests unitaires et de widgets (`test/`).

## [Phase 9 : File d'Attente API, Échelonnement & Horodatage (Rate-Limiting & Freshness)] - 2025-02-23

### 1. File d'Attente Prioritaire Échelonnée (`../lib/controllers/data_controller.dart`)
- **`data_controller.dart`** : Implémentation du gestionnaire de file d'attente échelonnée (`_QueueItem` & `_processQueue`).
  - *Pourquoi ?* : Respecter le quota strict de Twelve Data (8 requêtes/minute max) en imposant un délai minimum de **15 secondes** entre rafraîchissements en arrière-plan et de **8 secondes** pour les demandes utilisateur explicites (`isHot = true`).
  - Exposition de `isSymbolRefreshing(symbol)`, `refreshingSymbols` et `queueLength` pour piloter la réactivité graphique.

### 2. Horodatage & Stratégie Cache-First (`../lib/models/asset.dart` & `../lib/services/cache_service.dart`)
- **`asset.dart`** : Ajout de la propriété `final DateTime? lastUpdated` avec sérialisation/désérialisation JSON et horodatage lors des réponses API.
- **`cache_service.dart`** : Persistance de `lastUpdated` dans la colonne SQLite dédiée.
- **`formatters.dart`** : Ajout de `Formatters.formatRelativeTime` (*"À l'instant"*, *"Il y a 5 min"*) et `Formatters.formatLastUpdated` (*"Mis à jour aujourd'hui à 14:32"*).

### 3. Composants UX de Fraîcheur & Chargement (`../lib/views/`)
- **`hero_asset_card.dart`**, **`interactive_flip_asset_card.dart`** & **`asset_detail_screen.dart`** : Affichage systématique de l'horodatage relatif/absolu et intégration d'un micro-indicateur de chargement rotatif lorsque l'actif est en cours de rafraîchissement.

### 4. Recherche Dynamique & Expansion du Catalogue (`../lib/views/screens/`)
- **`dashboard_screen.dart`** : Intégration de `TSLA` (Tesla), `GOOGL` (Alphabet/Google) et `NVDA` (Nvidia) dans le catalogue pré-chargé.
- **`search_screen.dart`** : Ajout de la résolution des alias courants ("Google" $\rightarrow$ `GOOGL`, "Tesla" $\rightarrow$ `TSLA`, "Nvidia" $\rightarrow$ `NVDA`) et création du bouton de chargement à la demande *"🔍 Rechercher '[SYMBOLE]' sur les marchés réels"* pour interroger l'API Twelve Data en direct et importer n'importe quel nouvel actif dans l'application.

### 5. Suite de Tests & Validation (`../test/`)
- Création de `formatters_test.dart` et mise à jour de `data_controller_test.dart` et `search_screen_test.dart`.
- Validation globale à **100% de succès sur `flutter test` (155 tests validés)**.






