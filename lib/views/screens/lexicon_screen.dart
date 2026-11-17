// [AI-GENERATED] Phase 8, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/lexicon_item.dart';
import '../../utils/app_theme.dart';
import '../../controllers/portfolio_controller.dart';
import '../../controllers/gamification_controller.dart';
import 'dca_simulator_screen.dart';
import 'portfolio_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';

/// Écran principal du Lexique & Guide d'Aide Financière.
///
/// Permet la recherche globale, le filtrage par catégorie thématique,
/// la consultation pédagogique des termes boursiers et l'explication des formules.
class LexiconScreen extends StatefulWidget {
  /// Filtre initial optionnel par mot-clé (ex: "PMPA", "DCA").
  final String? initialSearchQuery;

  /// Catégorie initiale optionnelle.
  final LexiconCategory? initialCategory;

  const LexiconScreen({
    super.key,
    this.initialSearchQuery,
    this.initialCategory,
  });

  @override
  State<LexiconScreen> createState() => _LexiconScreenState();
}

class _LexiconScreenState extends State<LexiconScreen> {
  late TextEditingController _searchController;
  LexiconCategory? _selectedCategory;
  List<LexiconItem> _filteredItems = [];
  final Set<String> _expandedItemIds = {};

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialSearchQuery);
    _selectedCategory = widget.initialCategory;
    _filterItems();

    // Déclenchement automatique du succès "Linguiste des marchés"
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        final portfolio = context.read<PortfolioController>();
        final gamification = context.read<GamificationController>();
        gamification.checkAchievements(
          portfolioValue: portfolio.totalValue,
          totalInvested: portfolio.totalInvested,
          assetCount: portfolio.positions.length,
          hasSimulatedDCA: false,
          readLexicon: true,
        );
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Normalise les chaînes de caractères pour la recherche (accents, casse, ponctuation).
  String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[àâ]'), 'a')
        .replaceAll(RegExp(r'[îï]'), 'i')
        .replaceAll(RegExp(r'[ôö]'), 'o')
        .replaceAll(RegExp(r'[ûùü]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c')
        .replaceAll('.', '')
        .replaceAll('-', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Filtre la liste des termes selon la recherche textuelle et la catégorie sélectionnée.
  void _filterItems() {
    final rawQuery = _searchController.text.trim();
    final normalizedQuery = _normalize(rawQuery);

    setState(() {
      _filteredItems = LexiconRepository.defaultItems.where((item) {
        final matchesCategory =
            _selectedCategory == null || item.category == _selectedCategory;

        if (!matchesCategory) return false;
        if (normalizedQuery.isEmpty) return true;

        final normalizedTerm = _normalize(item.term);
        final normalizedShort = _normalize(item.shortDefinition);
        final normalizedDetailed = _normalize(item.detailedDefinition);

        final matchesTerm = normalizedTerm.contains(normalizedQuery) ||
            normalizedQuery.contains(normalizedTerm);
        final matchesShort = normalizedShort.contains(normalizedQuery);
        final matchesDetailed = normalizedDetailed.contains(normalizedQuery);

        final matchesAlias = item.aliases.any((alias) {
          final normalizedAlias = _normalize(alias);
          return normalizedAlias.contains(normalizedQuery) ||
              normalizedQuery.contains(normalizedAlias);
        });

        return matchesTerm || matchesShort || matchesDetailed || matchesAlias;
      }).toList();

      // Déplie automatiquement les termes correspondant directement à la recherche
      if (normalizedQuery.isNotEmpty) {
        for (var item in _filteredItems) {
          final normalizedTerm = _normalize(item.term);
          final matchesExactOrAlias = normalizedTerm == normalizedQuery ||
              item.aliases.any((a) => _normalize(a) == normalizedQuery) ||
              normalizedTerm.contains(normalizedQuery) ||
              item.aliases.any((a) => _normalize(a).contains(normalizedQuery));

          if (matchesExactOrAlias) {
            _expandedItemIds.add(item.id);
          }
        }
      }
    });
  }

  /// Gère la redirection contextuelle lors du clic sur un bouton d'action d'une fiche.
  void _handleActionRoute(String route) {
    switch (route) {
      case 'dca_simulator':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DcaSimulatorScreen()),
        );
        break;
      case 'portfolio':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PortfolioScreen()),
        );
        break;
      case 'profile':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
      case 'search':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SearchScreen()),
        );
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Lexique & Aide Financière',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                key: const Key('lexicon_search_input'),
                controller: _searchController,
                onChanged: (_) => _filterItems(),
                decoration: InputDecoration(
                  hintText: 'Rechercher un terme (ex: PER, PMPA, DCA)...',
                  hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppTheme.primaryColor,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          key: const Key('lexicon_search_clear_button'),
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            _filterItems();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),

          // Chips de filtres par catégories
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                // Chip "Tous"
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    key: const Key('lexicon_chip_all'),
                    label: const Text('Tous'),
                    selected: _selectedCategory == null,
                    selectedColor: AppTheme.primaryColor.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      color: _selectedCategory == null
                          ? AppTheme.primaryColor
                          : Colors.black87,
                      fontWeight: _selectedCategory == null
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = null;
                        });
                        _filterItems();
                      }
                    },
                  ),
                ),
                // Chips par catégorie
                ...LexiconCategory.values.map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      key: Key('lexicon_chip_${category.name}'),
                      avatar: Icon(
                        category.icon,
                        size: 16,
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.grey.shade600,
                      ),
                      label: Text(category.label),
                      selected: isSelected,
                      selectedColor: AppTheme.primaryColor.withValues(
                        alpha: 0.15,
                      ),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? category : null;
                        });
                        _filterItems();
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Compteur et Liste des termes
          Expanded(
            child: _filteredItems.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      final isExpanded = _expandedItemIds.contains(item.id);
                      return _buildLexiconCard(item, isExpanded);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Construit la vue d'état vide lorsque aucun résultat ne correspond.
  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 48,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucun terme trouvé',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty
                  ? 'Aucune définition ne correspond à "${_searchController.text}". Essayez un autre mot-clé.'
                  : 'Aucun terme disponible dans cette catégorie.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (_searchController.text.isNotEmpty || _selectedCategory != null)
              OutlinedButton.icon(
                key: const Key('lexicon_reset_filters_button'),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _selectedCategory = null;
                  });
                  _filterItems();
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Réinitialiser les filtres'),
              ),
          ],
        ),
      ),
    );
  }

  /// Construit une carte accordéon Soft UI pour un terme du lexique.
  Widget _buildLexiconCard(LexiconItem item, bool isExpanded) {
    return Container(
      key: Key('lexicon_card_${item.id}'),
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedItemIds.remove(item.id);
                } else {
                  _expandedItemIds.add(item.id);
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête : Icône + Titre + Badge Catégorie + Flèche
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item.category.icon,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.term,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.secondaryColor.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.category.label,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.secondaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Résumé court (toujours visible)
                  Text(
                    item.shortDefinition,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),

                  // Contenu étendu (si accordéon ouvert)
                  if (isExpanded) ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),

                    // Explication détaillée
                    Text(
                      item.detailedDefinition,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),

                    // Encadré d'Exemple
                    if (item.example != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.mint.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.lightbulb_outline_rounded,
                              color: AppTheme.mint,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Exemple concret :',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.example!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Encadré de Formule Mathématique
                    if (item.formula != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primaryColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.functions_rounded,
                              color: AppTheme.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                item.formula!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Bouton d'action contextuel
                    if (item.actionRoute != null && item.actionLabel != null) ...[
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          key: Key('lexicon_action_button_${item.id}'),
                          onPressed: () => _handleActionRoute(item.actionRoute!),
                          icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                          label: Text(item.actionLabel!),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
