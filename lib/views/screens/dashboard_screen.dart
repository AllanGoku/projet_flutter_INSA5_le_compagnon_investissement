// [AI-GENERATED] Phase 3, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/portfolio_controller.dart';
import '../../controllers/data_controller.dart';
import '../../controllers/data_state.dart';
import '../../models/asset.dart';
import '../../utils/app_theme.dart';
import '../widgets/flip_gain_counter.dart';
import '../widgets/hero_asset_card.dart';
import '../widgets/asset_grid_section.dart';
import '../widgets/market_movers_section.dart';
import '../widgets/buy_asset_sheet.dart';
import 'asset_detail_screen.dart';
import 'search_screen.dart';

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

  // Liste d'actifs pour alimenter le tableau de bord
  static const _heroSymbol = 'AAPL';
  static const _watchListConfigs = [
    {'symbol': 'MSFT', 'name': 'Microsoft Corp.', 'type': 'Stock', 'desc': 'Logiciel & Cloud'},
    {'symbol': 'AMZN', 'name': 'Amazon.com Inc.', 'type': 'Stock', 'desc': 'E-commerce & Cloud AWS'},
    {'symbol': 'IBM', 'name': 'IBM Corp.', 'type': 'Stock', 'desc': 'Informatique & Services IT'},
  ];

  static const _marketMoversConfigs = <Map<String, String>>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 1. Restauration du portefeuille fictif depuis SQLite
      context.read<PortfolioController>().loadPositions();

      final dataController = context.read<DataController>();

      // 2. Chargement immédiat de l'ensemble des données déjà en cache dans SQLite
      await dataController.loadAllCachedAssets();

      // 3. Récupération des cours réels du jour auprès de l'API
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
          isHot: true,
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
          setState(() {});
        },
      ),
    );
  }

  void _openDetailScreen(Asset asset) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AssetDetailScreen(asset: asset),
      ),
    );
  }

  Widget _buildHomeView(DataController dataController, Map<String, Asset> loadedAssets) {
    // Récupération de l'actif vedette depuis le cache/API ou instance par défaut
    final Asset heroAsset = loadedAssets[_heroSymbol] ?? Asset(
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
      return loadedAssets[sym] ?? Asset(
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
      return loadedAssets[sym] ?? Asset(
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

    return Consumer<PortfolioController>(
      builder: (context, portfolio, child) {
        return RefreshIndicator(
          onRefresh: () async {
            final portfolioController = context.read<PortfolioController>();
            final dataCtrl = context.read<DataController>();

            await portfolioController.loadPositions();
            await dataCtrl.refreshAll(
              [_heroSymbol, ..._watchListConfigs.map((e) => e['symbol']!), ..._marketMoversConfigs.map((e) => e['symbol']!)],
              force: true,
            );
          },
          color: AppTheme.primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (dataController.state == DataState.error || dataController.state == DataState.offline)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 16),
                    decoration: BoxDecoration(
                      color: dataController.state == DataState.error ? Colors.red.shade50 : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: dataController.state == DataState.error ? Colors.red.shade200 : Colors.orange.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          dataController.state == DataState.error ? Icons.error_outline : Icons.wifi_off,
                          color: dataController.state == DataState.error ? Colors.red : Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            dataController.errorMessage.isNotEmpty 
                                ? dataController.errorMessage 
                                : 'Problème de connexion aux données.',
                            style: TextStyle(
                              color: dataController.state == DataState.error ? Colors.red.shade900 : Colors.orange.shade900,
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
                ),
                const SizedBox(height: 20),

                // 2. Section 1 : Hero Asset ("Actif à la loupe")
                GestureDetector(
                  onTap: () => _openDetailScreen(heroAsset),
                  child: HeroAssetCard(
                    asset: heroAsset,
                    onBuyPressed: () => _openBuyModal(heroAsset),
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Section 2 : À surveiller (Grille horizontale)
                AssetGridSection(
                  assets: watchListAssets,
                  onAssetSelected: (asset) => _openDetailScreen(asset),
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
          const SearchScreen(),
          const Center(child: Text('Écran Portefeuille (À venir)')),
          const Center(child: Text('Écran Profil (À venir)')),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
          indicatorColor: AppTheme.mint.withOpacity(0.2),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: AppTheme.primaryColor),
              label: 'Accueil',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.search_rounded, color: AppTheme.primaryColor),
              label: 'Explorer',
            ),
            NavigationDestination(
              icon: Icon(Icons.pie_chart_outline_rounded),
              selectedIcon: Icon(Icons.pie_chart_rounded, color: AppTheme.primaryColor),
              label: 'Portefeuille',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded, color: AppTheme.primaryColor),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
