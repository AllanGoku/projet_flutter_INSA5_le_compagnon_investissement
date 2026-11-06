// [AI-GENERATED] Issue #5, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_compagnon_investissement/models/user_profile.dart';
import 'package:le_compagnon_investissement/views/widgets/flip_gain_counter.dart';

void main() {
  testWidgets('FlipGainCounter affiche les initiales et le nom de l\'utilisateur', (WidgetTester tester) async {
    bool tapped = false;
    final user = UserProfile(
      firstName: 'Jean',
      lastName: 'Dupont',
      email: 'jean@dupont.com',
      country: 'FR',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FlipGainCounter(
            totalValue: 1200.0,
            capitalGain: 200.0,
            performancePercentage: 20.0,
            cashBalance: 800.0,
            user: user,
            onProfileTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    // Salutation avec le prénom
    expect(find.text('Bonjour, Jean'), findsOneWidget);

    // Initiales JD dans la bulle de profil
    expect(find.text('JD'), findsOneWidget);

    // Clic sur l'avatar du profil
    await tester.tap(find.text('JD'));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });
}
