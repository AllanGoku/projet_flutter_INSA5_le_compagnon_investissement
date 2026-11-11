// [AI-GENERATED] Phase 3, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_compagnon_investissement/views/widgets/market_term_help_button.dart';

void main() {
  group('MarketTermHelpButton - Tests de widgets', () {
    testWidgets('Affiche le bouton avec l\'icône d\'aide', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MarketTermHelpButton(term: 'ETF')),
        ),
      );

      expect(find.byType(MarketTermHelpButton), findsOneWidget);
      expect(find.byIcon(Icons.help_outline_rounded), findsOneWidget);
    });

    testWidgets(
      'Ouvre la modale pédagogique explicative au clic sur le bouton',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: MarketTermHelpButton(term: 'ETF')),
          ),
        );

        // Clic sur l'icône d'aide
        await tester.tap(find.byIcon(Icons.help_outline_rounded));
        await tester.pumpAndSettle();

        // Vérification que l'AlertDialog est affiché avec la définition de l'ETF
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('ETF'), findsOneWidget);
        expect(
          find.textContaining('Un ETF (Exchange Traded Fund'),
          findsOneWidget,
        );
        expect(find.text('J\'ai compris'), findsOneWidget);
      },
    );

    testWidgets('Ferme la modale pédagogique au clic sur "J\'ai compris"', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MarketTermHelpButton(term: 'Volume')),
        ),
      );

      // Ouverture de la modale
      await tester.tap(find.byIcon(Icons.help_outline_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);

      // Fermeture de la modale
      await tester.tap(find.byKey(const Key('help_modal_close_button')));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}
