// [AI-GENERATED] Issue #7, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:le_compagnon_investissement/views/screens/leaderboard_screen.dart';
import 'package:le_compagnon_investissement/controllers/gamification_controller.dart';
import 'package:le_compagnon_investissement/controllers/portfolio_controller.dart';
import 'package:le_compagnon_investissement/services/cache_service.dart';
import 'package:sqflite/sqflite.dart';
// ignore: implementation_imports
import 'package:sqflite_common/src/mixin/factory.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';

void main() {
  testWidgets(
    'LeaderboardScreen affiche le classement et la carte utilisateur épinglée',
    (WidgetTester tester) async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
      databaseFactory = buildDatabaseFactory(
        invokeMethod: (String method, [Object? arguments]) async {
          if (method == 'openDatabase') return <String, dynamic>{'id': 1};
          if (method == 'execute') return null;
          if (method == 'insert') return 1;
          if (method == 'query') return <Map<String, dynamic>>[];
          if (method == 'delete') return 1;
          if (method == 'closeDatabase') return null;
          return null;
        },
      );

      final cacheService = CacheService();
      await cacheService.initDB(inMemory: true);

      final gamificationController = GamificationController(cacheService);
      await gamificationController.loadData();

      final portfolioController = PortfolioController(
        cacheService: cacheService,
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<GamificationController>.value(
              value: gamificationController,
            ),
            ChangeNotifierProvider<PortfolioController>.value(
              value: portfolioController,
            ),
          ],
          child: const MaterialApp(home: LeaderboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Vérifie la présence du titre
      expect(find.text('Classement'), findsOneWidget);

      // Au moins un avatar PNJ (ex: Warren B. -> WB)
      expect(find.text('WB'), findsWidgets);

      // L'utilisateur est affiché
      expect(find.text('Vous'), findsWidgets);
    },
  );
}
