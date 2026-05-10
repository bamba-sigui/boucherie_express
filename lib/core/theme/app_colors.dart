import 'package:flutter/material.dart';

/// App color constants based on Stitch AI designs
class AppColors {
  AppColors._();

  // ╔══════════════════════════════════════════════════════════════════════╗
  // ║  THEME CONFIG — Modifier ce bloc pour changer de thème              ║
  // ╠══════════════════════════════════════════════════════════════════════╣
  // ║  LIGHT THEME (actif)                                                ║
  static const Color background    = Color(0xFFFFFFFF); // fond général
  static const Color surface       = Color(0xFFF5F5F5); // cartes / surfaces
  static const Color surfaceAlt    = Color(0xFFEEF2EF); // pills, chips
  static const Color textPrimary   = Color(0xFF1A1A1A); // texte principal
  static const Color textSecondary = Color(0xFF757575); // texte secondaire
  static const Color border        = Color(0xFFE0E0E0); // bordures / dividers
  // ╚══════════════════════════════════════════════════════════════════════╝
  //
  // DARK THEME (décommenter les lignes ci-dessous et commenter celles du haut) :
  //   static const Color background    = Color(0xFF0A0F0C);
  //   static const Color surface       = Color(0xFF161D19);
  //   static const Color surfaceAlt    = Color(0xFF2A2A2A);
  //   static const Color textPrimary   = Color(0xFFFFFFFF);
  //   static const Color textSecondary = Color(0xFF9E9E9E);
  //   static const Color border        = Color(0x1AFFFFFF); // white12

  // ── Aliases rétro-compatibles (0 changement dans les widgets) ──────────
  static const Color backgroundDark     = background;
  static const Color backgroundLight    = background;
  static const Color cardDark           = surface;
  static const Color categoryUnselected = surfaceAlt;
  static const Color textGrey           = textSecondary;
  static const Color textDarkGrey       = Color(0xFF616161);

  // ── Couleurs de marque (invariables) ───────────────────────────────────
  static const Color primary     = Color(0xFF38E07B);
  static const Color primaryDark = Color(0xFF2BC266);

  // Accent / Red
  static const Color accentRed = Color(0xFFC62828);
  static const Color freshRed  = Color(0xFFE63946);
  static const Color brandRed  = Color(0xFFFF4B4B);

  // Text
  static const Color textWhite = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error   = Color(0xFFEF5350);
  static const Color info    = Color(0xFF42A5F5);

  // Order Status Colors (Stitch design)
  static const Color statusOrange = Color(0xFFF59E0B);
  static const Color statusBlue   = Color(0xFF3B82F6);
  static const Color statusGreen  = Color(0xFF10B981);

  // ── Gradients ──────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Suit automatiquement le thème via les aliases
  static const LinearGradient themeGradient = LinearGradient(
    colors: [background, surface],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Kept for backward compatibility
  static const LinearGradient darkGradient = themeGradient;
}
