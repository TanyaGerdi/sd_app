import 'package:flutter/material.dart';

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color bg;
  final Color card;
  final Color text;
  final Color textSec;
  final Color hint;
  final Color scaffoldShadow;

  const AppThemeExtension({
    required this.bg,
    required this.card,
    required this.text,
    required this.textSec,
    required this.hint,
    required this.scaffoldShadow,
  });

  @override
  ThemeExtension<AppThemeExtension> copyWith({
    Color? bg,
    Color? card,
    Color? text,
    Color? textSec,
    Color? hint,
    Color? scaffoldShadow,
  }) {
    return AppThemeExtension(
      bg: bg ?? this.bg,
      card: card ?? this.card,
      text: text ?? this.text,
      textSec: textSec ?? this.textSec,
      hint: hint ?? this.hint,
      scaffoldShadow: scaffoldShadow ?? this.scaffoldShadow,
    );
  }

  @override
  ThemeExtension<AppThemeExtension> lerp(
    covariant ThemeExtension<AppThemeExtension>? other,
    double t,
  ) {
    if (other is! AppThemeExtension) {
      return this;
    }
    return AppThemeExtension(
      bg: Color.lerp(bg, other.bg, t)!,
      card: Color.lerp(card, other.card, t)!,
      text: Color.lerp(text, other.text, t)!,
      textSec: Color.lerp(textSec, other.textSec, t)!,
      hint: Color.lerp(hint, other.hint, t)!,
      scaffoldShadow: Color.lerp(scaffoldShadow, other.scaffoldShadow, t)!,
    );
  }
}
