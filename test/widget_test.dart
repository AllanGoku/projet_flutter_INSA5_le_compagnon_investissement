// [AI-GENERATED] Setup, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:le_compagnon_investissement/main.dart';
import 'package:le_compagnon_investissement/views/screens/dashboard_screen.dart';

void main() {
  testWidgets('Smoke test: Dashboard screen loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the dashboard screen is shown.
    expect(find.byType(DashboardScreen), findsOneWidget);
    
    // Verify that the title is present
    expect(find.text('Le Compagnon d\'Investissement'), findsOneWidget);
    expect(find.text('Bienvenue dans votre tableau de bord.'), findsOneWidget);
  });
}
