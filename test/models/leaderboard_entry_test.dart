// [AI-GENERATED] Issue #7, Agent, 2025-02-23
import 'package:flutter_test/flutter_test.dart';
import 'package:le_compagnon_investissement/models/leaderboard_entry.dart';

void main() {
  group('LeaderboardEntry Model Tests', () {
    test(
      'Création d\'un LeaderboardEntry valide avec les données requises',
      () {
        final entry = LeaderboardEntry(
          rank: 1,
          name: 'Warren B.',
          avatarInitials: 'WB',
          level: 42,
          xp: 15000,
          portfolioValue: 100000.0,
          performancePercentage: 15.5,
          isCurrentUser: false,
        );

        expect(entry.rank, 1);
        expect(entry.name, 'Warren B.');
        expect(entry.avatarInitials, 'WB');
        expect(entry.level, 42);
        expect(entry.xp, 15000);
        expect(entry.portfolioValue, 100000.0);
        expect(entry.performancePercentage, 15.5);
        expect(entry.isCurrentUser, isFalse);
      },
    );

    test('Vérification de isCurrentUser à vrai', () {
      final entry = LeaderboardEntry(
        rank: 5,
        name: 'Moi',
        avatarInitials: 'ME',
        level: 10,
        xp: 2500,
        portfolioValue: 5000.0,
        performancePercentage: 2.1,
        isCurrentUser: true,
      );

      expect(entry.isCurrentUser, isTrue);
    });
  });
}
