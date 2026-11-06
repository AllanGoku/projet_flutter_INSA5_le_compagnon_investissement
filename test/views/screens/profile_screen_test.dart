// [AI-GENERATED] Issue #5, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:le_compagnon_investissement/views/screens/profile_screen.dart';
import 'package:le_compagnon_investissement/controllers/auth_controller.dart';
import 'package:le_compagnon_investissement/controllers/portfolio_controller.dart';
import 'package:le_compagnon_investissement/models/user_profile.dart';
import 'package:le_compagnon_investissement/services/auth_service.dart';
import 'package:le_compagnon_investissement/services/cache_service.dart';

class FakeAuthService implements AuthService {
  @override
  Future<UserProfile?> getCurrentUser() async => null;
  @override
  Future<bool> isKeepLoggedIn() async => false;
  @override
  Future<UserProfile> login(String e, String p, bool k) async => throw Exception();
  @override
  Future<void> logout() async {}
  @override
  Future<void> register(UserProfile u, String p) async {}
  @override
  Future<void> updateUser(UserProfile u) async {}
}

class FakeAuthController extends AuthController {
  FakeAuthController({UserProfile? initialUser}) : super(authService: FakeAuthService()) {
    _user = initialUser;
  }
  
  UserProfile? _user;
  
  @override
  UserProfile? get currentUser => _user;
}

void main() {
  Widget createWidgetUnderTest(AuthController authController, PortfolioController portController) {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthController>.value(value: authController),
          ChangeNotifierProvider<PortfolioController>.value(value: portController),
        ],
        child: const ProfileScreen(),
      ),
    );
  }

  testWidgets('ProfileScreen affiche correctement les infos de l\'utilisateur et ses records', (WidgetTester tester) async {
    final user = UserProfile(
      firstName: 'Alice',
      lastName: 'Dupont',
      email: 'alice@test.com',
      country: 'France',
      xp: 2500,
      level: 3,
      highestLevelReached: 4,
      highestXpReached: 3000,
      highestPortfolioValueReached: 15000.50,
      showTips: true,
      streak: 10,
    );
    final authCtrl = FakeAuthController(initialUser: user);
    
    // Un simple PortfolioController
    final portCtrl = PortfolioController(cacheService: CacheService());

    await tester.pumpWidget(createWidgetUnderTest(authCtrl, portCtrl));
    
    // Vérification de l'affichage du nom
    expect(find.text('Alice Dupont'), findsOneWidget);
    
    // Vérification de l'affichage du titre
    expect(find.text('Novice'), findsOneWidget); // Titre pour niveau 3
    
    // Vérification des infos personnelles
    expect(find.text('alice@test.com'), findsOneWidget);
    expect(find.text('France'), findsOneWidget);
    
    // Vérification des records
    expect(find.text('4'), findsOneWidget); // Niveau max
    expect(find.text('3000'), findsOneWidget); // XP max
    
    // Le solde formaté (doit contenir 15 000 ou similaire, selon Formatters.formatCurrency)
    expect(find.textContaining('15'), findsWidgets);
    
    // Vérification de la présence des boutons
    expect(find.text('Réinitialiser le compte'), findsOneWidget);
    expect(find.text('Se déconnecter'), findsOneWidget);
  });
}
