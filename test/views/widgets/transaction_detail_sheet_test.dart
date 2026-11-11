// [AI-GENERATED] Phase 4, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_compagnon_investissement/models/portfolio_transaction.dart';
import 'package:le_compagnon_investissement/views/widgets/transaction_detail_sheet.dart';

void main() {
  final now = DateTime.now();

  group('TransactionDetailSheet Widget Tests', () {
    testWidgets('Affiche les détails d\'une transaction d\'achat', (
      WidgetTester tester,
    ) async {
      final transaction = PortfolioTransaction(
        symbol: 'AAPL',
        assetName: 'Apple Inc.',
        type: TransactionType.buy,
        quantity: 5.0,
        price: 150.0,
        timestamp: now,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionDetailSheet(transaction: transaction),
          ),
        ),
      );

      expect(find.text('Détails de la Transaction'), findsOneWidget);
      expect(find.text('Apple Inc.'), findsOneWidget);
      expect(find.text('AAPL'), findsOneWidget);
      expect(find.text('ACHAT'), findsOneWidget);
      expect(find.text('Voir la fiche de l\'actif'), findsOneWidget);
    });

    testWidgets('Affiche la plus-value pour une revente', (
      WidgetTester tester,
    ) async {
      final transaction = PortfolioTransaction(
        symbol: 'NVDA',
        assetName: 'NVIDIA Corporation',
        type: TransactionType.sell,
        quantity: 2.0,
        price: 200.0,
        timestamp: now,
        realizedGain: 80.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionDetailSheet(transaction: transaction),
          ),
        ),
      );

      expect(find.text('VENTE'), findsOneWidget);
      expect(find.text('Plus-value réalisée'), findsOneWidget);
    });
  });
}
