// [AI-GENERATED] Phase 8, Agent, 2025-02-23
import 'package:flutter/material.dart';

/// Catégories thématiques des termes du lexique.
enum LexiconCategory {
  /// Termes généraux de marché et bourse (Actions, ETF, PER, etc.)
  market('Marché', Icons.candlestick_chart_rounded),

  /// Termes de gestion de portefeuille (PMPA, plus-value, cash, etc.)
  portfolio('Portefeuille', Icons.account_balance_wallet_rounded),

  /// Stratégies et culture financière (DCA, intérêts composés, CAGR, etc.)
  strategy('DCA & Stratégies', Icons.timeline_rounded),

  /// Formules et algorithmes de calcul utilisés dans l'application
  formulas('Formules App', Icons.functions_rounded);

  final String label;
  final IconData icon;

  const LexiconCategory(this.label, this.icon);
}

/// Modèle de données représentant une entrée du lexique pédagogique.
class LexiconItem {
  /// Identifiant unique du terme.
  final String id;

  /// Nom/Titre du terme financier (ex: "PMPA", "PER", "DCA").
  final String term;

  /// Catégorie thématique à laquelle appartient le terme.
  final LexiconCategory category;

  /// Résumé concis de la définition (1-2 phrases).
  final String shortDefinition;

  /// Explication pédagogique détaillée.
  final String detailedDefinition;

  /// Synonymes et appellations alternatives (ex: ["Cap. Boursière", "Market Cap"]).
  final List<String> aliases;

  /// Exemple concret chiffré optionnel.
  final String? example;

  /// Formule mathématique ou algorithmique optionnelle.
  final String? formula;

  /// Identifiant d'action pour redirection contextuelle optionnel ('dca_simulator', 'portfolio', 'profile', 'search').
  final String? actionRoute;

  /// Libellé du bouton d'action optionnel (ex: "Tester sur le Simulateur DCA").
  final String? actionLabel;

  const LexiconItem({
    required this.id,
    required this.term,
    required this.category,
    required this.shortDefinition,
    required this.detailedDefinition,
    this.aliases = const [],
    this.example,
    this.formula,
    this.actionRoute,
    this.actionLabel,
  });
}

/// Banque de données centralisée répertoriant tous les termes pédagogiques du lexique.
class LexiconRepository {
  /// Liste complète des termes et explications du lexique.
  static const List<LexiconItem> defaultItems = [
    LexiconItem(
      id: 'market_cap',
      term: 'Capitalisation Boursière',
      category: LexiconCategory.market,
      shortDefinition:
          'Valeur totale sur le marché de toutes les actions en circulation d\'une entreprise.',
      detailedDefinition:
          'La Capitalisation Boursière représente la valeur marchande globale d\'une société cotée. Elle s\'obtient en multipliant le cours actuel de l\'action par le nombre total d\'actions en circulation.',
      aliases: [
        'Cap. Boursière',
        'Cap. Boursiere',
        'Cap Boursière',
        'Capitalisation Boursiere',
        'Market Cap',
      ],
      example:
          'Une entreprise possédant 10 millions d\'actions cotées à 50 € a une capitalisation boursière de 500 millions d\'€.',
      formula: 'Cap. Boursière = Cours de l\'action × Total des actions',
    ),
    LexiconItem(
      id: 'per',
      term: 'PER (Price Earnings Ratio)',
      category: LexiconCategory.market,
      shortDefinition:
          'Ratio comparant le prix de l\'action à son bénéfice net annuel par action.',
      detailedDefinition:
          'Le PER (Ratio Cours/Bénéfice) mesure combien les investisseurs sont prêts à payer pour chaque euro de bénéfice généré par l\'entreprise. Un PER élevé suggère que le marché anticipe une forte croissance future.',
      aliases: [
        'PER',
        'PER (P/E)',
        'Price Earnings Ratio',
        'P/E',
        'Ratio Cours/Bénéfice',
      ],
      example:
          'Si une action cotée à 100 € génère 5 € de bénéfice par action, son PER est de 20 (100 / 5).',
      formula: 'PER = Prix de l\'action / Bénéfice Par Action (BPA)',
    ),
    LexiconItem(
      id: 'dividend',
      term: 'Dividende',
      category: LexiconCategory.market,
      shortDefinition:
          'Partie du bénéfice net d\'une entreprise distribuée aux actionnaires.',
      detailedDefinition:
          'Le dividende est un versement en espèces effectué par la société à ses actionnaires pour les récompenser de leur investissement. Il constitue un rendement complémentaire à l\'évolution du cours.',
      aliases: ['Dividende', 'Dividendes'],
      example:
          'Si vous détenez 10 actions et que le dividende annuel est de 2,50 € par action, vous recevez 25,00 €.',
    ),
    LexiconItem(
      id: 'risk_level',
      term: 'Niveau de Risque & Volatilité',
      category: LexiconCategory.market,
      shortDefinition:
          'Échelle de 1 à 5 évaluant la fréquence et l\'amplitude des variations de prix.',
      detailedDefinition:
          'Le niveau de risque traduit la volatilité de l\'actif. Un niveau faible (1-2) indique un actif stable avec peu de fluctuations, tandis qu\'un niveau élevé (4-5) signale des variations de cours rapides et importantes.',
      aliases: ['Risque', 'Niveau de Risque', 'Volatilité', 'Volatilite'],
    ),
    LexiconItem(
      id: 'beta',
      term: 'Bêta',
      category: LexiconCategory.market,
      shortDefinition:
          'Indicateur de sensibilité d\'un actif face aux fluctuations du marché global.',
      detailedDefinition:
          'Le Bêta compare les mouvements du prix d\'une action par rapport à son indice de référence. Un Bêta supérieur à 1 signifie que l\'actif est plus réactif et volatil que la moyenne du marché.',
      aliases: ['Bêta', 'Beta'],
      example:
          'Un Bêta de 1.20 implique que si le marché monte de 10 %, l\'actif grimpe généralement de 12 % (et inversement).',
    ),
    LexiconItem(
      id: 'bpa',
      term: 'BPA (EPS - Bénéfice Par Action)',
      category: LexiconCategory.market,
      shortDefinition:
          'Profit net d\'une entreprise divisé par le nombre d\'actions en circulation.',
      detailedDefinition:
          'Le BPA mesure la rentabilité directe générée par chaque action individuelle. C\'est l\'un des indicateurs fondamentaux les plus observés par les analystes financiers.',
      aliases: ['BPA', 'BPA (EPS)', 'EPS', 'Bénéfice Par Action'],
      formula: 'BPA = Bénéfice Net Total / Nombre d\'Actions',
    ),
    LexiconItem(
      id: 'high_low_52_weeks',
      term: 'Plus Haut / Bas 52 Semaines',
      category: LexiconCategory.market,
      shortDefinition:
          'Cours extrême (sommet et plancher) atteint par l\'actif sur les 12 derniers mois.',
      detailedDefinition:
          'Permet de situer le prix actuel d\'un actif par rapport à ses niveaux les plus élevés et les plus bas enregistrés au cours de l\'année écoulée (52 semaines).',
      aliases: [
        'Plus haut 52 sem.',
        'Plus bas 52 sem.',
        '52 sem.',
        '52 semaines',
        'Plus haut 52 sem',
        'Plus bas 52 sem',
      ],
    ),
    LexiconItem(
      id: 'market_open',
      term: 'Ouverture du Marché',
      category: LexiconCategory.market,
      shortDefinition:
          'Statut d\'ouverture en direct de la bourse où l\'actif est négocié.',
      detailedDefinition:
          'Indique si la place boursière sur laquelle l\'actif est coté est actuellement ouverte pour exécuter des ordres. En dehors des heures d\'ouverture, les prix affichés sont ceux de la dernière clôture.',
      aliases: [
        'Ouverture du marché',
        'Ouverture du marche',
        'Marché ouvert',
        'Marché fermier',
      ],
    ),
    LexiconItem(
      id: 'etf',
      term: 'ETF (Fonds Indiciel)',
      category: LexiconCategory.market,
      shortDefinition:
          'Panier d\'actifs répliquant la performance d\'un indice (ex: S&P 500, CAC 40).',
      detailedDefinition:
          'Un ETF (Exchange Traded Fund) permet d\'investir simultanément dans des centaines d\'entreprises via l\'achat d\'un seul titre. Il réduit le risque d\'actions individuelles grâce à la diversification automatique.',
      aliases: ['ETF', 'Fonds Indiciel', 'Trackers'],
      example:
          'Acheter une part d\'un ETF S&P 500 vous rend indirectement propriétaire d\'une fraction des 500 plus grandes entreprises américaines.',
      actionRoute: 'search',
      actionLabel: 'Explorer les ETF',
    ),
    LexiconItem(
      id: 'stock',
      term: 'Action',
      category: LexiconCategory.market,
      shortDefinition:
          'Titre de propriété représentant une fraction du capital d\'une société.',
      detailedDefinition:
          'Acheter une action fait de vous un co-propriétaire de l\'entreprise. Vous bénéficiez ainsi des plus-values lorsque l\'entreprise se développe et des dividendes éventuels.',
      aliases: ['Action', 'Actions', 'Stock'],
    ),
    LexiconItem(
      id: 'volume',
      term: 'Volume d\'Échange',
      category: LexiconCategory.market,
      shortDefinition:
          'Nombre total de titres achetés et vendus au cours d\'une période donnée.',
      detailedDefinition:
          'Un volume important indique une forte activité des investisseurs et une liquidité élevée, facilitant l\'exécution rapide des ordres au prix souhaité.',
      aliases: ['Volume', 'Volume d\'Échange', 'Volume d\'Echange'],
    ),
    LexiconItem(
      id: 'pmpa',
      term: 'PMPA (Prix Moyen Pondéré d\'Achat)',
      category: LexiconCategory.portfolio,
      shortDefinition:
          'Moyenne des prix d\'acquisition d\'un actif pondérée par les quantités.',
      detailedDefinition:
          'Le PMPA réactualise le coût moyen d\'un titre à chaque nouvel achat. C\'est votre prix de référence pour savoir si vous êtes en gain ou en perte sur la ligne.',
      aliases: [
        'PMPA',
        'Prix Moyen Pondéré d\'Achat',
        'Prix Moyen Pondere d\'Achat',
      ],
      example:
          'Achat 1 : 2 actions à 100 € (200 €)\nAchat 2 : 1 action à 130 € (130 €)\nTotal : 3 actions pour 330 €\nPMPA = 330 / 3 = 110 €.',
      formula: 'PMPA = Total des montants d\'achat / Nombre total de titres',
      actionRoute: 'portfolio',
      actionLabel: 'Voir mon Portefeuille',
    ),
    LexiconItem(
      id: 'variation_pct',
      term: 'Variation %',
      category: LexiconCategory.portfolio,
      shortDefinition:
          'Pourcentage de hausse ou de baisse de la valeur par rapport au cours précédent.',
      detailedDefinition:
          'Mesure l\'évolution en pourcentage du prix de l\'actif par rapport au dernier cours de clôture ou par rapport au PMPA.',
      aliases: ['Variation %', 'Variation', 'Variation en %'],
    ),
    LexiconItem(
      id: 'latent_gain',
      term: 'Plus-value Latente (Gain/Perte)',
      category: LexiconCategory.portfolio,
      shortDefinition:
          'Bénéfice ou perte virtuel(le) calculé(e) sur vos positions actuelles.',
      detailedDefinition:
          'La plus-value latente représente l\'écart entre la valeur actuelle de votre position au cours du marché et votre prix d\'achat moyen (PMPA). Elle n\'est pas encore matérialisée en cash.',
      aliases: [
        'Plus-value Latente',
        'Plus-value latente',
        'Gain latent',
        'Perte latente',
      ],
      example:
          'Vous possédez 5 actions avec un PMPA de 50 €. Le cours actuel est 60 €. Votre gain latent est de (60 - 50) × 5 = +50 € (+20 %).',
      formula: 'Plus-value Latente = (Cours Actuel - PMPA) × Quantité',
      actionRoute: 'portfolio',
      actionLabel: 'Consulter mes positions',
    ),
    LexiconItem(
      id: 'realized_gain',
      term: 'Plus-value Réalisée',
      category: LexiconCategory.portfolio,
      shortDefinition:
          'Gain ou perte définitivement encaissé(e) lors de la revente d\'un actif.',
      detailedDefinition:
          'Contrairement à la plus-value latente, la plus-value réalisée est le profit réel sécurisé lorsque vous vendez des titres. Ce montant recrédite directement vos liquidités.',
      aliases: ['Plus-value Réalisée', 'Plus-value réalisée', 'Gain réalisé'],
      formula: 'Plus-value Réalisée = (Prix de Vente - PMPA) × Quantité Vendue',
    ),
    LexiconItem(
      id: 'cash_balance',
      term: 'Solde de Liquidités (Cash)',
      category: LexiconCategory.portfolio,
      shortDefinition:
          'Montant en euros disponible pour effectuer de nouveaux investissements.',
      detailedDefinition:
          'Dans l\'application, vous commencez avec 1 000,00 € de cash fictif. Ce solde diminue lorsque vous achetez des titres et augmente lors de vos reventes.',
      aliases: ['Solde de Liquidités', 'Cash', 'Liquidités', 'Solde Cash'],
      actionRoute: 'portfolio',
      actionLabel: 'Voir mon solde cash',
    ),
    LexiconItem(
      id: 'dca',
      term: 'DCA (Dollar-Cost Averaging)',
      category: LexiconCategory.strategy,
      shortDefinition:
          'Investissement automatique d\'un montant fixe à intervalles réguliers.',
      detailedDefinition:
          'Le DCA consiste à placer le même montant (ex: 100 €/mois) quel que soit l\'état du marché. Cela permet de lisser le cours moyen d\'achat sur le long terme et d\'éliminer le stress de devoir choisir le "bon moment".',
      aliases: ['DCA', 'Dollar-Cost Averaging', 'Investissement Programmé'],
      example:
          'En versant 100 € par mois, vous achetez naturellement plus de titres quand les prix baissent et moins quand ils montent.',
      actionRoute: 'dca_simulator',
      actionLabel: 'Tester le Simulateur DCA',
    ),
    LexiconItem(
      id: 'compound_interest',
      term: 'Intérêts Composés',
      category: LexiconCategory.strategy,
      shortDefinition:
          'Phénomène où les gains accumulés génèrent eux-mêmes de nouveaux gains.',
      detailedDefinition:
          'Les intérêts composés créent un effet "boule de neige" puissant. En réinvestissant vos rendements année après année, la croissance du capital s\'accélère de façon exponentielle.',
      aliases: ['Intérêts Composés', 'Interets Composes', 'Intérêts composés'],
      formula: 'Capital Final = PMT × [((1 + r/12)^n - 1) / (r/12)]',
      actionRoute: 'dca_simulator',
      actionLabel: 'Simuler la croissance',
    ),
    LexiconItem(
      id: 'cagr',
      term: 'CAGR (Taux de Croissance Annuel Composé)',
      category: LexiconCategory.strategy,
      shortDefinition:
          'Taux de rendement annuel moyen lissé sur plusieurs années.',
      detailedDefinition:
          'Le CAGR indique la vitesse de progression annuelle théorique nécessaire pour passer d\'un montant initial à une valeur finale sur un horizon donné.',
      aliases: [
        'CAGR',
        'Taux de rendement',
        'Taux de Croissance Annuel Composé',
      ],
      formula: 'CAGR = (Valeur Finale / Valeur Initiale)^(1 / Années) - 1',
    ),
    LexiconItem(
      id: 'app_portfolio_value_formula',
      term: 'Calcul de la Valeur du Portefeuille (Formule App)',
      category: LexiconCategory.formulas,
      shortDefinition:
          'Algorithme de calcul du patrimoine total dans FinancialCalculator.',
      detailedDefinition:
          'L\'application additionne la valeur boursière instantanée de chacun des actifs possédés et y ajoute le solde de liquidités disponible.',
      aliases: ['Valeur du Portefeuille', 'Patrimoine Total'],
      formula:
          'Patrimoine Total = Solde Cash + SUM(Quantité Actif × Cours Actuel)',
      actionRoute: 'portfolio',
      actionLabel: 'Vérifier mon Portefeuille',
    ),
    LexiconItem(
      id: 'app_xp_formula',
      term: 'Niveaux & Points d\'XP (Formule App)',
      category: LexiconCategory.formulas,
      shortDefinition:
          'Règles d\'attribution de l\'expérience et calcul des niveaux d\'investisseur.',
      detailedDefinition:
          'Chaque tranche de 1 000 XP franchie vous fait monter d\'un niveau. Vous gagnez des points d\'XP via les connexions quotidiennes (+20 XP, bonus de série), le passage à l\'action (+50 XP par achat), les plus-values réalisées et la consultation pédagogique.',
      aliases: ['Niveaux', 'Points d\'XP', 'XP'],
      formula: 'Niveau = 1 + floor(XP Total / 1000)',
      actionRoute: 'profile',
      actionLabel: 'Consulter mon Niveau',
    ),
  ];
}
