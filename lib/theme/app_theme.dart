import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_theme_extension.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
      ),
      textTheme: _buildTextTheme(
        AppColors.textPrimary,
        AppColors.textSecondary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.primary),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: AppColors.surface,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      extensions: [
        AppThemeExtension(
          bg: AppColors.background,
          card: AppColors.surface,
          text: AppColors.textPrimary,
          textSec: AppColors.textSecondary,
          hint: AppColors.textHint,
          scaffoldShadow: const Color(0xFF1E3A5F).withValues(alpha: 0.06),
        ),
      ],
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.darkSurface,
      ),
      textTheme: _buildTextTheme(
        AppColors.darkTextPrimary,
        AppColors.darkTextSecondary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: AppColors.darkSurface,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      extensions: const [
        AppThemeExtension(
          bg: AppColors.darkBackground,
          card: AppColors.darkCard,
          text: AppColors.darkTextPrimary,
          textSec: AppColors.darkTextSecondary,
          hint: AppColors.darkTextHint,
          scaffoldShadow: Colors.transparent, // Animated shadow disappearance
        ),
      ],
    );
  }

  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return GoogleFonts.notoKufiArabicTextTheme().copyWith(
      displayLarge: GoogleFonts.notoKufiArabic(
        color: primary,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
        height: 1.3,
      ),
      displayMedium: GoogleFonts.notoKufiArabic(
        color: primary,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),
      titleLarge: GoogleFonts.notoKufiArabic(
        color: primary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      titleMedium: GoogleFonts.notoKufiArabic(
        color: primary,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      bodyLarge: GoogleFonts.notoKufiArabic(
        color: primary,
        fontSize: 16,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.notoKufiArabic(
        color: secondary,
        fontSize: 14,
        height: 1.5,
      ),
      labelLarge: GoogleFonts.notoKufiArabic(
        color: primary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
