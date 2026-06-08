import 'package:flutter/material.dart';
import 'app_theme_extension.dart';

class AppColors {
  // ─── Brand Palette (iOS 26 Indigo-Violet) ────────────────
  static const Color primary = Color(0xFF6366F1);       // Indigo 500 — VisionOS accent
  static const Color primaryLight = Color(0xFF818CF8);   // Indigo 400
  static const Color primaryDark = Color(0xFF818CF8);    // Bright indigo for dark mode
  static const Color secondary = Color(0xFFF59E0B);      // Amber 500 — warm accent
  static const Color accent = Color(0xFF06B6D4);         // Cyan 500 — cool complement

  // ─── Light Theme (iOS 26 System Colors) ─────────────────
  static const Color background = Color(0xFFF2F2F7);    // iOS System Gray 6
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1C1C1E);   // iOS Label
  static const Color textSecondary = Color(0xFF8E8E93); // iOS Secondary Label
  static const Color textHint = Color(0xFFC7C7CC);      // iOS Tertiary Label

  // ─── Dark Theme (iOS 26 Pure OLED Dark) ─────────────────
  static const Color darkBackground = Color(0xFF000000); // Pure OLED Black
  static const Color darkSurface = Color(0xFF1C1C1E);   // iOS Elevated Surface
  static const Color darkCard = Color(0xFF2C2C2E);      // iOS Secondary Surface
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF8E8E93);
  static const Color darkTextHint = Color(0xFF636366);

  // ─── Card Accent Colors ──────────────────────────────────
  static const Color cardBlue = Color(0xFFEEF2FF);      // Indigo 50
  static const Color cardGreen = Color(0xFFECFDF5);     // Emerald 50
  static const Color cardOrange = Color(0xFFFFFBEB);    // Amber 50
  static const Color cardPurple = Color(0xFFF5F3FF);    // Violet 50
  static const Color cardTeal = Color(0xFFECFEFF);      // Cyan 50

  // ─── Gradient Presets (VisionOS Mesh-Style) ──────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF0EA5E9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Spatial mesh gradient for hero cards
  static const LinearGradient spatialGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFA78BFA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  // ─── Shadows (Softer, luminous) ──────────────────────────
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: const Color(0xFF6366F1).withValues(alpha: 0.06),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> mediumShadow = [
    BoxShadow(
      color: const Color(0xFF6366F1).withValues(alpha: 0.08),
      blurRadius: 32,
      offset: const Offset(0, 12),
    ),
  ];

  static List<BoxShadow> glowShadow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.25),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // Context-aware shadow (transparent in dark mode)
  static List<BoxShadow> shadow(BuildContext context) {
    final shadowColor =
        Theme.of(context).extension<AppThemeExtension>()?.scaffoldShadow ??
        Colors.transparent;
    if (shadowColor == Colors.transparent) return [];

    return [
      BoxShadow(color: shadowColor, blurRadius: 24, offset: const Offset(0, 8)),
    ];
  }

  // ─── Claymorphism Tokens ──────────────────────────────────
  static const Color claySurface = Color(0xFFE8EAF0);      // Light clay bg
  static const Color claySurfaceDark = Color(0xFF1E1E24);   // Dark clay bg
  static const Color clayCard = Color(0xFFECEEF4);          // Light card surface
  static const Color clayCardDark = Color(0xFF252530);       // Dark card surface
  static const Color clayShadowDark = Color(0xFFBCC3CE);    // Light mode dark shadow
  static const Color clayShadowLight = Color(0xFFFFFFFF);   // Light mode highlight
  static const Color clayShadowDarkMode = Color(0xFF000000); // Dark mode shadow
  static const Color clayHighlightDarkMode = Color(0xFF2A2A35); // Dark mode highlight

  // Clay dynamic getters
  static Color claySfc(BuildContext context) =>
      isDark(context) ? claySurfaceDark : claySurface;
  static Color clayCardColor(BuildContext context) =>
      isDark(context) ? clayCardDark : clayCard;

  // ─── Dynamic Getters (using ThemeExtension) ──────────────
  static Color bg(BuildContext context) =>
      Theme.of(context).extension<AppThemeExtension>()?.bg ?? background;
  static Color card(BuildContext context) =>
      Theme.of(context).extension<AppThemeExtension>()?.card ?? surface;
  static Color text(BuildContext context) =>
      Theme.of(context).extension<AppThemeExtension>()?.text ?? textPrimary;
  static Color textSec(BuildContext context) =>
      Theme.of(context).extension<AppThemeExtension>()?.textSec ??
      textSecondary;
  static Color hint(BuildContext context) =>
      Theme.of(context).extension<AppThemeExtension>()?.hint ?? textHint;

  // Glass material helpers
  static Color glass(BuildContext context) =>
      Theme.of(context).extension<AppThemeExtension>()?.glassColor ??
      Colors.white.withValues(alpha: 0.7);
  static Color glassBorder(BuildContext context) =>
      Theme.of(context).extension<AppThemeExtension>()?.glassBorder ??
      Colors.black.withValues(alpha: 0.04);
  static Color glow(BuildContext context) =>
      Theme.of(context).extension<AppThemeExtension>()?.glowColor ??
      primary.withValues(alpha: 0.06);

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// Returns a **visible** primary color: bright indigo in dark mode,
  /// standard indigo in light mode.
  static Color primaryAdaptive(BuildContext context) =>
      isDark(context) ? primaryDark : primary;

  /// Subtle divider color for both modes.
  static Color divider(BuildContext context) =>
      isDark(context)
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.black.withValues(alpha: 0.04);
}
