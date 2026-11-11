// [AI-GENERATED] Issue #7, Agent, 2025-02-23
import 'package:flutter_test/flutter_test.dart';
import 'package:le_compagnon_investissement/controllers/gamification_controller.dart';
import 'package:le_compagnon_investissement/services/cache_service.dart';
import 'package:le_compagnon_investissement/models/achievement.dart';
import 'package:sqflite/sqflite.dart';
// ignore: implementation_imports
import 'package:sqflite_common/src/mixin/factory.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';

void main() {
  group('GamificationController Tests', () {
    late CacheService cacheService;
    late GamificationController controller;

    setUp(() async {
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

      cacheService = CacheService();
      await cacheService.initDB(inMemory: true);
      controller = GamificationController(cacheService);
      await controller.loadData();
    });

    tearDown(() async {
      await cacheService.close();
    });

    test('Initialisation correcte des données', () async {
      expect(controller.userXp, 0);
      expect(controller.level, 1);
      expect(controller.achievements, isNotEmpty);
      expect(controller.newlyUnlockedQueue, isEmpty);
    });

    test('Ajout d\'XP met à jour le niveau et notifie', () async {
      await controller.awardXp(1200); // Devrait passer niveau 2

      expect(controller.userXp, 1250); // 1200 + 50 (first_step)
      expect(controller.level, 2);
    });

    test('Vérification et déblocage de succès (DCA Pioneer)', () async {
      await controller.checkAchievements(
        portfolioValue: 0.0,
        totalInvested: 0.0,
        assetCount: 0,
        hasSimulatedDCA: true,
        readLexicon: false,
      );

      final unlocked = controller.achievements.firstWhere(
        (a) => a.id == 'dca_pioneer',
      );
      expect(unlocked.isUnlocked, isTrue);

      // Le succès doit être dans la file d'attente pour l'UI
      expect(
        controller.newlyUnlockedQueue.any((a) => a.id == 'dca_pioneer'),
        isTrue,
      );

      // L'XP de récompense doit avoir été ajouté (200 XP + 50 XP pour first_step si pas déjà débloqué)
      expect(controller.userXp, 250);

      // On vide la file d'attente
      controller.clearNewlyUnlockedQueue();
      expect(controller.newlyUnlockedQueue, isEmpty);
    });
  });
}
