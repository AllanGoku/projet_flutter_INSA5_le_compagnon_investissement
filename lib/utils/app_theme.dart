// [AI-GENERATED] Issue #0, Agent, 2025-02-23
import 'package:flutter/material.dart';

/// Thème global de l'application (Material 3).
///
/// Fournit les couleurs, la typographie et les styles par défaut pour
/// garantir une interface cohérente et moderne pour l'application éducative.
class AppTheme {
  /// Couleurs principales pour le mode clair.
  static const Color primaryColor = Color(0xFF2E7D32); // Vert sombre apaisant
  static const Color secondaryColor = Color(0xFF1565C0); // Bleu éducatif
  
  // Design Soft UI
  static const Color backgroundColor = Color(0xFFF8F9FA); // Fond global Soft UI
  static const Color surfaceColor = Color(0xFFFFFFFF); // Cartes blanches
  
  // Performance Colors
  static const Color gainColor = Color(0xFF10B981); // Vert pour les gains
  static const Color lossColor = Color(0xFFEF4444); // Rouge pour les pertes

  // Gradient Colors
  static const Color mint = Color(0xFF34D399); // Vert menthe
  static const Color azure = Color(0xFF38BDF8); // Bleu azur

  /// Dégradé principal de l'application
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [mint, azure],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Thème clair global.
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: mint,
        primary: mint,
        secondary: azure,
        surface: surfaceColor,
        surfaceTint: backgroundColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
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
