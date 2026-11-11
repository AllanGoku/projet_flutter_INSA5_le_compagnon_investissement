// [AI-GENERATED] Phase 3, Agent, 2025-02-23
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
/// Transmet [onNavigateToPortfolio] lors de la validation d'un achat pour basculer vers l'onglet Portefeuille.
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
      _searchQuery = _searchController.text.trim().toLowerCase();
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

  /// Algorithme de filtrage réactif selon la saisie textuelle et la catégorie sélectionnée.
  List<Asset> _getFilteredAssets(List<Asset> allAssets) {
    return allAssets.where((asset) {
      // 1. Filtrage par texte (symbole ou nom)
      final matchesSearch =
          _searchQuery.isEmpty ||
          asset.symbol.toLowerCase().contains(_searchQuery) ||
          asset.name.toLowerCase().contains(_searchQuery);

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
                  hintText: 'Rechercher par symbole ou nom (ex: AAPL, Apple)',
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

              // 3. Liste des résultats
              Expanded(
                child: filteredAssets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 60,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              allAssets.isEmpty
                                  ? 'Chargement des actifs en cours...'
                                  : 'Aucun actif ne correspond à votre recherche.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
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
