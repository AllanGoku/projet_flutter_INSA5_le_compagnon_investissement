// [AI-GENERATED] Issue #5, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import 'dart:math';

/// Widget affichant un conseil pédagogique contextuel et dynamique.
///
/// Si l'utilisateur a désactivé les conseils (`showTips` == false), il retourne
/// un conteneur vide pour ne rien afficher.
class ContextualTipCard extends StatefulWidget {
  const ContextualTipCard({super.key});

  @override
  State<ContextualTipCard> createState() => _ContextualTipCardState();
}

class _ContextualTipCardState extends State<ContextualTipCard> {
  late String _currentTip;

  static const List<String> _tips = [
    "Saviez-vous qu'un portefeuille diversifié permet de lisser les risques ?",
    "Investir régulièrement (DCA) est souvent plus efficace que d'essayer de timer le marché.",
    "Vos liquidités ne rapportent rien. Pensez à les investir intelligemment !",
    "La volatilité est normale. Ne paniquez pas lors d'une baisse temporaire.",
    "La patience est la clé. L'intérêt composé travaille avec le temps.",
    "Revendre avec plus-value rapporte plus d'XP si vous gardez l'actif longtemps."
  ];

  @override
  void initState() {
    super.initState();
    _currentTip = _tips[Random().nextInt(_tips.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, auth, child) {
        if (auth.currentUser == null || !auth.currentUser!.showTips) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.shade200, width: 1.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lightbulb_outline, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _currentTip,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  auth.toggleShowTips(false);
                },
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Icons.close, size: 20, color: Colors.blue),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
