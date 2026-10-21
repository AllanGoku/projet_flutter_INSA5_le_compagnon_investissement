// [AI-GENERATED] Phase 4, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_compagnon_investissement/models/portfolio_transaction.dart';
import 'package:le_compagnon_investissement/views/widgets/transaction_history_section.dart';

void main() {
  final now = DateTime.now();

  group('TransactionHistorySection Widget Tests', () {
    testWidgets('Affiche la liste des transactions d\'achat et de revente', (WidgetTester tester) async {
      final transactions = [
        PortfolioTransaction(
          symbol: 'AAPL',
          assetName: 'Apple Inc.',
          type: TransactionType.buy,
          quantity: 5.0,
          price: 150.0,
          timestamp: now,
        ),
        PortfolioTransaction(
          symbol: 'NVDA',
          assetName: 'NVIDIA Corporation',
          type: TransactionType.sell,
          quantity: 2.0,
          price: 200.0,
          timestamp: now.subtract(const Duration(hours: 2)),
          realizedGain: 50.0,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TransactionHistorySection(transactions: transactions),
            ),
          ),
        ),
      );

      expect(find.text('Historique des Transactions'), findsOneWidget);
      expect(find.text('ACHAT'), findsOneWidget);
      expect(find.text('VENTE'), findsOneWidget);
      expect(find.text('AAPL'), findsOneWidget);
      expect(find.text('NVDA'), findsOneWidget);
    });

    testWidgets('Affiche le message vide lorsque aucune transaction n\'existe', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TransactionHistorySection(transactions: []),
          ),
        ),
      );

      expect(find.text('Historique des Transactions'), findsOneWidget);
      expect(find.text('Aucune transaction enregistrée'), findsOneWidget);
    });
  });
}
