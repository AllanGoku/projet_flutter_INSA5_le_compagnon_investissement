// [AI-GENERATED] Issue #7, Agent, 2025-02-23
import 'package:flutter_test/flutter_test.dart';
import 'package:le_compagnon_investissement/models/achievement.dart';

void main() {
  group('Achievement Model Tests', () {
    test('Création d\'un Achievement valide avec les données requises', () {
      final achievement = Achievement(
        id: 'first_step',
        title: 'Premier Pas',
        description: 'Vous avez ouvert l\'application pour la première fois.',
        iconName: 'directions_walk',
        xpReward: 50,
      );

      expect(achievement.id, 'first_step');
      expect(achievement.title, 'Premier Pas');
      expect(
        achievement.description,
        'Vous avez ouvert l\'application pour la première fois.',
      );
      expect(achievement.iconName, 'directions_walk');
      expect(achievement.xpReward, 50);
      expect(achievement.isUnlocked, isFalse);
      expect(achievement.unlockedAt, isNull);
    });

    test('Création d\'un Achievement avec date de déblocage', () {
      final date = DateTime.now();
      final achievement = Achievement(
        id: 'lynx_eye',
        title: 'L\'œil du Lynx',
        description: 'Vous avez consulté 5 actifs.',
        iconName: 'visibility',
        xpReward: 100,
        isUnlocked: true,
        unlockedAt: date,
      );

      expect(achievement.isUnlocked, isTrue);
      expect(achievement.unlockedAt, date);
    });

    test('Conversion de Achievement vers Map (JSON)', () {
      final date = DateTime(2023, 10, 10, 14, 30);
      final achievement = Achievement(
        id: 'market_linguist',
        title: 'Linguiste des marchés',
        description: 'Vous avez lu le lexique.',
        iconName: 'book',
        xpReward: 150,
        isUnlocked: true,
        unlockedAt: date,
      );

      final map = achievement.toMap();

      expect(map['id'], 'market_linguist');
      expect(map['title'], 'Linguiste des marchés');
      expect(map['description'], 'Vous avez lu le lexique.');
      expect(map['iconName'], 'book');
      expect(map['xpReward'], 150);
      expect(map['isUnlocked'], 1);
      expect(map['unlockedAt'], date.toIso8601String());
    });

    test('Création de Achievement depuis Map (JSON)', () {
      final map = {
        'id': 'dca_pioneer',
        'title': 'Pionnier du DCA',
        'description': 'Vous avez simulé un DCA.',
        'iconName': 'timeline',
        'xpReward': 200,
        'isUnlocked': 1,
        'unlockedAt': '2023-10-10T14:30:00.000',
      };

      final achievement = Achievement.fromMap(map);

      expect(achievement.id, 'dca_pioneer');
      expect(achievement.title, 'Pionnier du DCA');
      expect(achievement.description, 'Vous avez simulé un DCA.');
      expect(achievement.iconName, 'timeline');
      expect(achievement.xpReward, 200);
      expect(achievement.isUnlocked, isTrue);
      expect(achievement.unlockedAt, DateTime.parse('2023-10-10T14:30:00.000'));
    });
  });
}
