// [AI-GENERATED] Issue #6, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../models/asset.dart';
import '../../models/financial_calculator.dart';
import '../../controllers/data_controller.dart';
import '../../controllers/portfolio_controller.dart';
import '../../controllers/gamification_controller.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatters.dart';
import '../widgets/buy_asset_sheet.dart';
import '../widgets/market_term_help_button.dart';

/// Option d'actif présélectionnée avec taux d'intérêt annuel estimé pour le simulateur.
class DcaAssetOption {
  final String label;
  final double estimatedReturnRate;
  final Asset? asset;
  final bool isCustomRateMode;

  const DcaAssetOption({
    required this.label,
    required this.estimatedReturnRate,
    this.asset,
    this.isCustomRateMode = false,
  });
}

/// Écran du simulateur DCA (Dollar-Cost Averaging) et calcul d'intérêts composés.
///
/// Permet de simuler l'investissement régulier mensuel sur un actif financier,
/// d'observer l'effet cumulé des intérêts composés sur 1, 5, 10 ou 20 ans,
/// de comparer les gains face à un placement garanti (ex: Livret A à 3%),
/// et de directement déclencher un achat fictif via `BuyAssetSheet`.
class DcaSimulatorScreen extends StatefulWidget {
  final Asset? initialAsset;

  const DcaSimulatorScreen({super.key, this.initialAsset});

  @override
  State<DcaSimulatorScreen> createState() => _DcaSimulatorScreenState();
}

class _DcaSimulatorScreenState extends State<DcaSimulatorScreen> {
  double _monthlyAmount = 100.0;
  int _durationYears = 10;
  double _currentReturnRate = 7.0;
  late TextEditingController _amountController;

  late List<DcaAssetOption> _assetOptions = [];
  late DcaAssetOption _selectedOption;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: '100');

    // Déclenchement automatique du succès "Pionnier du DCA" lors de l'utilisation du simulateur
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          final portfolio = context.read<PortfolioController>();
          final gamification = context.read<GamificationController>();
          gamification.checkAchievements(
            portfolioValue: portfolio.totalValue,
            totalInvested: portfolio.totalInvested,
            assetCount: portfolio.positions.length,
            hasSimulatedDCA: true,
            readLexicon: false,
          );
        } catch (_) {}
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_assetOptions.length > 5) return; // Déjà initialisé dynamiquement

    final dataController = context.read<DataController>();
    final loadedAssets = dataController.assets.values.toList();

    List<DcaAssetOption> dynamicOptions = [];

    if (loadedAssets.isNotEmpty) {
      for (final asset in loadedAssets) {
        final rate = FinancialCalculator.calculateAssetAnnualizedReturn(asset);
        dynamicOptions.add(
          DcaAssetOption(
            label: '${asset.name} (${asset.symbol})',
            estimatedReturnRate: rate,
            asset: asset,
          ),
        );
      }
    }

    const customOption = DcaAssetOption(
      label: 'Taux personnalisé (sur-mesure)',
      estimatedReturnRate: 7.0,
      asset: null,
      isCustomRateMode: true,
    );

    setState(() {
      _assetOptions = [...dynamicOptions, customOption];

      if (widget.initialAsset != null) {
        final initialAsset = widget.initialAsset!;
        final existingIndex = _assetOptions.indexWhere(
          (opt) => opt.asset?.symbol == initialAsset.symbol,
        );

        if (existingIndex != -1) {
          _selectedOption = _assetOptions[existingIndex];
        } else {
          final calculatedRate =
              FinancialCalculator.calculateAssetAnnualizedReturn(initialAsset);
          final customOpt = DcaAssetOption(
            label: '${initialAsset.name} (${initialAsset.symbol})',
            estimatedReturnRate: calculatedRate,
            asset: initialAsset,
          );
          _assetOptions.insert(0, customOpt);
          _selectedOption = customOpt;
        }
      } else {
        _selectedOption = _assetOptions.first;
      }

      if (_selectedOption.asset != null) {
        _currentReturnRate = FinancialCalculator.calculateAssetAnnualizedReturn(
          _selectedOption.asset!,
        );
      } else {
        _currentReturnRate = 7.0;
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onAmountChanged(String val) {
    final parsed = double.tryParse(val);
    if (parsed != null && parsed >= 0) {
      setState(() {
        _monthlyAmount = parsed.clamp(10.0, 1000.0);
      });
    }
  }

  void _openBuySheet() {
    final Asset assetToBuy =
        _selectedOption.asset ??
        _assetOptions.where((opt) => opt.asset != null).firstOrNull?.asset ??
        context.read<DataController>().assets.values.firstOrNull ??
        Asset(
          symbol: 'AAPL',
          name: 'Apple Inc.',
          currentPrice: 180.0,
          changePercentage: 1.4,
          type: 'Action',
          description: 'Apple Inc.',
          marketOpen: true,
          timezone: 'US/Eastern',
          timeSeries: const {},
        );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BuyAssetSheet(
        asset: assetToBuy,
        onPurchaseSuccess: () {
          Navigator.of(context).pop('open_portfolio');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calcul de la projection de scénarios DCA avec intérêts composés et historique de l'actif
    final simulation = FinancialCalculator.simulateDcaProjection(
      monthlyAmount: _monthlyAmount,
      annualReturnRate: _currentReturnRate,
      durationYears: _durationYears,
      beta: _selectedOption.asset?.beta ?? 1.0,
    );

    final double totalInvested = simulation['totalInvested'] ?? 0.0;
    final double finalValue = simulation['neutralValue'] ?? 0.0;
    final double pessimisticValue = simulation['pessimisticValue'] ?? 0.0;
    final double optimisticValue = simulation['optimisticValue'] ?? 0.0;

    final List<Map<String, double>> yearlyData = simulation['yearlyData'] ?? [];

    final double totalGains = finalValue - totalInvested;

    // Simulation comparative avec un placement sécurisé à 3% (Livret A)
    final comparison3 = FinancialCalculator.simulateDcaProjection(
      monthlyAmount: _monthlyAmount,
      annualReturnRate: 3.0,
      durationYears: _durationYears,
    );
    final double comparison3Final = comparison3['neutralValue'] ?? 0.0;
    final double gainsDiff3 = finalValue - comparison3Final;

    // Proportions pour la barre bicolore de répartition (sur le scénario Neutre)
    final double investedRatio = finalValue > 0
        ? (totalInvested / finalValue).clamp(0.0, 1.0)
        : 1.0;
    final double gainsRatio = finalValue > 0
        ? (totalGains / finalValue).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Simulateur DCA',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: const [
          MarketTermHelpButton(term: 'DCA', iconSize: 22),
          SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Carte de configuration de la simulation
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Expanded(
                          child: Text(
                            'Montant mensuel à investir',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        MarketTermHelpButton(term: 'DCA', iconSize: 18),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Champ texte + Slider
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            key: const Key('dca_monthly_amount_slider'),
                            value: _monthlyAmount.clamp(10.0, 1000.0),
                            min: 10.0,
                            max: 1000.0,
                            divisions: 99,
                            activeColor: AppTheme.primaryColor,
                            inactiveColor: Colors.grey.shade200,
                            onChanged: (val) {
                              setState(() {
                                _monthlyAmount = val;
                                _amountController.text = val.round().toString();
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 100,
                          child: TextField(
                            key: const Key('dca_monthly_amount_field'),
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                            decoration: InputDecoration(
                              suffixText: '€',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppTheme.primaryColor,
                                  width: 2,
                                ),
                              ),
                            ),
                            onChanged: _onAmountChanged,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Sélection de la durée (Puces 1, 5, 10, 20 ans)
                    const Text(
                      'Horizon de placement (durée)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [1, 5, 10, 20].map((years) {
                        final isSelected = _durationYears == years;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2.0,
                            ),
                            child: ChoiceChip(
                              key: Key('dca_duration_chip_$years'),
                              label: Center(
                                child: Text(
                                  '$years ${years > 1 ? 'ans' : 'an'}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              showCheckmark: false,
                              selected: isSelected,
                              selectedColor: AppTheme.primaryColor,
                              backgroundColor: Colors.grey.shade100,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _durationYears = years;
                                  });
                                }
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Choix de l'actif simulé
                    const Text(
                      'Actif ou Indice de référence',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      key: const Key('dca_asset_selector'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<DcaAssetOption>(
                          isExpanded: true,
                          value: _selectedOption,
                          icon: const Icon(
                            Icons.arrow_drop_down_rounded,
                            color: AppTheme.primaryColor,
                          ),
                          items: _assetOptions.map((opt) {
                            return DropdownMenuItem<DcaAssetOption>(
                              value: opt,
                              child: Text(
                                opt.label,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (newOpt) {
                            if (newOpt != null) {
                              setState(() {
                                _selectedOption = newOpt;
                                if (newOpt.asset != null) {
                                  _currentReturnRate =
                                      FinancialCalculator.calculateAssetAnnualizedReturn(
                                        newOpt.asset!,
                                      );
                                } else {
                                  _currentReturnRate = 7.0;
                                }
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Taux de rendement : calculé automatiquement si actif sélectionné, ou slider si mode sur-mesure
                    if (!_selectedOption.isCustomRateMode) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              color: Colors.blue.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Taux de référence basé sur l\'historique de l\'actif : +${_currentReturnRate.toStringAsFixed(1)}% / an',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const MarketTermHelpButton(
                              term: 'Taux de rendement',
                              iconSize: 18,
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Taux de rendement annuel sur-mesure',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.mint.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '+${_currentReturnRate.toStringAsFixed(1)} % / an',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const MarketTermHelpButton(
                                term: 'Taux de rendement',
                                iconSize: 18,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Slider(
                        key: const Key('dca_return_rate_slider'),
                        value: _currentReturnRate.clamp(0.0, 30.0),
                        min: 0.0,
                        max: 30.0,
                        divisions: 60,
                        activeColor: AppTheme.primaryColor,
                        inactiveColor: Colors.grey.shade200,
                        onChanged: (val) {
                          setState(() {
                            _currentReturnRate = val;
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Disclaimer pédagogique sur la volatilité
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Avertissement : Les marchés fluctuent et ne montent jamais en ligne droite. '
                        'Ce simulateur projette 3 scénarios (Pessimiste, Neutre, Optimiste) basés sur la '
                        'volatilité de l\'actif pour être plus proche de la réalité.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Cône de Projection (Graphique fl_chart)
              if (yearlyData.length > 1) ...[
                const Text(
                  'Projection des scénarios',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22,
                            interval: (_durationYears / 5).ceilToDouble(),
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}A',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: yearlyData
                              .map((e) => FlSpot(e['year']!, e['optimistic']!))
                              .toList(),
                          isCurved: true,
                          color: AppTheme.mint,
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                        ),
                        LineChartBarData(
                          spots: yearlyData
                              .map((e) => FlSpot(e['year']!, e['neutral']!))
                              .toList(),
                          isCurved: true,
                          color: AppTheme.primaryColor,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                        ),
                        LineChartBarData(
                          spots: yearlyData
                              .map((e) => FlSpot(e['year']!, e['pessimistic']!))
                              .toList(),
                          isCurved: true,
                          color: Colors.orange.shade400,
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                        ),
                        LineChartBarData(
                          spots: yearlyData
                              .map((e) => FlSpot(e['year']!, e['invested']!))
                              .toList(),
                          isCurved: true,
                          color: Colors.grey.shade400,
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          dashArray: [5, 5],
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((LineBarSpot touchedSpot) {
                              final double val = touchedSpot.y;
                              return LineTooltipItem(
                                Formatters.formatCurrency(val),
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem('Optimiste', AppTheme.mint),
                    const SizedBox(width: 12),
                    _buildLegendItem('Neutre', AppTheme.primaryColor),
                    const SizedBox(width: 12),
                    _buildLegendItem('Pessimiste', Colors.orange.shade400),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // 2. Carte de Résultat principale (Dégradé Soft UI)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Valeur finale estimée (${_durationYears} ans)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade300,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.gainColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '+${_currentReturnRate.toStringAsFixed(1)}% / an',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.gainColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Montant final en gros (Neutre) avec fourchette Haut/Bas
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          key: const Key('dca_final_value'),
                          Formatters.formatCurrency(finalValue),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.arrow_upward_rounded,
                                    color: AppTheme.mint,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Opti. : ${Formatters.formatCurrency(optimisticValue)}',
                                      style: const TextStyle(
                                        color: AppTheme.mint,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.arrow_downward_rounded,
                                    color: Colors.orange.shade400,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Pess. : ${Formatters.formatCurrency(pessimisticValue)}',
                                      style: TextStyle(
                                        color: Colors.orange.shade400,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Détails Capital Investi vs Gains
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Capital versé',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              key: const Key('dca_total_invested'),
                              Formatters.formatCurrency(totalInvested),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Gains générés',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              key: const Key('dca_total_gains'),
                              '+${Formatters.formatCurrency(totalGains)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.gainColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Barre de répartition bicolore
                    ClipRRect(
                      key: const Key('dca_distribution_bar'),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        height: 10,
                        width: double.infinity,
                        color: Colors.grey.shade700,
                        child: Row(
                          children: [
                            Expanded(
                              flex: (investedRatio * 100).round(),
                              child: Container(color: AppTheme.mint),
                            ),
                            Expanded(
                              flex: (gainsRatio * 100).round(),
                              child: Container(color: AppTheme.gainColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Carte de comparaison visuelle avec placement à 3%
              Container(
                key: const Key('dca_comparison_card'),
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.blue.shade100, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.compare_arrows_rounded,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Comparaison avec un placement à 3%',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Un placement à 3% (ex: Livret d\'épargne) vous aurait rapporté ${Formatters.formatCurrency(comparison3Final)}.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: gainsDiff3 >= 0
                            ? Colors.green.shade50
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            gainsDiff3 >= 0
                                ? Icons.trending_up_rounded
                                : Icons.trending_flat_rounded,
                            color: gainsDiff3 >= 0
                                ? AppTheme.gainColor
                                : Colors.orange,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              gainsDiff3 >= 0
                                  ? '+${Formatters.formatCurrency(gainsDiff3)} de surplus grâce aux intérêts composés !'
                                  : 'Écart de ${Formatters.formatCurrency(gainsDiff3.abs())}.',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: gainsDiff3 >= 0
                                    ? Colors.green.shade900
                                    : Colors.orange.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),

      // Bouton d'action "Ajouter cet actif au portefeuille"
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              key: const Key('dca_buy_button'),
              onPressed: _openBuySheet,
              icon: const Icon(Icons.add_shopping_cart_rounded),
              label: Text(
                _selectedOption.asset != null
                    ? 'Ajouter ${_selectedOption.asset!.symbol} au portefeuille'
                    : 'Ajouter un actif au portefeuille',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
