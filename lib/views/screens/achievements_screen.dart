// [AI-GENERATED] Issue #7, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/gamification_controller.dart';
import '../widgets/achievement_badge_card.dart';

/// Écran récapitulatif des succès (badges).
/// Affiche la liste des succès débloqués et ceux qui restent à accomplir.
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gamificationController = context.watch<GamificationController>();
    final achievements = gamificationController.achievements;

    final unlockedCount = achievements.where((a) => a.isUnlocked).length;
    final totalCount = achievements.length;
    final progress = totalCount > 0 ? unlockedCount / totalCount : 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Mes Succès')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24.0),
            color: Theme.of(context).colorScheme.primaryContainer
                .withOpacity(0.3),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progression Globale',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$unlockedCount / $totalCount',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Continuez d\'explorer pour débloquer de nouveaux badges et accumuler de l\'XP !',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: achievements.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                return AchievementBadgeCard(achievement: achievement);
              },
            ),
          ),
        ],
      ),
    );
  }
}
