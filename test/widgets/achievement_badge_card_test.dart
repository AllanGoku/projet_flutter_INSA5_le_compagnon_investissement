// [AI-GENERATED] Issue #7, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_compagnon_investissement/models/achievement.dart';
import 'package:le_compagnon_investissement/views/widgets/achievement_badge_card.dart';

void main() {
  group('AchievementBadgeCard Widget Tests', () {
    testWidgets('Affiche un badge verrouillé avec cadenas et texte lisible', (
      WidgetTester tester,
    ) async {
      final achievement = Achievement(
        id: 'test',
        title: 'Badge Test',
        description: 'Test description',
        iconName: 'star',
        xpReward: 100,
        isUnlocked: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AchievementBadgeCard(achievement: achievement)),
        ),
      );

      expect(find.text('Badge Test'), findsOneWidget);
      expect(find.text('+100 XP'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('Affiche un badge débloqué avec coche verte', (
      WidgetTester tester,
    ) async {
      final achievement = Achievement(
        id: 'test_unlocked',
        title: 'Badge Débloqué',
        description: 'Test desc',
        iconName: 'star',
        xpReward: 200,
        isUnlocked: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AchievementBadgeCard(achievement: achievement)),
        ),
      );

      expect(find.text('Badge Débloqué'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });
}
