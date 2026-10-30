import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.copper,
        onPrimary: Colors.white,
        secondary: AppColors.sage,
        onSecondary: Colors.white,
        surface: AppColors.paper,
        onSurface: AppColors.ink,
        tertiary: AppColors.blush,
      ),
      scaffoldBackgroundColor: AppColors.paper,
    );
    return _withTypography(base, AppColors.ink, AppColors.inkSoft);
  }

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.copperSoft,
        onPrimary: AppColors.ink,
        secondary: AppColors.sage,
        onSecondary: AppColors.cream,
        surface: AppColors.darkEspresso,
        onSurface: AppColors.cream,
        tertiary: AppColors.blush,
      ),
      scaffoldBackgroundColor: AppColors.darkEspresso,
    );
    return _withTypography(base, AppColors.cream, const Color(0xFFC9B8A8));
  }

  static ThemeData _withTypography(ThemeData base, Color ink, Color muted) {
    final display = GoogleFonts.fraunces(
      color: ink,
      fontWeight: FontWeight.w600,
      height: 1.1,
    );
    final body = GoogleFonts.figtree(
      color: ink,
      height: 1.35,
    );
    return base.copyWith(
      textTheme: TextTheme(
        displayLarge: display.copyWith(fontSize: 44, letterSpacing: -1),
        displayMedium: display.copyWith(fontSize: 34, letterSpacing: -0.6),
        headlineLarge: display.copyWith(fontSize: 28),
        headlineMedium: display.copyWith(fontSize: 22),
        titleLarge: display.copyWith(fontSize: 20, fontWeight: FontWeight.w500),
        titleMedium: body.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
        bodyLarge: body.copyWith(fontSize: 16),
        bodyMedium: body.copyWith(fontSize: 14, color: muted),
        bodySmall: body.copyWith(fontSize: 12, color: muted),
        labelLarge: body.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
      chipTheme: ChipThemeData(
        selectedColor: AppColors.copper.withValues(alpha: 0.16),
        backgroundColor: ink.withValues(alpha: 0.05),
        labelStyle: body.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        side: BorderSide.none,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.copper,
        thumbColor: AppColors.copper,
        overlayColor: AppColors.copper.withValues(alpha: 0.12),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: ink,
        titleTextStyle: display.copyWith(fontSize: 22),
      ),
      splashFactory: InkRipple.splashFactory,
      dividerColor: ink.withValues(alpha: 0.08),
    );
  }
}
