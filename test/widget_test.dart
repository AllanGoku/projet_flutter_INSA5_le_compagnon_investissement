// [AI-GENERATED] Setup, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:le_compagnon_investissement/main.dart';
import 'package:le_compagnon_investissement/controllers/auth_controller.dart';
import 'package:le_compagnon_investissement/views/screens/login_screen.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets('Smoke test: App starts with LoginScreen by default', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthController()),
        ],
        child: const MyApp(),
      ),
    );

    // Initial state is the loading spinner (CircularProgressIndicator)
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Pump to let the _checkAuth complete
    await tester.pumpAndSettle();

    // Verify that the login screen is shown because no user is saved in mocks.
    expect(find.byType(LoginScreen), findsOneWidget);
    
    // Verify that the title is present
    expect(find.text('Connexion'), findsWidgets);
  });
}
