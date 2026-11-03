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
/// de vérifier le solde de liquidités disponible en temps réel,
/// de bénéficier de boutons raccourcis (+1, +5, +10) et de déclencher l'animation de paiement.
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

      try {
        final portfolioController = context.read<PortfolioController>();
        await portfolioController.buyAsset(widget.asset, _quantity);

        setState(() {
          _showAnimation = true;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                e.toString().replaceAll('StateError: ', '').replaceAll('ArgumentError: ', ''),
              ),
              backgroundColor: AppTheme.lossColor,
            ),
          );
        }
      }
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

    final double availableCash = context.watch<PortfolioController>().cashBalance;
    final double totalCost = _quantity * widget.asset.currentPrice;
    final bool hasEnoughCash = totalCost <= availableCash;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          top: false,
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
              const SizedBox(height: 16),

              // Rappel des liquidités disponibles
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: hasEnoughCash ? AppTheme.mint.withOpacity(0.12) : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: hasEnoughCash ? AppTheme.mint.withOpacity(0.3) : Colors.red.shade200,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 18,
                          color: hasEnoughCash ? AppTheme.primaryColor : Colors.red.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Liquidités disponibles :',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: hasEnoughCash ? AppTheme.primaryColor : Colors.red.shade900,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      Formatters.formatCurrency(availableCash),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: hasEnoughCash ? AppTheme.primaryColor : Colors.red.shade900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

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
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantité d\'unités (Entier)',
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
                  if ((val - val.round()).abs() > 0.0001) {
                    return 'Veuillez saisir un nombre entier d\'unités (pas de fractions).';
                  }
                  final cost = val * widget.asset.currentPrice;
                  final available = context.read<PortfolioController>().cashBalance;
                  if (cost > available) {
                    return 'Solde insuffisant (${Formatters.formatCurrency(available)} disponible).';
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
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: hasEnoughCash ? AppTheme.primaryColor : Colors.red.shade700,
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
                    backgroundColor: hasEnoughCash ? AppTheme.primaryColor : Colors.grey.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    hasEnoughCash ? 'Confirmer l\'achat fictif' : 'Solde de liquidités insuffisant',
                    style: const TextStyle(
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
