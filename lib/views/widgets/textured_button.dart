// [AI-GENERATED] Issue #0, Agent, 2025-02-23
import 'package:flutter/material.dart';

import '../../utils/app_theme.dart';

/// Variantes de style pour les boutons.
enum ButtonVariant {
  /// Bouton d'action principal (Gris très foncé, inspiré du mockup).
  dark,

  /// Bouton avec le dégradé de la marque (Menthe vers Azur).
  gradient,

  /// Bouton avec fond blanc et texte azur.
  light,
}

/// Bouton d'action principal réutilisable inspiré de la maquette HTML.
///
/// Dispose de plusieurs variantes (dark, gradient, light) pour s'adapter
/// aux différents contextes (formulaires, actions secondaires, etc.).
class TexturedButton extends StatefulWidget {
  /// L'action à déclencher lors du clic.
  final VoidCallback onPressed;

  /// Le texte affiché dans le bouton.
  final String label;

  /// Un widget icône optionnel à afficher avant le texte.
  final Widget? icon;

  /// La variante de couleur/style du bouton.
  final ButtonVariant variant;

  /// Si vrai, le bouton prendra toute la largeur disponible.
  final bool fullWidth;

  const TexturedButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.variant = ButtonVariant.dark,
    this.fullWidth = false,
  });

  @override
  State<TexturedButton> createState() => _TexturedButtonState();
}

class _TexturedButtonState extends State<TexturedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    // Animation simulant le "active:scale-95" de Tailwind
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
    widget.onPressed();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    // Détermination des styles en fonction de la variante
    BoxDecoration decoration;
    Color textColor;

    switch (widget.variant) {
      case ButtonVariant.dark:
        decoration = BoxDecoration(
          color: const Color(0xFF111827), // bg-gray-900
          borderRadius: BorderRadius.circular(16.0), // rounded-2xl
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF111827)
                  .withOpacity(0.2), // shadow-gray-900/20
              blurRadius: 15,
              offset: const Offset(0, 10), // shadow-lg
            ),
          ],
        );
        textColor = Colors.white;
        break;
      case ButtonVariant.gradient:
        decoration = BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: AppTheme.mint.withOpacity(0.4), // shadow-mint/40
              blurRadius: 15,
              offset: const Offset(0, 10),
            ),
          ],
        );
        textColor = Colors.white;
        break;
      case ButtonVariant.light:
        decoration = BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0), // rounded-xl
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), // shadow-md leger
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        );
        textColor = AppTheme.azure;
        break;
    }

    final Widget buttonContent = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.variant == ButtonVariant.light ? 16.0 : 24.0,
        vertical: widget.variant == ButtonVariant.light ? 12.0 : 16.0,
      ),
      child: Row(
        mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[
            widget.icon!,
            const SizedBox(width: 8.0),
          ],
          Text(
            widget.label,
            style: TextStyle(
              color: textColor,
              fontSize: widget.variant == ButtonVariant.light
                  ? 14.0
                  : 18.0, // text-sm ou text-lg
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: Container(
          width: widget.fullWidth ? double.infinity : null,
          decoration: decoration,
          child: buttonContent,
        ),
      ),
    );
  }
}
