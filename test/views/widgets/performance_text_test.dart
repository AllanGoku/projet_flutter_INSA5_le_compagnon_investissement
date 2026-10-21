// [AI-GENERATED] Issue #0, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_compagnon_investissement/utils/app_theme.dart';
import 'package:le_compagnon_investissement/views/widgets/performance_text.dart';

void main() {
  group('PerformanceText Widget', () {
    testWidgets('affiche le texte en vert pour une valeur positive', (WidgetTester tester) async {
      // Préparation du widget avec une valeur positive
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PerformanceText(value: 15.0),
          ),
        ),
      );

      // Récupération du widget Text rendu
      final textFinder = find.byType(Text);
      expect(textFinder, findsOneWidget);

      final Text textWidget = tester.widget(textFinder);
      
      // Vérification de la couleur et du format (qui vient de Formatters)
      expect(textWidget.style?.color, AppTheme.gainColor);
      expect(textWidget.data, contains('+15,00'));
    });

    testWidgets('affiche le texte en rouge pour une valeur négative', (WidgetTester tester) async {
      // Préparation du widget avec une valeur négative
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PerformanceText(value: -10.0),
          ),
        ),
      );

      // Récupération du widget Text rendu
      final textFinder = find.byType(Text);
      expect(textFinder, findsOneWidget);

      final Text textWidget = tester.widget(textFinder);
      
      // Vérification de la couleur et du format (qui vient de Formatters)
      expect(textWidget.style?.color, AppTheme.lossColor);
      expect(textWidget.data, contains('-10,00'));
    });
  });
}
