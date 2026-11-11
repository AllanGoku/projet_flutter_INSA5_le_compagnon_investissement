// [AI-GENERATED] Issue #7, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:flutter_confetti/flutter_confetti.dart';

import '../../models/achievement.dart';

/// Modale affichée lors du déblocage d'un nouveau succès.
/// Utilise le package `flutter_confetti` pour animer des confettis en surimpression.
class AchievementUnlockDialog extends StatefulWidget {
  final Achievement achievement;

  const AchievementUnlockDialog({Key? key, required this.achievement})
    : super(key: key);

  static void show(BuildContext context, Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => AchievementUnlockDialog(achievement: achievement),
    );
  }

  @override
  State<AchievementUnlockDialog> createState() =>
      _AchievementUnlockDialogState();
}

class _AchievementUnlockDialogState extends State<AchievementUnlockDialog> {
  @override
  void initState() {
    super.initState();
    // Lance les confettis juste après l'affichage du dialogue
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Confetti.launch(
        context,
        options: const ConfettiOptions(particleCount: 100, spread: 70, y: 0.6),
      );
    });
  }

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
      default:
        return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.amber.withOpacity(0.2),
            child: Icon(
              _getIconData(widget.achievement.iconName),
              size: 40,
              color: Colors.amber[800],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Succès Débloqué !',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.achievement.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            widget.achievement.description,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '+${widget.achievement.xpReward} XP',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.amber[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Génial !'),
        ),
      ],
      actionsAlignment: MainAxisAlignment.center,
    );
  }
}
