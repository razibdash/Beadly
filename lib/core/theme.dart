import 'package:flutter/material.dart';

/// Beadly's warm, neutral-spiritual color system, shared across every
/// tradition — only small icon accents change, never the palette.
class BeadlyColors {
  BeadlyColors._();

  // Light
  static const lightBackground = Color(0xFFFBF6EE);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightText = Color(0xFF2E2233);
  static const lightTextMuted = Color(0xFF6E6072);

  // Dark
  static const darkBackground = Color(0xFF161019);
  static const darkSurface = Color(0xFF211A26);
  static const darkText = Color(0xFFF4EEEF);
  static const darkTextMuted = Color(0xFFAFA3B4);

  // Shared accent gradient — amber-gold to soft rose.
  static const accentGold = Color(0xFFD9A441);
  static const accentRose = Color(0xFFC97B63);

  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentGold, accentRose],
  );
}

class BeadlyTheme {
  BeadlyTheme._();

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: BeadlyColors.lightBackground,
      colorScheme: base.colorScheme.copyWith(
        brightness: Brightness.light,
        primary: BeadlyColors.accentGold,
        secondary: BeadlyColors.accentRose,
        surface: BeadlyColors.lightSurface,
        onSurface: BeadlyColors.lightText,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: BeadlyColors.lightText,
        displayColor: BeadlyColors.lightText,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: BeadlyColors.lightText,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: BeadlyColors.lightSurface,
        selectedItemColor: BeadlyColors.accentRose,
        unselectedItemColor: BeadlyColors.lightTextMuted,
        type: BottomNavigationBarType.fixed,
      ),
      dividerColor: BeadlyColors.lightTextMuted.withValues(alpha: 0.15),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: BeadlyColors.darkBackground,
      colorScheme: base.colorScheme.copyWith(
        brightness: Brightness.dark,
        primary: BeadlyColors.accentGold,
        secondary: BeadlyColors.accentRose,
        surface: BeadlyColors.darkSurface,
        onSurface: BeadlyColors.darkText,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: BeadlyColors.darkText,
        displayColor: BeadlyColors.darkText,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: BeadlyColors.darkText,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: BeadlyColors.darkSurface,
        selectedItemColor: BeadlyColors.accentGold,
        unselectedItemColor: BeadlyColors.darkTextMuted,
        type: BottomNavigationBarType.fixed,
      ),
      dividerColor: BeadlyColors.darkTextMuted.withValues(alpha: 0.15),
    );
  }
}
