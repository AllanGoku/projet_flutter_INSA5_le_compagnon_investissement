// [AI-GENERATED] Issue #0, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_compagnon_investissement/views/widgets/soft_card.dart';

void main() {
  group('SoftCard Widget', () {
    testWidgets('s\'instancie correctement et affiche son enfant', (
      WidgetTester tester,
    ) async {
      const childKey = Key('soft-card-child');

      // Pompage du widget SoftCard avec un enfant simple
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SoftCard(child: Text('Contenu de la carte', key: childKey)),
          ),
        ),
      );

      // Vérification que le widget a bien été rendu
      expect(find.byType(SoftCard), findsOneWidget);

      // Vérification que l'enfant de la carte est bien affiché
      expect(find.byKey(childKey), findsOneWidget);
      expect(find.text('Contenu de la carte'), findsOneWidget);
    });
  });
}
