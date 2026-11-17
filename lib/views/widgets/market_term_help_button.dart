// [AI-GENERATED] Phase 3, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/app_theme.dart';
import '../../controllers/portfolio_controller.dart';
import '../../controllers/gamification_controller.dart';
import '../screens/lexicon_screen.dart';

/// Composant réutilisable affichant une bulle d'aide pédagogique ("?").
///
/// Permet aux utilisateurs débutants de comprendre instantanément les termes
/// financiers et boursiers (ex: Cap. Boursière, PER, Dividende, Risque, ETF, Volume, PMPA)
/// en ouvrant une fenêtre modale explicative au clic.
class MarketTermHelpButton extends StatelessWidget {
  /// Le terme boursier à expliquer.
  final String term;

  /// Explication sur mesure optionnelle si le terme n'est pas dans le dictionnaire standard.
  final String? customDefinition;

  /// Taille de l'icône d'aide.
  final double iconSize;

  /// Couleur de l'icône d'aide.
  final Color? iconColor;

  const MarketTermHelpButton({
    super.key,
    required this.term,
    this.customDefinition,
    this.iconSize = 18.0,
    this.iconColor,
  });

  /// Dictionnaire pédagogique centralisé des définitions boursières simplifiées.
  static const Map<String, String> defaultDefinitions = {
    'Cap. Boursière': 'La Capitalisation Boursière représente la valeur totale de toutes les actions en circulation d\'une entreprise sur le marché (ex: 2.81 T €). Elle s\'obtient en multipliant le prix de l\'action par le nombre total de titres.',
    'Capitalisation Boursière': 'La Capitalisation Boursière représente la valeur totale de toutes les actions en circulation d\'une entreprise sur le marché (ex: 2.81 T €). Elle s\'obtient en multipliant le prix de l\'action par le nombre total de titres.',
    'PER (P/E)': 'Le PER (Price Earnings Ratio ou Ratio Cours/Bénéfice) compare le prix de l\'action au bénéfice net par action. Un PER de 68.4 indique que les investisseurs sont prêts à payer 68,40 € pour chaque 1 € de bénéfice généré, anticipant une forte croissance.',
    'PER': 'Le PER (Price Earnings Ratio ou Ratio Cours/Bénéfice) compare le prix de l\'action au bénéfice net par action. Un PER élevé indique que les investisseurs anticipent une forte croissance future.',
    'Dividende': 'Le Dividende est la part du bénéfice de l\'entreprise distribuée aux actionnaires (ex: 0.02%). Il représente un rendement régulier en espèces, complémentaire à la hausse éventuelle du cours.',
    'Risque': 'Le Niveau de Risque évalue la volatilité de l\'actif sur une échelle de 1 (très stable) à 5 (très volatil/spéculatif). Un niveau élevé (ex: 4/5) signifie que le cours peut connaître d\'importantes variations à la hausse comme à la baisse.',
    'Niveau de Risque': 'Le Niveau de Risque évalue la volatilité de l\'actif sur une échelle de 1 (très stable) à 5 (très volatil/spéculatif). Un niveau élevé (ex: 4/5) signifie que le cours peut connaître d\'importantes variations à la hausse comme à la baisse.',
    'Bêta': 'Le Bêta mesure la sensibilité du cours de l\'action par rapport au marché global. Un Bêta supérieur à 1 (ex: 1.24) indique que l\'actif est plus volatil que la moyenne du marché.',
    'BPA': 'Le BPA (Bénéfice Par Action ou EPS) est le bénéfice net de l\'entreprise divisé par le nombre total d\'actions. Il mesure la rentabilité unitaire générée par chaque titre.',
    'BPA (EPS)': 'Le BPA (Bénéfice Par Action ou EPS) est le bénéfice net de l\'entreprise divisé par le nombre total d\'actions. Il mesure la rentabilité unitaire générée par chaque titre.',
    'Plus haut 52 sem.': 'Le cours le plus élevé atteint par l\'actif sur les 12 derniers mois (52 semaines). Permet de situer le prix actuel par rapport au sommet annuel.',
    'Plus bas 52 sem.': 'Le cours le plus bas atteint par l\'actif sur les 12 derniers mois (52 semaines). Permet de situer le prix actuel par rapport au niveau plancher annuel.',
    'Ouverture du marché': 'Indique si la bourse où cet actif est négocié est actuellement ouverte pour exécuter les ordres en direct. En dehors des heures d\'ouverture, les cours affichés sont ceux de la dernière clôture.',
    'ETF': 'Un ETF (Exchange Traded Fund ou Fonds Indiciel) est un panier d\'actifs qui suit un indice (ex: S&P 500 ou CAC 40). Il permet de diversifier ses investissements facilement et à moindres frais.',
    'Actions': 'Une action représente une petite part du capital d\'une entreprise. En acheter fait de vous un associé, avec un droit aux gains si la valeur de l\'entreprise augmente.',
    'Action': 'Une action représente une petite part du capital d\'une entreprise. En acheter fait de vous un associé, avec un droit aux gains si la valeur de l\'entreprise augmente.',
    'Volume': 'Le volume indique le nombre total de titres échangés (achetés et vendus) sur le marché durant la séance. Un volume élevé indique une forte activité.',
    'PMPA': 'Prix Moyen Pondéré d\'Achat. C\'est la moyenne des prix auxquels vous avez acheté vos différentes unités d\'un même actif dans votre portefeuille.',
    'Variation %': 'La variation en pourcentage indique l\'évolution du prix de l\'actif (hausse ou baisse) par rapport à son cours de clôture de la journée précédente.',
    'DCA': 'Le DCA (Dollar-Cost Averaging ou Investissement Programmé) consiste à investir un montant fixe à intervalles réguliers (ex: chaque mois). Cela permet de lisser le prix d\'achat moyen et d\'éliminer le stress lié au timing du marché.',
    'Taux de rendement': 'Le Taux de Rendement Annuel estimé (%) représente la progression moyenne de l\'actif sur un an. Pour un actif sélectionné, il est calculé automatiquement d\'après la formule du Taux de Croissance Annuel Composé (CAGR) basé sur l\'historique réels des prix. En mode sur-mesure, vous pouvez l\'ajuster librement.',
  };

  /// Affiche la modale explicative pédagogique.
  void _showHelpModal(BuildContext context) {
    // Déclenchement automatique du succès "Linguiste des marchés"
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

    final String definition =
        customDefinition ??
        defaultDefinitions[term] ??
        'Explication pédagogique indisponible pour le moment pour le terme "$term".';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.school_rounded,
                color: AppTheme.secondaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                term,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              definition,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    color: AppTheme.mint,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Conseil : Les marchés évoluent constamment. Investir à long terme permet d\'atténuer la volatilité.',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            key: const Key('help_modal_open_lexicon_button'),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => LexiconScreen(initialSearchQuery: term),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.secondaryColor,
            ),
            child: const Text('Voir le Lexique'),
          ),
          TextButton(
            key: const Key('help_modal_close_button'),
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            child: const Text('J\'ai compris'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: Key('market_term_help_button_$term'),
      onTap: () => _showHelpModal(context),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          width: iconSize + 4,
          height: iconSize + 4,
          decoration: BoxDecoration(
            color: (iconColor ?? AppTheme.secondaryColor).withValues(
              alpha: 0.1,
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.help_outline_rounded,
              size: iconSize * 0.85,
              color: iconColor ?? AppTheme.secondaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
