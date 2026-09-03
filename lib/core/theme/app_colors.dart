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
  });

  static const light = AppColors(
    primary: Color(0xFF1B3A5C),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF6B7280),
    background: Color(0xFFF7F7F5),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF0F0EE),
    border: Color(0xFFE0E0DC),
    textPrimary: Color(0xFF1A1A1A),
    textSecondary: Color(0xFF5C5C5C),
    textDisabled: Color(0xFFA0A0A0),
    success: Color(0xFF1E7B4D),
    error: Color(0xFFB3261E),
    warning: Color(0xFFB86E00),
    income: Color(0xFF1E7B4D),
    expense: Color(0xFFB3261E),
  );

  static const dark = AppColors(
    primary: Color(0xFF6E93B7),
    onPrimary: Color(0xFF0B1420),
    secondary: Color(0xFF9CA3AF),
    background: Color(0xFF121212),
    surface: Color(0xFF1C1C1E),
    surfaceVariant: Color(0xFF262628),
    border: Color(0xFF3A3A3C),
    textPrimary: Color(0xFFF0F0F0),
    textSecondary: Color(0xFFB0B0B0),
    textDisabled: Color(0xFF6E6E6E),
    success: Color(0xFF4FAE7C),
    error: Color(0xFFE4736A),
    warning: Color(0xFFE0A23B),
    income: Color(0xFF4FAE7C),
    expense: Color(0xFFE4736A),
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
    );
  }
}
