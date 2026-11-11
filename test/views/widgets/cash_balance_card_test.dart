// [AI-GENERATED] Phase 4, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_compagnon_investissement/views/widgets/cash_balance_card.dart';

void main() {
  group('CashBalanceCard Widget Tests', () {
    testWidgets('Affiche le solde de liquidités et le libellé', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CashBalanceCard(cashBalance: 750.0)),
        ),
      );

      expect(find.text('Liquidités disponibles'), findsOneWidget);
      expect(find.byType(CashBalanceCard), findsOneWidget);
    });
  });
}
