// [AI-GENERATED] Setup, Agent, 2025-02-23
import 'asset.dart';

/// Modèle représentant une ligne (position) dans le portefeuille fictif de l'utilisateur.
///
/// Associe un actif [Asset] à une [quantity] détenue et un [averagePurchasePrice] (prix de revient unitaire).
/// Utilisé pour suivre les investissements fictifs et calculer les plus-values.
class PortfolioPosition {
  final Asset asset;
  final double quantity;
  final double averagePurchasePrice;

  PortfolioPosition({
    required this.asset,
    required this.quantity,
    required this.averagePurchasePrice,
  });

  /// Crée une instance [PortfolioPosition] à partir d'une map JSON.
  factory PortfolioPosition.fromJson(Map<String, dynamic> json) {
    return PortfolioPosition(
      asset: Asset.fromJson(json['asset'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num).toDouble(),
      averagePurchasePrice: (json['averagePurchasePrice'] as num).toDouble(),
    );
  }

  /// Sérialise l'instance [PortfolioPosition] en une map JSON.
  Map<String, dynamic> toJson() {
    return {
      'asset': asset.toJson(),
      'quantity': quantity,
      'averagePurchasePrice': averagePurchasePrice,
    };
  }
}
