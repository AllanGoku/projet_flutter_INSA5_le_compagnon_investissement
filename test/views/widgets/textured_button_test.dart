// [AI-GENERATED] Issue #0, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_compagnon_investissement/views/widgets/textured_button.dart';

void main() {
  group('TexturedButton Widget', () {
    testWidgets('s\'instancie correctement et répond au clic', (WidgetTester tester) async {
      bool buttonPressed = false;
      
      // Pompage du widget TexturedButton
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TexturedButton(
              label: 'Valider',
              onPressed: () {
                buttonPressed = true;
              },
            ),
          ),
        ),
      );

      // Vérification que le widget a bien été rendu
      expect(find.byType(TexturedButton), findsOneWidget);
      expect(find.text('Valider'), findsOneWidget);
      
      // Test de l'interaction (tap)
      await tester.tap(find.byType(TexturedButton));
      await tester.pumpAndSettle();
      
      // Vérification que l'action a été déclenchée
      expect(buttonPressed, isTrue);
    });
  });
}
