// [AI-GENERATED] Phase 4, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/portfolio_position.dart';
import '../../controllers/portfolio_controller.dart';
import '../../models/financial_calculator.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatters.dart';
import 'performance_text.dart';

/// Feuille modale (`ModalBottomSheet`) de revente d'actif fictif.
///
/// Permet à l'utilisateur de sélectionner ou de saisir un nombre entier d'unités à vendre
/// (via Slider, champ de texte, ou bouton "Tout vendre").
/// Affiche la plus/moins-value réalisée estimée, le montant crédité sur les liquidités et valide l'opération.
class SellAssetSheet extends StatefulWidget {
  final PortfolioPosition position;
  final VoidCallback? onSellSuccess;

  const SellAssetSheet({
    super.key,
    required this.position,
    this.onSellSuccess,
  });

  @override
  State<SellAssetSheet> createState() => _SellAssetSheetState();
}

class _SellAssetSheetState extends State<SellAssetSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _quantityController;
  late double _maxUnits;
  double _quantity = 1.0;

  @override
  void initState() {
    super.initState();
    _maxUnits = widget.position.quantity;
    final initialVal = _maxUnits >= 1.0 ? 1.0 : _maxUnits;
    _quantity = initialVal;
    _quantityController = TextEditingController(
      text: initialVal % 1 == 0 ? initialVal.toInt().toString() : initialVal.toString(),
    );
    _quantityController.addListener(_onQuantityChanged);
  }

  @override
  void dispose() {
    _quantityController.removeListener(_onQuantityChanged);
    _quantityController.dispose();
    super.dispose();
  }

  void _onQuantityChanged() {
    final parsed = double.tryParse(_quantityController.text.replaceAll(',', '.'));
    if (parsed != null && parsed > 0 && parsed <= _maxUnits) {
      setState(() {
        _quantity = parsed;
      });
    }
  }

  void _setQuantity(double value) {
    final intValue = value.floor();
    _quantityController.text = intValue.toString();
  }

  Future<void> _submitSell() async {
    if (_formKey.currentState?.validate() ?? false) {
      final parsed = double.tryParse(_quantityController.text.replaceAll(',', '.'));
      if (parsed == null || parsed <= 0 || (parsed - parsed.round()).abs() > 0.0001) return;

      try {
        final portfolioController = context.read<PortfolioController>();
        await portfolioController.sellAsset(widget.position.asset, parsed);

        if (mounted) {
          Navigator.of(context).maybePop();
          if (widget.onSellSuccess != null) {
            widget.onSellSuccess!();
          }
        }
      } catch (e) {
        debugPrint("Erreur lors de la revente: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                e.toString().replaceAll('StateError: ', '').replaceAll('ArgumentError: ', ''),
              ),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double estimatedSaleValue = _quantity * widget.position.asset.currentPrice;
    final double estimatedRealizedGain = FinancialCalculator.calculateRealizedGain(
      sellPrice: widget.position.asset.currentPrice,
      averagePurchasePrice: widget.position.averagePurchasePrice,
      quantity: _quantity,
    );
    final double investedPart = _quantity * widget.position.averagePurchasePrice;
    final double gainPercentage = FinancialCalculator.calculatePerformance(
      initialValue: investedPart,
      currentValue: estimatedSaleValue,
    );

    final int maxIntegerUnits = _maxUnits.floor();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poignée de glissement
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Titre et informations de l'actif
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Revente Fictive',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.position.asset.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.position.asset.symbol,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Rappel des informations de la position
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('Possédé', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                          const SizedBox(height: 2),
                          Text(
                            '${maxIntegerUnits} un.',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                      Container(height: 20, width: 1, color: Colors.grey.shade300),
                      Column(
                        children: [
                          Text('PMPA d\'achat', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                          const SizedBox(height: 2),
                          Text(
                            Formatters.formatCurrency(widget.position.averagePurchasePrice),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                      Container(height: 20, width: 1, color: Colors.grey.shade300),
                      Column(
                        children: [
                          Text('Cours actuel', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                          const SizedBox(height: 2),
                          Text(
                            Formatters.formatCurrency(widget.position.asset.currentPrice),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Champ de saisie de la quantité
                TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Quantité d\'unités à vendre (Entier)',
                    hintText: 'Ex: 1, 2, $maxIntegerUnits',
                    prefixIcon: const Icon(Icons.numbers_rounded, color: Colors.redAccent),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez saisir une quantité à vendre.';
                    }
                    final val = double.tryParse(value.replaceAll(',', '.'));
                    if (val == null || val <= 0) {
                      return 'La quantité doit être supérieure à 0.';
                    }
                    if ((val - val.round()).abs() > 0.0001) {
                      return 'Veuillez saisir un nombre entier d\'unités (pas de fractions).';
                    }
                    if (val > _maxUnits) {
                      return 'Quantité supérieure aux unités possédées ($maxIntegerUnits).';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Slider d'unités entières si maxIntegerUnits > 1
                if (maxIntegerUnits > 1) ...[
                  Row(
                    children: [
                      const Text('1', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Slider(
                          value: _quantity.clamp(1.0, maxIntegerUnits.toDouble()),
                          min: 1.0,
                          max: maxIntegerUnits.toDouble(),
                          divisions: maxIntegerUnits > 1 ? maxIntegerUnits - 1 : 1,
                          activeColor: Colors.redAccent,
                          label: _quantity.round().toString(),
                          onChanged: (val) {
                            _setQuantity(val);
                          },
                        ),
                      ),
                      Text('$maxIntegerUnits', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],

                // Bouton raccourci "Tout vendre"
                Align(
                  alignment: Alignment.centerRight,
                  child: ActionChip(
                    label: const Text('Tout vendre'),
                    labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red.shade700),
                    backgroundColor: Colors.red.shade50,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onPressed: () => _setQuantity(maxIntegerUnits.toDouble()),
                  ),
                ),
                const SizedBox(height: 16),

                // Estimation du produit de revente et de la plus-value réalisée
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Liquidités créditées',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                          ),
                          Text(
                            '+ ${Formatters.formatCurrency(estimatedSaleValue)}',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Plus-value réalisée estimée',
                            style: TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                          Row(
                            children: [
                              PerformanceText(
                                value: estimatedRealizedGain,
                                isCurrency: true,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              Text(' (', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                              PerformanceText(
                                value: gainPercentage,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              Text(')', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Bouton de confirmation de la revente
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    key: const Key('confirm_sell_button'),
                    onPressed: _submitSell,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Confirmer la revente fictive',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
