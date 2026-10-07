// [AI-GENERATED] Phase 2, Agent, 2025-02-23
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';

/// Widget d'animation personnalisée simulant un paiement fictif par carte bancaire.
///
/// L'animation orchestre la glissade d'une carte bleue virtuelle venant se poser en "sans-contact"
/// sur un terminal TPE. Lors de l'impact visuel, un voyant vert de validation s'allume
/// sur le terminal et une pluie de confettis [Confetti.launch] vient célébrer l'achat fictif.
class PurchaseAnimation extends StatefulWidget {
  final String assetSymbol;
  final double quantity;
  final VoidCallback onCompleted;

  const PurchaseAnimation({
    super.key,
    required this.assetSymbol,
    required this.quantity,
    required this.onCompleted,
  });

  @override
  State<PurchaseAnimation> createState() => _PurchaseAnimationState();
}

class _PurchaseAnimationState extends State<PurchaseAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  bool _isContactlessDone = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Glissement de la carte du haut vers le terminal TPE
    _slideAnimation = Tween<double>(begin: -150.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.bounceOut),
      ),
    );

    // Légère pulsation lors du contact sans-contact
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _isContactlessDone = true;
          });
          // Déclenchement de la pluie de confettis
          try {
            const options = ConfettiOptions(
              spread: 360,
              ticks: 250,
              gravity: 0.4,
              decay: 0.94,
              startVelocity: 15,
              y: -0.1,
              x: 0.5,
            );

            void shoot() {
              if (!mounted) return;
              
              Confetti.launch(context,
                  options: options.copyWith(
                    particleCount: 20,
                  ),
                  particleBuilder: (index) => Emoji(
                      emoji: '💶',
                      textStyle:
                          GoogleFonts.notoColorEmoji()));
              Confetti.launch(context,
                  options: options.copyWith(
                    particleCount: 15,
                  ),
                  particleBuilder: (index) => Emoji(
                        emoji: '💵',
                        textStyle:
                            GoogleFonts.notoColorEmoji(),
                      ));
              Confetti.launch(context,
                  options: options.copyWith(
                    particleCount: 15,
                  ),
                  particleBuilder: (index) => Emoji(
                        emoji: '💴',
                        textStyle:
                            GoogleFonts.notoColorEmoji(),
                      ));
              Confetti.launch(context,
                  options: options.copyWith(
                    particleCount: 15,
                  ),
                  particleBuilder: (index) => Emoji(
                        emoji: '💷',
                        textStyle:
                            GoogleFonts.notoColorEmoji(),
                      ));
            }

            Timer(Duration.zero, shoot);
            Timer(const Duration(milliseconds: 200), shoot);
            Timer(const Duration(milliseconds: 400), shoot);
          } catch (e) {
            debugPrint("Erreur lors du lancement des confettis: $e");
          }
        }
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Text(
            _isContactlessDone ? 'Achat Fictif Confirmé !' : 'Paiement en cours...',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${widget.quantity.toStringAsFixed(2)} x ${widget.assetSymbol}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 30),

          // Zone d'animation : Terminal TPE + Carte Bleue virtuelle
          SizedBox(
            height: 220,
            width: double.infinity,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Terminal TPE (base fixe)
                    Positioned(
                      bottom: 10,
                      child: Container(
                        width: 200,
                        height: 130,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Écran du terminal TPE
                            Container(
                              width: 160,
                              height: 50,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: _isContactlessDone ? Colors.green.shade900 : Colors.black,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _isContactlessDone ? AppTheme.gainColor : Colors.grey.shade800,
                                ),
                              ),
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: _isContactlessDone
                                      ? Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: const [
                                            Icon(
                                              Icons.check_circle_rounded,
                                              color: AppTheme.gainColor,
                                              size: 20,
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              'ACCEPTE',
                                              style: TextStyle(
                                                color: AppTheme.gainColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: const [
                                            Icon(
                                              Icons.contactless_rounded,
                                              color: AppTheme.azure,
                                              size: 20,
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              'SANS CONTACT',
                                              style: TextStyle(
                                                color: AppTheme.azure,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Clavier TPE stylisé
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                3,
                                (index) => Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: 24,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade800,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Carte bleue virtuelle animée
                    Positioned(
                      top: 10 + _slideAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: 170,
                          height: 95,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: const [
                                  Icon(Icons.nfc_rounded, color: Colors.white, size: 18),
                                  Text(
                                    'COMPAGNON',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 22,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade300,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '•••• 4242',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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
          ),
          const SizedBox(height: 20),

          // Bouton de fermeture / poursuite
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isContactlessDone ? widget.onCompleted : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                _isContactlessDone ? 'Voir mon Portefeuille' : 'Validation...',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
