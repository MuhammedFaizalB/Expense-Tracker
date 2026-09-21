import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color success;
  final Color error;
  final Color warning;
  final Color income;
  final Color expense;

  final Color heroHeader;

  final Color heroGradientStart;
  final Color heroGradientEnd;

  final Color glow;

  const AppColors({
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.success,
    required this.error,
    required this.warning,
    required this.income,
    required this.expense,
    required this.heroHeader,
    required this.heroGradientStart,
    required this.heroGradientEnd,
    required this.glow,
  });

  static const light = AppColors(
    primary: Color(0xFF22C55E),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF64748B),
    background: Color(0xFFF6F9F8),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF0F4F3),
    border: Color(0xFFE7ECEA),
    textPrimary: Color(0xFF15211E),
    textSecondary: Color(0xFF77897F),
    textDisabled: Color(0xFFB9C4C1),
    success: Color(0xFF22C55E),
    error: Color(0xFFE0435C),
    warning: Color(0xFFF59E0B),
    income: Color(0xFF22C55E),
    expense: Color(0xFFE0435C),
    heroHeader: Color(0xFF0E1B26),
    heroGradientStart: Color(0xFF1FE0A0),
    heroGradientEnd: Color(0xFF0BA968),
    glow: Color(0xFF22C55E),
  );

  static const dark = AppColors(
    primary: Color(0xFF34D399),
    onPrimary: Color(0xFF04140F),
    secondary: Color(0xFF93A6A0),
    background: Color(0xFF0B1512),
    surface: Color(0xFF13211D),
    surfaceVariant: Color(0xFF1A2E28),
    border: Color(0xFF223A33),
    textPrimary: Color(0xFFF1F7F4),
    textSecondary: Color(0xFFA6BAB4),
    textDisabled: Color(0xFF56706A),
    success: Color(0xFF34D399),
    error: Color(0xFFFF6B81),
    warning: Color(0xFFFFB25C),
    income: Color(0xFF34D399),
    expense: Color(0xFFFF6B81),
    heroHeader: Color(0xFF071119),
    heroGradientStart: Color(0xFF1FE0A0),
    heroGradientEnd: Color(0xFF0A7A4E),
    glow: Color(0xFF34D399),
  );

  @override
  AppColors copyWith({
    Color? primary,
    Color? onPrimary,
    Color? secondary,
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDisabled,
    Color? success,
    Color? error,
    Color? warning,
    Color? income,
    Color? expense,
    Color? heroHeader,
    Color? heroGradientStart,
    Color? heroGradientEnd,
    Color? glow,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      secondary: secondary ?? this.secondary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textDisabled: textDisabled ?? this.textDisabled,
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      income: income ?? this.income,
      expense: expense ?? this.expense,
      heroHeader: heroHeader ?? this.heroHeader,
      heroGradientStart: heroGradientStart ?? this.heroGradientStart,
      heroGradientEnd: heroGradientEnd ?? this.heroGradientEnd,
      glow: glow ?? this.glow,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      heroHeader: Color.lerp(heroHeader, other.heroHeader, t)!,
      heroGradientStart: Color.lerp(
        heroGradientStart,
        other.heroGradientStart,
        t,
      )!,
      heroGradientEnd: Color.lerp(heroGradientEnd, other.heroGradientEnd, t)!,
      glow: Color.lerp(glow, other.glow, t)!,
    );
  }
}
