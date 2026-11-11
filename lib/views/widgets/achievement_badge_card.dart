// [AI-GENERATED] Issue #7, Agent, 2025-02-23
import 'package:flutter/material.dart';

import '../../models/achievement.dart';

/// Composant affichant un succès (badge) sous forme de carte.
/// Utilise une opacité réduite et l'absence de couleur si le badge n'est pas encore débloqué.
class AchievementBadgeCard extends StatelessWidget {
  final Achievement achievement;

  const AchievementBadgeCard({Key? key, required this.achievement})
    : super(key: key);

  IconData _getIconData(String name) {
    switch (name) {
      case 'directions_walk':
        return Icons.directions_walk;
      case 'visibility':
        return Icons.visibility;
      case 'menu_book':
        return Icons.menu_book;
      case 'timeline':
        return Icons.timeline;
      case 'pie_chart':
        return Icons.pie_chart;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'trending_up':
        return Icons.trending_up;
      case 'hourglass_bottom':
        return Icons.hourglass_bottom;
      case 'star':
        return Icons.star;
      default:
        return Icons.star_border;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool unlocked = achievement.isUnlocked;

    return Card(
      elevation: unlocked ? 4 : 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: unlocked
          ? theme.colorScheme.surface
          : theme.disabledColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: unlocked
                  ? theme.colorScheme.primaryContainer
                  : Colors.grey[200],
              child: Icon(
                _getIconData(achievement.iconName),
                size: 32,
                color: unlocked ? theme.colorScheme.primary : Colors.grey[500],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: unlocked
                          ? theme.colorScheme.onSurface
                          : Colors.grey[800], // Plus sombre
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: unlocked
                          ? theme.colorScheme.onSurfaceVariant
                          : Colors.grey[700], // Plus sombre
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: unlocked
                          ? Colors.amber.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '+${achievement.xpReward} XP',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: unlocked ? Colors.amber[800] : Colors.grey[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (unlocked)
              const Icon(Icons.check_circle, color: Colors.green, size: 28),
            if (!unlocked)
              Icon(Icons.lock_outline, color: Colors.grey[400], size: 24),
          ],
        ),
      ),
    );
  }
}
