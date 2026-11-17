<!-- [AI-GENERATED] README Update, Agent, 2025-02-23 -->

# 📈 Le Compagnon d'Investissement

[![Flutter](https://img.shields.io/badge/Flutter-3.13+-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.1+-0175C2?style=flat&logo=dart&logoColor=white)](https://dart.dev)
[![Architecture](https://img.shields.io/badge/Architecture-MVC%203--Tiers-blueviolet)](.github/RULES/ARCHITECTURE.md)

**Le Compagnon d'Investissement** est une application mobile éducative développée avec **Flutter**, conçue pour accompagner les utilisateurs débutants à intermédiaires dans la découverte et la compréhension de l'investissement boursier.

Adoptant une approche résolument pédagogique par l'interaction et la **simulation à 100 % fictive sans aucun risque financier**, elle permet d'explorer des actions et des ETF réels (via l'API Twelve Data), de gérer un portefeuille virtuel, d'expérimenter des scénarios d'investissement régulier (DCA) et de mesurer sa progression au sein d'un classement ludique.

---

## 🎯 Objectifs Pédagogiques

- **Apprendre sans risque** : Expérimenter l'achat et la revente d'actifs boursiers avec des liquidités virtuelles.
- **Comprendre la stratégie DCA** : Simuler l'impact d'investissements réguliers mensuels comparés au timing de marché.
- **Démystifier le vocabulaire financier** : Lexique complet et bulles d'aide interactives intégrées aux écrans.
- **Rendre l'apprentissage ludique** : Système d'expérience (XP), niveaux, séries d'activité (streaks), succès déblocables et classement fictif.

---

## ✨ Fonctionnalités Principales

### 📊 1. Tableau de Bord (Dashboard)
- **Synthèse globale** : Valeur totale du portefeuille, liquidités disponibles, plus-values/moins-values nettes.
- **Bascule d'affichage** : Conversion en un clic entre la performance en euros (**€**) et en pourcentage (**%**) via une animation de compteur dynamique (`animated_flip_counter`).
- **Tendances du marché** : Affichage des plus fortes hausses et baisses du jour (Top Gainers / Losers).
- **Conseils contextuels** : Recommandations pédagogiques adaptées au profil et à la progression de l'utilisateur.

### 💼 2. Portefeuille Fictif & Transactions
- **Gestion des positions** : Calcul automatique du **Prix Moyen Pondéré d'Achat (PMPA)**, quantité détenue, valeur actuelle et plus-values latentes/réalisées.
- **Répartition visuelle** : Graphique en camembert interactif (`fl_chart`) montrant l'allocation par actif.
- **Achat & Revente animés** : Formulaires validés avec animation fluide de carte bancaire virtuelle (`PurchaseAnimation`).
- **Historique complet** : Journal détaillé de toutes les opérations d'achat et de revente effectuées.

### 🔎 3. Exploration d'Actifs & Fiches Détail
- **Recherche dynamique** : Exploration des actions et ETF disponibles (ex: Apple, Microsoft, S&P 500, World ETF...).
- **Graphiques boursiers interactifs** : Graphique d'historique (courbe de cours, périodes 1D, 1W, 1M, 1Y, ALL) avec affichage du point sélectionné au survol/toucher.
- **Carte à retournement (Flip Card)** : Animation recto/verso dévoilant les données clés de l'actif (capitalisation, horodatage marché, timezone, type).

### 💡 4. Simulateur DCA (Dollar-Cost Averaging)
- **Simulation d'investissement régulier** : Calcule le capital final, l'apport total versé et les intérêts générés pour un versement mensuel donné sur une période sélectionnée.
- **Comparaison d'actifs** : Test du comportement d'un actif face au reste du portefeuille.

### 🎮 5. Gamification & Classement Fictif
- **Système de Niveaux & XP** : Gain de points d'expérience en effectuant des actions pédagogiques (achats, simulations DCA, lecture de définitions).
- **Succès & Badges** : Déblocage de succès avec pop-up et effets visuels de confettis (`flutter_confetti`).
- **Classement Virtuel (Leaderboard)** : Comparaison amusante avec des profils simulés pour encourager la régularité.

### 📚 6. Lexique Financier & Bulles d'Aide
- **Dictionnaire financier** : Explication claire et illustrée des notions clés (ETF, DCA, PMPA, Volatilité, Capitalisation, Dividend, etc.).
- **Aide contextuelle** : Boutons `?` cliquables à côté des termes complexes sur tous les écrans.

### 📶 7. Cache & Mode Hors-Ligne
- **Persistance locale SQLite (`sqflite`)** : Cache intelligent des cours boursiers et des positions du portefeuille.
- **Fonctionnement hors-ligne** : L'application reste pleinement fonctionnelle sans réseau en utilisant les dernières données en cache.

---

## 🛠️ Stack Technique & Architecture

### Architecture Logicielle
L'application respecte une **architecture MVC à 3 Tiers** stricte et découplée :
- **Vue (`lib/views/`)** : Composants UI réutilisables, écrans, animations (`AnimationController`, `Tween`, `AnimatedFlipCounter`).
- **Contrôleurs & Services (`lib/controllers/`, `lib/services/`)** : Gestion d'état réactive avec `Provider` (`ChangeNotifier`), appels réseau HTTP (Twelve Data API), persistance SQLite (`sqflite`) et stockage sécurisé (`flutter_secure_storage`, `shared_preferences`).
- **Modèle & Moteur Métier (`lib/models/`)** : Modèles typés avec sérialisation JSON et fonctions pures financières isolées dans `FinancialCalculator`.

### Dépendances Principales
| Package | Rôle |
| :--- | :--- |
| `provider` | Gestion d'état globale et injection de dépendances |
| `http` | Communication avec l'API externe (Twelve Data) |
| `sqflite` & `path` | Base de données locale pour le cache et les positions |
| `fl_chart` | Graphiques financiers et camembert d'allocation |
| `animated_flip_counter` | Animation fluide des chiffres de portefeuille |
| `flutter_confetti` | Effet visuel lors du déblocage de succès |
| `flutter_dotenv` | Chargement des variables d'environnement (`.env`) |
| `flutter_secure_storage` | Stockage sécurisé des clés et identifiants de session |
| `google_fonts` | Typographie moderne et uniforme |

---

## 🚀 Installation & Lancement

### Prérequis
- [Flutter SDK](https://docs.flutter.dev/get-started/install) v3.13.3 ou supérieur
- [Dart SDK](https://dart.dev/get-dart) v3.1.0 ou supérieur
- Android Studio / VS Code avec l'extension Flutter
- Une clé API gratuite [Twelve Data](https://twelvedata.com/)

### Étape 1 : Clonage du projet
```bash
git clone https://github.com/votre-compte/le_compagnon_investissement.git
cd le_compagnon_investissement
```

### Étape 2 : Installation des dépendances
```bash
flutter pub get
```

### Étape 3 : Configuration de l'environnement (`.env`)
Créez un fichier `.env` à la racine du projet :
```bash
TWELVEDATA_API_KEY=votre_cle_api_twelve_data
```

### Étape 4 : Lancement de l'application
```bash
flutter run
```

---

## 🧪 Tests & Qualité de Code

Le projet intègre une couverture de tests complète (tests unitaires des calculs financiers, tests des contrôleurs et tests de widgets UI).

Pour exécuter l'ensemble des tests :
```bash
flutter test
```

Pour effectuer l'analyse statique du code :
```bash
flutter analyze
```

---

## 📁 Structure du Projet

```text
le_compagnon_investissement/
├── .env                              # Variables d'environnement (non commitées)
├── pubspec.yaml                      # Dépendances et ressources du projet
├── lib/
│   ├── main.dart                     # Point d'entrée de l'application & initialisation des providers
│   ├── controllers/                  # Contrôleurs ChangeNotifier (Auth, Data, Portfolio, Gamification)
│   ├── models/                       # Modèles de données & FinancialCalculator (calculs purs)
│   ├── services/                     # Services d'E/S (ApiService Twelve Data, CacheService SQLite, AuthService)
│   ├── utils/                        # Thème AppTheme, Formatters (€ / %), Validateurs de formulaires
│   └── views/
│       ├── screens/                  # Écrans principaux (Dashboard, Portfolio, AssetDetail, DCA, Lexicon...)
│       └── widgets/                  # Composants UI réutilisables (Charts, Cards, Sheets, Animations...)
└── test/                             # Tests unitaires, de contrôleurs, de services et de widgets
```

---

## ⚠️ Avertissement Légal & Décharge

> **IMPORTANT :**
> **Le Compagnon d'Investissement** est un outil à visée **strictement éducative et pédagogique**.
> - Aucune transaction financière réelle n'est effectuée sur l'application.
> - L'argent, le portefeuille et le solde de liquidités affichés sont **100 % fictifs**.
> - Les données boursières et les calculs de simulation ne constituent en aucun cas des conseils en investissement ou des incitations financières.
