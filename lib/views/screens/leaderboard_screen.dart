// [AI-GENERATED] Issue #7, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/gamification_controller.dart';
import '../../controllers/portfolio_controller.dart';
import '../../models/leaderboard_entry.dart';
import '../../utils/formatters.dart';

/// Écran affichant le tableau de classement simulé avec filtre par critère.
/// Comprend la liste des investisseurs (PNJ) et la position du joueur.
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  LeaderboardSortCriteria _sortBy = LeaderboardSortCriteria.xp;

  String _formatMetric(LeaderboardEntry entry) {
    switch (_sortBy) {
      case LeaderboardSortCriteria.xp:
        return '${entry.xp} XP';
      case LeaderboardSortCriteria.portfolioValue:
        return Formatters.formatCurrency(entry.portfolioValue);
      case LeaderboardSortCriteria.performance:
        final prefix = entry.performancePercentage > 0 ? '+' : '';
        return '$prefix${entry.performancePercentage.toStringAsFixed(1)} %';
    }
  }

  Widget _buildTopThreePodium(
    BuildContext context,
    List<LeaderboardEntry> topThree,
  ) {
    if (topThree.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (topThree.length >= 2)
            _buildPodiumColumn(context, topThree[1], 2, 90, Colors.grey[400]!),
          if (topThree.isNotEmpty)
            _buildPodiumColumn(context, topThree[0], 1, 130, Colors.amber),
          if (topThree.length >= 3)
            _buildPodiumColumn(
              context,
              topThree[2],
              3,
              75,
              Colors.orange[300]!,
            ),
        ],
      ),
    );
  }

  Widget _buildPodiumColumn(
    BuildContext context,
    LeaderboardEntry entry,
    int rank,
    double height,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CircleAvatar(
          radius: rank == 1 ? 32 : 24,
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            entry.avatarInitials,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: rank == 1 ? 22 : 15,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          entry.name,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          _formatMetric(entry),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: rank == 1 ? 75 : 55,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Center(
            child: Text(
              '$rank',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final gamificationController = context.watch<GamificationController>();
    final portfolioController = context.watch<PortfolioController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Classement')),
      body: FutureBuilder<List<LeaderboardEntry>>(
        future: gamificationController.getLeaderboard(
          portfolioController.totalValue,
          portfolioController.totalPerformance,
          sortBy: _sortBy,
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final leaderboard = snapshot.data!;
          final topThree = leaderboard.take(3).toList();
          final others = leaderboard.skip(3).toList();

          final currentUserEntry = leaderboard.firstWhere(
            (e) => e.isCurrentUser,
            orElse: () => leaderboard.first,
          );

          return Column(
            children: [
              const SizedBox(height: 12),
              // Filtre des critères
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SegmentedButton<LeaderboardSortCriteria>(
                  segments: const [
                    ButtonSegment(
                      value: LeaderboardSortCriteria.xp,
                      label: Text('XP'),
                      icon: Icon(Icons.bolt, size: 16),
                    ),
                    ButtonSegment(
                      value: LeaderboardSortCriteria.portfolioValue,
                      label: Text('Portefeuille'),
                      icon: Icon(Icons.account_balance_wallet, size: 16),
                    ),
                    ButtonSegment(
                      value: LeaderboardSortCriteria.performance,
                      label: Text('Perf %'),
                      icon: Icon(Icons.trending_up, size: 16),
                    ),
                  ],
                  selected: {_sortBy},
                  onSelectionChanged: (newSelection) {
                    setState(() {
                      _sortBy = newSelection.first;
                    });
                  },
                ),
              ),
              _buildTopThreePodium(context, topThree),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: others.length,
                  itemBuilder: (context, index) {
                    final entry = others[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: entry.isCurrentUser
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[200],
                        child: Text(
                          entry.avatarInitials,
                          style: TextStyle(
                            color: entry.isCurrentUser
                                ? Colors.white
                                : Colors.grey[800],
                          ),
                        ),
                      ),
                      title: Text(
                        entry.name,
                        style: TextStyle(
                          fontWeight: entry.isCurrentUser
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        'Niveau ${entry.level} • ${_formatMetric(entry)}',
                      ),
                      trailing: Text(
                        '#${entry.rank}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[500],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      tileColor: entry.isCurrentUser
                          ? Theme.of(context).colorScheme.primaryContainer
                                .withOpacity(0.3)
                          : null,
                    );
                  },
                ),
              ),
              // Carte épinglée de l'utilisateur respectant la zone de sécurité (SafeArea)
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primary,
                          child: Text(
                            currentUserEntry.avatarInitials,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                currentUserEntry.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Niveau ${currentUserEntry.level} • ${_formatMetric(currentUserEntry)}',
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '#${currentUserEntry.rank}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
