// [AI-GENERATED] Setup, Agent, 2025-02-23
import 'package:flutter/material.dart';

/// Écran principal du tableau de bord.
/// 
/// Affiche la vue d'ensemble du portefeuille fictif.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Le Compagnon d\'Investissement'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.trending_up,
              size: 80,
              color: Colors.green,
            ),
            SizedBox(height: 16),
            Text(
              'Bienvenue dans votre tableau de bord.',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Gérez votre portefeuille fictif sans risque !',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
