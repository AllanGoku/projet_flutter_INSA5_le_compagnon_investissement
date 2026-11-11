// [AI-GENERATED] Issue #5, Agent, 2025-02-23
import 'package:flutter_test/flutter_test.dart';
import 'package:le_compagnon_investissement/controllers/auth_controller.dart';
import 'package:le_compagnon_investissement/models/user_profile.dart';
import 'package:le_compagnon_investissement/services/auth_service.dart';

// Un mock simple pour AuthService afin d'éviter la persistance réelle
class MockAuthService implements AuthService {
  UserProfile? _user;
  bool _keep = false;

  @override
  Future<List<UserProfile>> getAllUsers() async =>
      _user != null ? [_user!] : [];

  @override
  Future<void> register(UserProfile user, String password) async {
    _user = user;
  }

  @override
  Future<UserProfile> login(
    String email,
    String password,
    bool keepLoggedIn,
  ) async {
    if (_user != null && _user!.email == email) {
      _keep = keepLoggedIn;
      return _user!;
    }
    throw Exception('Login failed');
  }

  @override
  Future<void> updateUser(UserProfile user) async {
    _user = user;
  }

  @override
  Future<void> logout() async {
    _keep = false;
  }

  @override
  Future<bool> isKeepLoggedIn() async => _keep;

  @override
  Future<UserProfile?> getCurrentUser() async => _user;
}

void main() {
  group('AuthController Tests', () {
    late AuthController authController;
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
      authController = AuthController(authService: mockAuthService);
    });

    test('register et login initiaux', () async {
      final user = UserProfile(
        firstName: 'John',
        lastName: 'Doe',
        email: 'john@doe.com',
        country: 'FR',
      );
      final success = await authController.register(user, 'password');
      expect(success, isTrue);
      expect(authController.currentUser?.email, 'john@doe.com');
      // La première connexion met le streak à 1
      expect(authController.currentUser?.streak, 1);
    });

    test('addXp met à jour l\'expérience et le niveau', () async {
      final user = UserProfile(
        firstName: 'John',
        lastName: 'Doe',
        email: 'john@doe.com',
        country: 'FR',
        xp: 0,
        level: 1,
      );
      await authController.register(user, 'password');

      // ajout 1500 XP => passe niveau 2
      await authController.addXp(1500);

      expect(
        authController.currentUser?.xp,
        1500 + 20,
      ); // +20 from login streak at register/login
      expect(authController.currentUser?.level, 2);
      expect(authController.currentUser?.highestXpReached, 1520);
      expect(authController.currentUser?.highestLevelReached, 2);
    });

    test(
      'updateHighestPortfolioValue met à jour si la valeur est plus élevée',
      () async {
        final user = UserProfile(
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@doe.com',
          country: 'FR',
        );
        await authController.register(user, 'password');

        await authController.updateHighestPortfolioValue(1000.0);
        expect(
          authController.currentUser?.highestPortfolioValueReached,
          1000.0,
        );

        // Valeur plus faible, ne doit pas changer
        await authController.updateHighestPortfolioValue(500.0);
        expect(
          authController.currentUser?.highestPortfolioValueReached,
          1000.0,
        );

        // Valeur plus élevée, doit changer
        await authController.updateHighestPortfolioValue(1500.0);
        expect(
          authController.currentUser?.highestPortfolioValueReached,
          1500.0,
        );
      },
    );

    test('resetAccount réinitialise l\'XP mais garde les records', () async {
      final user = UserProfile(
        firstName: 'John',
        lastName: 'Doe',
        email: 'john@doe.com',
        country: 'FR',
      );
      await authController.register(user, 'password');

      await authController.addXp(2000);
      await authController.updateHighestPortfolioValue(3000.0);

      // Verification avant reset
      expect(authController.currentUser?.level, 3);
      expect(authController.currentUser?.highestLevelReached, 3);

      // Action reset
      await authController.resetAccount();

      // Verification après reset
      expect(authController.currentUser?.xp, 0);
      expect(authController.currentUser?.level, 1);
      expect(authController.currentUser?.highestLevelReached, 3);
      expect(authController.currentUser?.highestPortfolioValueReached, 3000.0);
    });
  });
}
