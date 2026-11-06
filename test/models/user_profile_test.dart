// [AI-GENERATED] Issue #5, Agent, 2025-02-23
import 'package:flutter_test/flutter_test.dart';
import 'package:le_compagnon_investissement/models/user_profile.dart';

void main() {
  group('UserProfile Tests', () {
    test('devrait sérialiser et désérialiser correctement avec les nouvelles propriétés XP', () {
      final date = DateTime(2023, 10, 15);
      final profile = UserProfile(
        firstName: 'Jean',
        lastName: 'Dupont',
        email: 'jean@test.com',
        country: 'France',
        xp: 1500,
        level: 2,
        highestLevelReached: 2,
        highestXpReached: 1500,
        highestPortfolioValueReached: 1200.0,
        streak: 5,
        lastLoginDate: date,
        showTips: false,
      );

      final json = profile.toJson();
      final decodedProfile = UserProfile.fromJson(json);

      expect(decodedProfile.firstName, 'Jean');
      expect(decodedProfile.xp, 1500);
      expect(decodedProfile.level, 2);
      expect(decodedProfile.highestPortfolioValueReached, 1200.0);
      expect(decodedProfile.streak, 5);
      expect(decodedProfile.showTips, false);
      expect(decodedProfile.lastLoginDate?.year, 2023);
    });

    test('copyWith devrait modifier uniquement les champs spécifiés', () {
      final profile = UserProfile(
        firstName: 'Jean',
        lastName: 'Dupont',
        email: 'jean@test.com',
        country: 'France',
      );

      final updated = profile.copyWith(xp: 50, streak: 1);

      expect(updated.firstName, 'Jean');
      expect(updated.xp, 50);
      expect(updated.streak, 1);
      expect(updated.level, 1); // Valeur par défaut
    });
  });
}
