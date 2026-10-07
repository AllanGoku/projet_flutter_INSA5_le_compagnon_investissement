// [AI-GENERATED] Phase 2, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/asset.dart';
import '../../controllers/portfolio_controller.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatters.dart';
import 'purchase_animation.dart';

/// Feuille modale (`ModalBottomSheet`) d'achat d'actif fictif.
///
/// Permet à l'utilisateur de saisir la quantité souhaitée avec validation,
/// de bénéficier de boutons raccourcis (+1, +5, +10), d'observer le coût total
/// réestimé en temps réel et de déclencher l'animation de paiement.
class BuyAssetSheet extends StatefulWidget {
  final Asset asset;
  final VoidCallback? onPurchaseSuccess;

  const BuyAssetSheet({
    super.key,
    required this.asset,
    this.onPurchaseSuccess,
  });

  @override
  State<BuyAssetSheet> createState() => _BuyAssetSheetState();
}

class _BuyAssetSheetState extends State<BuyAssetSheet> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController(text: '1');
  double _quantity = 1.0;
  bool _showAnimation = false;

  @override
  void initState() {
    super.initState();
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
    setState(() {
      _quantity = (parsed != null && parsed > 0) ? parsed : 0.0;
    });
  }

  void _addQuantity(double delta) {
    final current = double.tryParse(_quantityController.text.replaceAll(',', '.')) ?? 0.0;
    final newValue = (current + delta).clamp(1.0, 10000.0);
    _quantityController.text = newValue % 1 == 0 ? newValue.toInt().toString() : newValue.toStringAsFixed(1);
  }

  Future<void> _submitPurchase() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_quantity <= 0) return;

      // Exécution de l'achat dans le contrôleur de portefeuille
      final portfolioController = context.read<PortfolioController>();
      await portfolioController.buyAsset(widget.asset, _quantity);

      setState(() {
        _showAnimation = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showAnimation) {
      return PurchaseAnimation(
        assetSymbol: widget.asset.symbol,
        quantity: _quantity,
        onCompleted: () {
          Navigator.of(context).pop();
          if (widget.onPurchaseSuccess != null) {
            widget.onPurchaseSuccess!();
          }
        },
      );
    }

    final double totalCost = _quantity * widget.asset.currentPrice;

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
                        'Achat Fictif',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.asset.name,
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
                      color: AppTheme.mint.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.asset.symbol,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Prix unitaire actuel
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Prix unitaire :',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Formatters.formatCurrency(widget.asset.currentPrice),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (widget.asset.originalCurrency != 'EUR') ...[
                        Text(
                          '(${widget.asset.originalPrice.toStringAsFixed(2)} ${widget.asset.originalCurrency})',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ]
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Champ de saisie de la quantité
              TextFormField(
                controller: _quantityController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Quantité d\'actifs',
                  hintText: 'Ex: 1, 5, 10',
                  prefixIcon: const Icon(Icons.numbers_rounded, color: AppTheme.mint),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez saisir une quantité.';
                  }
                  final val = double.tryParse(value.replaceAll(',', '.'));
                  if (val == null || val <= 0) {
                    return 'La quantité doit être supérieure à 0.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Boutons raccourcis de quantité (+1, +5, +10)
              Row(
                children: [
                  const Text(
                    'Raccourcis : ',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  _buildShortcutChip('+1', 1.0),
                  const SizedBox(width: 6),
                  _buildShortcutChip('+5', 5.0),
                  const SizedBox(width: 6),
                  _buildShortcutChip('+10', 10.0),
                ],
              ),
              const SizedBox(height: 20),

              // Total de la transaction
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Coût Total Fictif',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      Formatters.formatCurrency(totalCost),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Bouton de confirmation d'achat
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const Key('confirm_buy_button'),
                  onPressed: _submitPurchase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Confirmer l\'achat fictif',
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
    );
  }

  Widget _buildShortcutChip(String label, double value) {
    return ActionChip(
      label: Text(label),
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.azure),
      backgroundColor: Colors.blue.shade50,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onPressed: () => _addQuantity(value),
    );
  }
}
