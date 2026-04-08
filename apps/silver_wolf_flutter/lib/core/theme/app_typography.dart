import 'package:flutter/material.dart';
import 'package:silver_wolf_flutter/core/theme/app_colors.dart';

class AppTypography {
  const AppTypography._();

  static TextTheme build(TextTheme base) {
    return base.copyWith(
      headlineMedium: base.headlineMedium?.copyWith(
        fontFamily: 'Georgia',
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontFamily: 'Georgia',
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      bodyLarge: base.bodyLarge?.copyWith(height: 1.45, color: AppColors.ink),
      bodyMedium: base.bodyMedium?.copyWith(height: 1.45, color: AppColors.ink),
      labelLarge: base.labelLarge?.copyWith(
        letterSpacing: 0.2,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
