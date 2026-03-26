import 'package:flutter/material.dart';
import 'app_theme_extension.dart';

class AppColors {
  // ─── Brand Palette (Refined Indigo + Warm Tones) ─────────────
  static const Color primary = Color(0xFF1E3A5F);
  static const Color primaryLight = Color(0xFF2C5282);
  static const Color primaryDark = Color(0xFF6EA8FE); // Vivid blue for dark mode
  static const Color secondary = Color(0xFFE8985E);
  static const Color accent = Color(0xFF5B8DEF);

  // ─── Light Theme ─────────────────────────────────────────────
  static const Color background = Color(0xFFF7F8FC);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1A202C);
  static const Color textSecondary = Color(0xFF8896AB);
  static const Color textHint = Color(0xFFBDC5D1);

  // ─── Dark Theme (iOS 26 Pure Dark) ─────────────────────────
  static const Color darkBackground = Color(0xFF000000); // Pure Black
  static const Color darkSurface = Color(0xFF1C1C1E); // iOS Elevated Surface
  static const Color darkCard = Color(0xFF2C2C2E); // iOS Card Surface
  static const Color darkTextPrimary = Color(0xFFFFFFFF); // White
  static const Color darkTextSecondary = Color(0xFF8E8E93); // iOS System Gray
  static const Color darkTextHint = Color(0xFF636366); // iOS System Gray 2

  // ─── Card Accent Colors ──────────────────────────────────────
  static const Color cardBlue = Color(0xFFEBF4FF);
  static const Color cardGreen = Color(0xFFE8FAF0);
  static const Color cardOrange = Color(0xFFFFF4EB);
  static const Color cardPurple = Color(0xFFF3EEFF);
  static const Color cardTeal = Color(0xFFE6FAF5);

  // ─── Gradient Presets ────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1E3A5F), Color(0xFF2C5282)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFE8985E), Color(0xFFF0B27A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF5B8DEF), Color(0xFF7BA7F7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Shadows ─────────────────────────────────────────────────
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: const Color(0xFF1E3A5F).withValues(alpha: 0.06),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> mediumShadow = [
    BoxShadow(
      color: const Color(0xFF1E3A5F).withValues(alpha: 0.10),
      blurRadius: 28,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> glowShadow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.30),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  // This shadow evaluates to transparent in dark mode natively via the extension
  static List<BoxShadow> shadow(BuildContext context) {
    final shadowColor =
        Theme.of(context).extension<AppThemeExtension>()?.scaffoldShadow ??
        Colors.transparent;
    if (shadowColor == Colors.transparent) return [];

    return [
      BoxShadow(color: shadowColor, blurRadius: 20, offset: const Offset(0, 6)),
    ];
  }

  // ─── Dynamic Getters (using ThemeExtension) ──────────────────
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

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// Returns a **visible** primary color: bright blue in dark mode,
  /// classic navy in light mode.
  static Color primaryAdaptive(BuildContext context) =>
      isDark(context) ? primaryDark : primary;

  /// Subtle divider color for both modes.
  static Color divider(BuildContext context) =>
      isDark(context)
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.06);
}
