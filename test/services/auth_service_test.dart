// [AI-GENERATED] Issue #1, Agent, 2025-02-23

import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:le_compagnon_investissement/services/auth_service.dart';
import 'package:le_compagnon_investissement/models/user_profile.dart';

void main() {
  group('AuthService', () {
    late AuthService authService;

    setUp(() {
      SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
      FlutterSecureStorage.setMockInitialValues({});
      authService = AuthService();
    });

    test('Register saves user profile and password', () async {
      final user = UserProfile(
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        country: 'France',
      );

      await authService.register(user, 'password123');

      final storedUser = await authService.getCurrentUser();
      expect(storedUser, isNotNull);
      expect(storedUser!.email, 'john.doe@example.com');
    });

    test('Login succeeds with correct credentials', () async {
      final user = UserProfile(
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        country: 'France',
      );

      await authService.register(user, 'password123');
      
      final loggedUser = await authService.login('john.doe@example.com', 'password123', true);
      expect(loggedUser.firstName, 'John');
      
      final keepLoggedIn = await authService.isKeepLoggedIn();
      expect(keepLoggedIn, isTrue);
    });

    test('Login fails with incorrect password', () async {
      final user = UserProfile(
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        country: 'France',
      );

      await authService.register(user, 'password123');

      expect(
        () => authService.login('john.doe@example.com', 'wrongpassword', true),
        throwsException,
      );
    });

    test('Logout clears keepLoggedIn flag', () async {
      final user = UserProfile(
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        country: 'France',
      );

      await authService.register(user, 'password123');
      await authService.login('john.doe@example.com', 'password123', true);
      
      await authService.logout();
      final keepLoggedIn = await authService.isKeepLoggedIn();
      expect(keepLoggedIn, isFalse);
    });
  });
}
