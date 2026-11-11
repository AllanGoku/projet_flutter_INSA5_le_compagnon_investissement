// [AI-GENERATED] Issue #0, Agent, 2025-02-23
import 'package:flutter/material.dart';

import '../../utils/app_theme.dart';

/// Widget de carte avec un style Soft UI / Glassmorphism.
///
/// Utilisé pour afficher des éléments de contenu avec des bords très arrondis,
/// un fond blanc, et une ombre douce et diffuse afin d'obtenir un effet
/// d'élévation léger sans être agressif visuellement.
class SoftCard extends StatelessWidget {
  /// Le widget enfant contenu dans la carte.
  final Widget child;

  /// Marges internes de la carte.
  final EdgeInsetsGeometry padding;

  /// Marges externes de la carte.
  final EdgeInsetsGeometry margin;

  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}
