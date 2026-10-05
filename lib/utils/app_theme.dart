// [AI-GENERATED] Setup, Agent, 2025-02-23
import 'package:flutter/material.dart';

/// Thème global de l'application (Material 3).
///
/// Fournit les couleurs, la typographie et les styles par défaut pour
/// garantir une interface cohérente et moderne pour l'application éducative.
class AppTheme {
  /// Couleurs principales pour le mode clair.
  static const Color primaryColor = Color(0xFF2E7D32); // Vert sombre apaisant
  static const Color secondaryColor = Color(0xFF1565C0); // Bleu éducatif
  static const Color backgroundColor = Color(0xFFF5F5F5); // Fond gris très clair
  static const Color surfaceColor = Colors.white; // Cartes blanches
  
  static const Color gainColor = Color(0xFF4CAF50); // Vert pour les gains
  static const Color lossColor = Color(0xFFF44336); // Rouge pour les pertes

  /// Thème clair global.
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        surfaceTint: backgroundColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.black87),
        bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
      ),
    );
  }
}
