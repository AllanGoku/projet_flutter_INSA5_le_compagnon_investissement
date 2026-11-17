// [AI-GENERATED] Phase 9, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/data_controller.dart';
import '../../models/asset.dart';
import '../../utils/app_theme.dart';
import '../widgets/interactive_flip_asset_card.dart';
import '../widgets/buy_asset_sheet.dart';
import 'asset_detail_screen.dart';

/// Page d'exploration et de recherche textuelle dynamique d'actifs.
///
/// Permet de filtrer la liste des actifs réels disponibles (en cache SQLite et API)
/// par mot-clé (symbole ou nom) ainsi que par catégories ("Tous", "Actions", "ETF").
/// Offre la recherche dynamique à la demande sur l'API Twelve Data pour charger n'importe quel symbole (ex: TSLA, GOOGL).
class SearchScreen extends StatefulWidget {
  final VoidCallback? onNavigateToPortfolio;

  const SearchScreen({super.key, this.onNavigateToPortfolio});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Tous';
  bool _isSearchingApi = false;
  String? _apiSearchError;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dataCtrl = context.read<DataController>();
      if (dataCtrl.assets.isEmpty) {
        dataCtrl.loadAllCachedAssets();
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim();
      _apiSearchError = null;
    });
  }

  void _openDetailScreen(Asset asset) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AssetDetailScreen(asset: asset)),
    );
    if (result == 'open_portfolio') {
      if (widget.onNavigateToPortfolio != null) {
        widget.onNavigateToPortfolio!();
      }
    }
  }

  void _openBuyModal(Asset asset) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BuyAssetSheet(
        asset: asset,
        onPurchaseSuccess: () {
          if (widget.onNavigateToPortfolio != null) {
            widget.onNavigateToPortfolio!();
          }
        },
      ),
    );
  }

  /// Convertit les termes courants en symboles boursiers standards.
  String _resolveQueryToSymbol(String query) {
    final clean = query.trim().toLowerCase();
    if (clean == 'google' || clean == 'alphabet') return 'GOOGL';
    if (clean == 'tesla') return 'TSLA';
    if (clean == 'nvidia') return 'NVDA';
    if (clean == 'apple') return 'AAPL';
    if (clean == 'microsoft') return 'MSFT';
    if (clean == 'amazon') return 'AMZN';
    return query.trim().toUpperCase();
  }

  /// Déclenche le chargement en direct depuis l'API Twelve Data pour le symbole demandé.
  Future<void> _fetchAssetFromApi(String query) async {
    final symbol = _resolveQueryToSymbol(query);
    if (symbol.isEmpty) return;

    setState(() {
      _isSearchingApi = true;
      _apiSearchError = null;
    });

    try {
      final dataCtrl = context.read<DataController>();
      await dataCtrl.loadAsset(symbol, isHot: true);
      setState(() {
        _isSearchingApi = false;
      });
    } catch (e) {
      setState(() {
        _isSearchingApi = false;
        _apiSearchError =
            "Impossible de charger l'actif $symbol : ${e.toString().replaceAll('Exception: ', '')}";
      });
    }
  }

  /// Algorithme de filtrage réactif selon la saisie textuelle et la catégorie sélectionnée.
  List<Asset> _getFilteredAssets(List<Asset> allAssets) {
    final q = _searchQuery.toLowerCase();
    return allAssets.where((asset) {
      // 1. Filtrage par texte (symbole ou nom ou correspondances d'alias)
      final matchesSearch = q.isEmpty ||
          asset.symbol.toLowerCase().contains(q) ||
          asset.name.toLowerCase().contains(q) ||
          (q == 'google' && asset.symbol == 'GOOGL') ||
          (q == 'tesla' && asset.symbol == 'TSLA') ||
          (q == 'nvidia' && asset.symbol == 'NVDA');

      // 2. Filtrage par catégorie ("Tous", "Actions", "ETF")
      bool matchesCategory = true;
      if (_selectedCategory == 'Actions') {
        final t = asset.type.toLowerCase();
        matchesCategory =
            t.contains('stock') || t.contains('action') || t.contains('equity');
      } else if (_selectedCategory == 'ETF') {
        final t = asset.type.toLowerCase();
        matchesCategory = t.contains('etf') || t.contains('fonds');
      }

      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dataController = context.watch<DataController>();
    final List<Asset> allAssets = dataController.assets.values.toList();
    final List<Asset> filteredAssets = _getFilteredAssets(allAssets);
    final String targetSymbol = _resolveQueryToSymbol(_searchQuery);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Explorer les Marchés',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // 1. Barre de recherche textuelle
              TextField(
                key: const Key('search_text_field'),
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher (ex: TSLA, GOOGL, Tesla, Google)',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppTheme.secondaryColor,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          key: const Key('clear_search_button'),
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2. Filtres par catégories (Chips)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Tous', 'Actions', 'ETF'].map((category) {
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        key: Key('category_chip_$category'),
                        label: Text(category),
                        selected: isSelected,
                        selectedColor: AppTheme.mint.withValues(alpha: 0.2),
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? AppTheme.mint
                              : Colors.grey.shade200,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // 3. Liste des résultats ou bouton de recherche en direct API
              Expanded(
                child: filteredAssets.isEmpty
                    ? Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_isSearchingApi) ...[
                                const CircularProgressIndicator(
                                  color: AppTheme.primaryColor,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Recherche de $targetSymbol sur les marchés en cours...',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ] else ...[
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 50,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'Saisissez un symbole ou le nom d\'une entreprise.'
                                      : 'Aucun actif ne correspond à votre recherche.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                if (_apiSearchError != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    _apiSearchError!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ],
                                if (_searchQuery.isNotEmpty) ...[
                                  const SizedBox(height: 20),
                                  ElevatedButton.icon(
                                    key: const Key('fetch_api_search_button'),
                                    onPressed: () =>
                                        _fetchAssetFromApi(_searchQuery),
                                    icon: const Icon(
                                      Icons.cloud_download_outlined,
                                    ),
                                    label: Text(
                                      'Rechercher "$targetSymbol" sur les marchés réels',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredAssets.length,
                        itemBuilder: (context, index) {
                          final asset = filteredAssets[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: InteractiveFlipAssetCard(
                              asset: asset,
                              onDetailPressed: () => _openDetailScreen(asset),
                              onBuyPressed: () => _openBuyModal(asset),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
