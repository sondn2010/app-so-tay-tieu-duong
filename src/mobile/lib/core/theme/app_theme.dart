import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds (warm paper)
  static const background = Color(0xFFFCF9F3);
  static const surface = Color(0xFFFCF9F3);
  static const surfaceContainerLow = Color(0xFFF6F3ED);
  static const surfaceContainer = Color(0xFFF0EEE8);
  static const surfaceContainerHigh = Color(0xFFEBE8E2);
  static const surfaceDim = Color(0xFFDCDAD4);

  // Primary (soft teal-green)
  static const primary = Color(0xFF35675B);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF6B9E90);
  static const onPrimaryContainer = Color(0xFF00342A);

  // Secondary (muted yellow)
  static const secondary = Color(0xFF735B26);
  static const secondaryContainer = Color(0xFFFDDC9A);

  // Tertiary / danger (soft red)
  static const tertiary = Color(0xFF8B4C50);
  static const tertiaryContainer = Color(0xFFC98083);
  static const error = Color(0xFFBA1A1A);

  // Text
  static const onSurface = Color(0xFF1C1C18);
  static const onSurfaceVariant = Color(0xFF404946);
  static const outline = Color(0xFF707975);
  static const outlineVariant = Color(0xFFC0C8C4);

  // Blood sugar status
  static const bsLow = Color(0xFFBA1A1A);
  static const bsNormal = Color(0xFF35675B);
  static const bsPrediabetes = Color(0xFF735B26);
  static const bsHigh = Color(0xFFBA1A1A);
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        fontFamily: 'BeVietnamPro',
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          secondary: AppColors.secondary,
          tertiary: AppColors.tertiary,
          error: AppColors.error,
          surface: AppColors.surface,
          onSurface: AppColors.onSurface,
          secondaryContainer: AppColors.secondaryContainer,
        ),
        scaffoldBackgroundColor: AppColors.background,
        cardColor: AppColors.surfaceContainerLow,
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: AppColors.surfaceContainerLow,
          indicatorColor: AppColors.primaryContainer,
        ),
      );
}
