// [AI-GENERATED] Issue #7, Agent, 2025-02-23
import 'package:flutter_test/flutter_test.dart';
import 'package:le_compagnon_investissement/models/financial_calculator.dart';
import 'package:le_compagnon_investissement/models/achievement.dart';

void main() {
  group('FinancialCalculator - Gamification Phase 7', () {
    test('Génération du classement déterministe avec l\'utilisateur', () {
      final entries = FinancialCalculator.generateMockLeaderboardEntries(
        userXp: 9000,
        userPortfolioValue: 45000.0,
        userPerformancePercentage: 10.0,
      );

      expect(entries, isNotEmpty);
      expect(entries.length, greaterThan(1));

      final currentUserEntry = entries.firstWhere((e) => e.isCurrentUser);
      expect(currentUserEntry.name, 'Vous');
      expect(currentUserEntry.xp, 9000);

      // L'utilisateur (9000 XP) devrait être devant Peter L. (8500 XP) mais derrière Charlie M. (12000 XP)
      expect(currentUserEntry.rank, 3);

      // Vérifier le tri (le rang 1 a le plus d'XP)
      expect(entries[0].xp, greaterThanOrEqualTo(entries[1].xp));
    });

    test('Vérification pure du déblocage des succès (Lynx Eye)', () {
      final achievements = [
        Achievement(
          id: 'lynx_eye',
          title: 'Lynx',
          description: 'desc',
          iconName: 'icon',
          xpReward: 100,
        ),
      ];

      final newlyUnlocked = FinancialCalculator.checkAchievementUnlock(
        achievements: achievements,
        userXp: 0,
        portfolioValue: 0.0,
        totalInvested: 0.0,
        assetCount: 5, // 5 actifs remplissent la condition
        hasSimulatedDCA: false,
        readLexicon: false,
      );

      expect(newlyUnlocked, contains('lynx_eye'));
    });

    test('Vérification pure du déblocage des succès (Pionnier DCA)', () {
      final achievements = [
        Achievement(
          id: 'dca_pioneer',
          title: 'DCA',
          description: 'desc',
          iconName: 'icon',
          xpReward: 200,
        ),
      ];

      final newlyUnlocked = FinancialCalculator.checkAchievementUnlock(
        achievements: achievements,
        userXp: 0,
        portfolioValue: 0.0,
        totalInvested: 0.0,
        assetCount: 0,
        hasSimulatedDCA: true,
        readLexicon: false,
      );

      expect(newlyUnlocked, contains('dca_pioneer'));
    });

    test('Succès déjà débloqué est ignoré', () {
      final achievements = [
        Achievement(
          id: 'first_step',
          title: 'Step',
          description: 'desc',
          iconName: 'icon',
          xpReward: 50,
          isUnlocked: true,
        ),
      ];

      final newlyUnlocked = FinancialCalculator.checkAchievementUnlock(
        achievements: achievements,
        userXp: 0,
        portfolioValue: 0.0,
        totalInvested: 0.0,
        assetCount: 0,
        hasSimulatedDCA: false,
        readLexicon: false,
      );

      expect(newlyUnlocked, isEmpty);
    });
  });
}
