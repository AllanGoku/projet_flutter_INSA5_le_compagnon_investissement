// [AI-GENERATED] Phase 9, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/portfolio_controller.dart';
import '../../controllers/data_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/data_state.dart';
import '../../controllers/gamification_controller.dart';
import '../../models/asset.dart';
import '../../utils/app_theme.dart';
import '../widgets/flip_gain_counter.dart';
import '../widgets/hero_asset_card.dart';
import '../widgets/asset_grid_section.dart';
import '../widgets/market_movers_section.dart';
import '../widgets/buy_asset_sheet.dart';
import '../widgets/contextual_tip_card.dart';
import '../widgets/achievement_unlock_dialog.dart';
import 'asset_detail_screen.dart';
import 'dca_simulator_screen.dart';
import 'search_screen.dart';
import 'portfolio_screen.dart';
import 'leaderboard_screen.dart';
import 'profile_screen.dart';

/// Écran principal du tableau de bord (Accueil restructuré).
///
/// Intègre la navigation entre l'Accueil, la Recherche/Exploration (`SearchScreen`)
/// et la consultation détaillée des actifs (`AssetDetailScreen`).
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentNavIndex = 0;

  // Liste d'actifs pour alimenter le tableau de bord (5 actifs au total : AAPL + MSFT, AMZN, NVDA, IBM)
  static const _heroSymbol = 'AAPL';
  static const _watchListConfigs = [
    {
      'symbol': 'MSFT',
      'name': 'Microsoft Corp.',
      'type': 'Stock',
      'desc': 'Logiciel & Cloud',
    },
    {
      'symbol': 'AMZN',
      'name': 'Amazon.com Inc.',
      'type': 'Stock',
      'desc': 'E-commerce & Cloud AWS',
    },
    {
      'symbol': 'NVDA',
      'name': 'NVIDIA Corp.',
      'type': 'Stock',
      'desc': 'Puces IA & Graphiques',
    },
    {
      'symbol': 'IBM',
      'name': 'IBM Corp.',
      'type': 'Stock',
      'desc': 'Informatique & Services IT',
    },
  ];

  static const _marketMoversConfigs = <Map<String, String>>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authController = context.read<AuthController>();
      final currentUserEmail =
          authController.currentUser?.email ?? 'guest@app.local';

      // 1. Restauration du portefeuille fictif et des succès du compte connecté
      await context.read<PortfolioController>().loadPositions(currentUserEmail);
      await context.read<GamificationController>().loadData(currentUserEmail);

      final dataController = context.read<DataController>();

      // 2. Chargement immédiat de l'ensemble des données déjà en cache dans SQLite
      await dataController.loadAllCachedAssets();

      // 3. Récupération des cours réels du jour avec file d'attente échelonnée
      dataController.loadAsset(
        _heroSymbol,
        isHot: true,
        name: 'Apple Inc.',
        type: 'Stock',
        description: 'Leader mondial des technologies grand public et des services informatiques.',
      );

      for (var item in _watchListConfigs) {
        dataController.loadAsset(
          item['symbol']!,
          isHot: false,
          name: item['name'],
          type: item['type'],
          description: item['desc'],
        );
      }

      for (var item in _marketMoversConfigs) {
        dataController.loadAsset(
          item['symbol']!,
          isHot: true,
          name: item['name'],
          type: item['type'],
          description: item['desc'],
        );
      }

      final portfolioController = context.read<PortfolioController>();
      final gamificationController = context.read<GamificationController>();

      // Synchronisation de l'XP entre l'AuthController et le GamificationController
      final userXp = authController.currentUser?.xp ?? 0;
      if (gamificationController.userXp < userXp) {
        await gamificationController.awardXp(
          userXp - gamificationController.userXp,
        );
      } else if (gamificationController.userXp > userXp) {
        await authController.syncXp(gamificationController.userXp);
      }

      // Vérification rétroactive automatique des succès pour les utilisateurs existants
      await gamificationController.checkAchievements(
        portfolioValue: portfolioController.totalValue,
        totalInvested: portfolioController.totalInvested,
        assetCount: portfolioController.positions.length,
        hasSimulatedDCA: false,
        readLexicon: false,
      );
    });
  }

  void _openBuyModal(Asset asset) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BuyAssetSheet(
        asset: asset,
        onPurchaseSuccess: () {
          setState(() {
            _currentNavIndex = 2; // Redirection vers l'onglet Portefeuille
          });
        },
      ),
    );
  }

  void _openDetailScreen(Asset asset) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AssetDetailScreen(asset: asset)),
    );
    if (result == 'open_portfolio') {
      setState(() {
        _currentNavIndex = 2; // Redirection vers l'onglet Portefeuille
      });
    }
  }

  Widget _buildHomeView(
    DataController dataController,
    Map<String, Asset> loadedAssets,
  ) {
    // Récupération de l'actif vedette depuis le cache/API ou instance par défaut
    final Asset heroAsset =
        loadedAssets[_heroSymbol] ??
        Asset(
          symbol: _heroSymbol,
          name: dataController.state == DataState.error
              ? 'Erreur API'
              : 'Apple Inc.',
          currentPrice: 0.0,
          type: 'Stock',
          description: dataController.state == DataState.error
              ? dataController.errorMessage
              : 'Chargement ou attente des données...',
          marketOpen: true,
          timezone: 'US/Eastern',
          timeSeries: {},
        );

    // Extraction des actifs réels de la liste à surveiller
    final List<Asset> watchListAssets = _watchListConfigs.map((item) {
      final sym = item['symbol']!;
      return loadedAssets[sym] ??
          Asset(
            symbol: sym,
            name: item['name']!,
            currentPrice: 0.0,
            type: item['type']!,
            description: item['desc']!,
            marketOpen: true,
            timezone: 'US/Eastern',
            timeSeries: {},
          );
    }).toList();

    // Extraction des actifs réels des Market Movers
    final List<Asset> marketMoversAssets = _marketMoversConfigs.map((item) {
      final sym = item['symbol']!;
      return loadedAssets[sym] ??
          Asset(
            symbol: sym,
            name: item['name']!,
            currentPrice: 0.0,
            type: item['type']!,
            description: item['desc']!,
            marketOpen: true,
            timezone: 'US/Eastern',
            timeSeries: {},
          );
    }).toList();

    return Consumer2<PortfolioController, AuthController>(
      builder: (context, portfolio, auth, child) {
        final user = auth.currentUser;
        return RefreshIndicator(
          onRefresh: () async {
            final portfolioController = context.read<PortfolioController>();
            final dataCtrl = context.read<DataController>();

            await portfolioController.loadPositions();
            await dataCtrl.refreshAll([
              _heroSymbol,
              ..._watchListConfigs.map((e) => e['symbol']!),
              ..._marketMoversConfigs.map((e) => e['symbol']!),
            ], force: true);
          },
          color: AppTheme.primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<GamificationController>(
                  builder: (context, gamification, child) {
                    if (gamification.newlyUnlockedQueue.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (gamification.newlyUnlockedQueue.isNotEmpty) {
                          final newlyUnlocked = List.from(
                            gamification.newlyUnlockedQueue,
                          );
                          gamification.clearNewlyUnlockedQueue();
                          for (var ach in newlyUnlocked) {
                            AchievementUnlockDialog.show(context, ach);
                          }
                        }
                      });
                    }
                    return const SizedBox.shrink();
                  },
                ),

                if ((dataController.state == DataState.error ||
                        dataController.state == DataState.offline) &&
                    loadedAssets.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      top: 16,
                    ),
                    decoration: BoxDecoration(
                      color: dataController.state == DataState.error
                          ? Colors.red.shade50
                          : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: dataController.state == DataState.error
                            ? Colors.red.shade200
                            : Colors.orange.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          dataController.state == DataState.error
                              ? Icons.error_outline
                              : Icons.wifi_off,
                          color: dataController.state == DataState.error
                              ? Colors.red
                              : Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            dataController.errorMessage.isNotEmpty
                                ? dataController.errorMessage
                                : 'Problème de connexion aux données.',
                            style: TextStyle(
                              color: dataController.state == DataState.error
                                  ? Colors.red.shade900
                                  : Colors.orange.shade900,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // 1. En-tête Synthèse du Portefeuille (FlipGainCounter)
                FlipGainCounter(
                  totalValue: portfolio.totalValue,
                  capitalGain: portfolio.totalCapitalGain,
                  performancePercentage: portfolio.totalPerformance,
                  cashBalance: portfolio.cashBalance,
                  user: user,
                  onProfileTap: () {
                    setState(() {
                      _currentNavIndex = 4;
                    });
                  },
                ),

                // Mise à jour discrète du record du portefeuille
                Builder(
                  builder: (context) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      context
                          .read<AuthController>()
                          .updateHighestPortfolioValue(
                            portfolio.totalValue + portfolio.cashBalance,
                          );
                    });
                    return const SizedBox.shrink();
                  },
                ),

                // Astuces contextuelles
                const ContextualTipCard(),

                const SizedBox(height: 16),

                // Carte d'accès rapide au Simulateur DCA
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.primaryColor.withValues(alpha: 0.85),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        key: const Key('dashboard_dca_simulator_button'),
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const DcaSimulatorScreen(),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.calculate_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Simulateur DCA & Intérêts Composés',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Simule l\'investissement mensuel et projette tes gains',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 2. Section 1 : Hero Asset ("Actif à la loupe")
                HeroAssetCard(
                  asset: heroAsset,
                  onTap: () => _openDetailScreen(heroAsset),
                  onBuyPressed: () => _openBuyModal(heroAsset),
                ),
                const SizedBox(height: 24),

                // 3. Section 2 : À surveiller (Grille horizontale)
                AssetGridSection(
                  assets: watchListAssets,
                  onAssetSelected: (asset) => _openDetailScreen(asset),
                  onBuyPressed: (asset) => _openBuyModal(asset),
                ),
                const SizedBox(height: 24),

                // 4. Section 3 : Market Movers (Top variations)
                MarketMoversSection(
                  assets: marketMoversAssets,
                  onAssetSelected: (asset) => _openDetailScreen(asset),
                ),
                const SizedBox(height: 100), // Espace pour la barre de nav
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataController = context.watch<DataController>();
    final Map<String, Asset> loadedAssets = dataController.assets;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: IndexedStack(
        index: _currentNavIndex,
        children: [
          _buildHomeView(dataController, loadedAssets),
          SearchScreen(
            onNavigateToPortfolio: () {
              setState(() {
                _currentNavIndex = 2;
              });
            },
          ),
          const PortfolioScreen(),
          const LeaderboardScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentNavIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentNavIndex = index;
            });
          },
          backgroundColor: Colors.white,
          elevation: 0,
          indicatorColor: AppTheme.mint.withValues(alpha: 0.2),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(
                Icons.home_rounded,
                color: AppTheme.primaryColor,
              ),
              label: 'Accueil',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(
                Icons.search_rounded,
                color: AppTheme.primaryColor,
              ),
              label: 'Explorer',
            ),
            NavigationDestination(
              icon: Icon(Icons.pie_chart_outline_rounded),
              selectedIcon: Icon(
                Icons.pie_chart_rounded,
                color: AppTheme.primaryColor,
              ),
              label: 'Portefeuille',
            ),
            NavigationDestination(
              icon: Icon(Icons.leaderboard_outlined),
              selectedIcon: Icon(
                Icons.leaderboard_rounded,
                color: AppTheme.primaryColor,
              ),
              label: 'Classement',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(
                Icons.person_rounded,
                color: AppTheme.primaryColor,
              ),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
