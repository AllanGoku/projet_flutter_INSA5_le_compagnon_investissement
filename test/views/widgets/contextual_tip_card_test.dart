// [AI-GENERATED] Issue #5, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:le_compagnon_investissement/views/widgets/contextual_tip_card.dart';
import 'package:le_compagnon_investissement/controllers/auth_controller.dart';
import 'package:le_compagnon_investissement/models/user_profile.dart';
import 'package:le_compagnon_investissement/services/auth_service.dart';

// Un faux AuthController pour les tests
class FakeAuthService implements AuthService {
  @override
  Future<List<UserProfile>> getAllUsers() async => [];
  @override
  Future<UserProfile?> getCurrentUser() async => null;
  @override
  Future<bool> isKeepLoggedIn() async => false;
  @override
  Future<UserProfile> login(String e, String p, bool k) async =>
      throw Exception();
  @override
  Future<void> logout() async {}
  @override
  Future<void> register(UserProfile u, String p) async {}
  @override
  Future<void> updateUser(UserProfile u) async {}
}

class FakeAuthController extends AuthController {
  FakeAuthController({UserProfile? initialUser})
    : super(authService: FakeAuthService()) {
    _user = initialUser;
  }

  UserProfile? _user;

  @override
  UserProfile? get currentUser => _user;

  @override
  Future<void> toggleShowTips(bool show) async {
    if (_user != null) {
      _user = _user!.copyWith(showTips: show);
      notifyListeners();
    }
  }
}

void main() {
  Widget createWidgetUnderTest(AuthController authController) {
    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<AuthController>.value(
          value: authController,
          child: const ContextualTipCard(),
        ),
      ),
    );
  }

  testWidgets(
    'ContextualTipCard ne s\'affiche pas si l\'utilisateur est null',
    (WidgetTester tester) async {
      final authCtrl = FakeAuthController(initialUser: null);
      await tester.pumpWidget(createWidgetUnderTest(authCtrl));

      expect(find.byType(ContextualTipCard), findsOneWidget);
      expect(find.byIcon(Icons.lightbulb_outline), findsNothing);
    },
  );

  testWidgets('ContextualTipCard ne s\'affiche pas si showTips est false', (
    WidgetTester tester,
  ) async {
    final user = UserProfile(
      firstName: 'A',
      lastName: 'B',
      email: 'a@b.com',
      country: 'FR',
      showTips: false,
    );
    final authCtrl = FakeAuthController(initialUser: user);
    await tester.pumpWidget(createWidgetUnderTest(authCtrl));

    expect(find.byIcon(Icons.lightbulb_outline), findsNothing);
  });

  testWidgets(
    'ContextualTipCard s\'affiche si showTips est true et permet de désactiver',
    (WidgetTester tester) async {
      final user = UserProfile(
        firstName: 'A',
        lastName: 'B',
        email: 'a@b.com',
        country: 'FR',
        showTips: true,
      );
      final authCtrl = FakeAuthController(initialUser: user);
      await tester.pumpWidget(createWidgetUnderTest(authCtrl));

      expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);

      // Simuler clic sur le bouton fermer
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Le widget devrait disparaître car toggleShowTips(false) a été appelé
      expect(find.byIcon(Icons.lightbulb_outline), findsNothing);
    },
  );
}
