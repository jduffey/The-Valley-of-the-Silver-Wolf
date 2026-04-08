import 'package:flutter/material.dart';
import 'package:silver_wolf_flutter/core/theme/app_colors.dart';
import 'package:silver_wolf_flutter/core/theme/app_typography.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData build() {
    const ColorScheme colorScheme = ColorScheme.light(
      primary: AppColors.storm,
      secondary: AppColors.brass,
      surface: AppColors.parchment,
      error: AppColors.ember,
      onPrimary: Colors.white,
      onSecondary: AppColors.ink,
      onSurface: AppColors.ink,
      onError: Colors.white,
    );

    final ThemeData base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF8F2E9),
    );

    return base.copyWith(
      textTheme: AppTypography.build(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.storm,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.92),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.mist),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.storm,
          foregroundColor: Colors.white,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.storm,
          side: const BorderSide(color: AppColors.storm),
        ),
      ),
    );
  }
}
