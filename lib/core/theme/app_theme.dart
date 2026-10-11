// ============================================================================
// app_theme.dart
// ----------------------------------------------------------------------------
// Central theme file. Everything you'd want to tweak lives in ONE of the
// sections below — change a value here and it propagates everywhere.
//
// Structure:
//   1. AppColors      -> raw color palette (brand + semantic)
//   2. AppRadius       -> corner radius scale
//   3. AppSpacing       -> spacing scale
//   4. AppTextStyles    -> typography scale (theme-aware via factory methods)
//   5. AppTheme         -> ThemeData.light / ThemeData.dark builders
// ============================================================================

import 'package:flutter/material.dart';

// ============================================================================
// 1. COLORS
// ============================================================================
/// Raw palette. Keep this the single source of truth for every color used
/// in the app. Nothing outside this class should hardcode a Color(0x...).
class AppColors {
  AppColors._();

  // --- Brand -----------------------------------------------------------
  static const Color brandGreen = Color(0xFF2ECC71); // primary accent
  static const Color brandGreenDark = Color(0xFF1FA85C); // pressed/hover
  static const Color brandOrange = Color(0xFFFF7A29); // secondary accent
  static const Color brandOrangeDark = Color(0xFFE85D04);

  // --- Neutrals (dark mode) ---------------------------------------------
  static const Color darkBackground = Color(0xFF0B0F0D);
  static const Color darkSurface = Color(0xFF121613); // cards
  static const Color darkSurfaceAlt = Color(0xFF161B18); // stat tiles
  static const Color darkBorder = Color(0xFF232923);
  static const Color darkTextPrimary = Color(0xFFF5F7F5);
  static const Color darkTextSecondary = Color(0xFFA7B0A9);
  static const Color darkTextMuted = Color(0xFF6E766F);

  // --- Neutrals (light mode) ---------------------------------------------
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFF7F8F7);
  static const Color lightBorder = Color(0xFFE7EAE7);
  static const Color lightTextPrimary = Color(0xFF16181A);
  static const Color lightTextSecondary = Color(0xFF5B625D);
  static const Color lightTextMuted = Color(0xFF9AA19B);

  // --- Tints (soft icon/badge backgrounds) --------------------------------
  static const Color greenTintDark = Color(0x332ECC71); // ~20% on dark
  static const Color greenTintLight = Color(0xFFDCFCE7);
  static const Color orangeTintDark = Color(0x33FF7A29);
  static const Color orangeTintLight = Color(0xFFFFE6D6);
  static const Color purpleTintDark = Color(0x336C5DD3);
  static const Color purpleTintLight = Color(0xFFE7E3FB);
  static const Color purple = Color(0xFF6C5DD3);

  // --- Semantic ------------------------------------------------------------
  static const Color success = brandGreen;
  static const Color warning = Color(0xFFF5B93D);
  static const Color error = Color(0xFFE5484D);
  static const Color info = Color(0xFF3B9EFF);
}

// ============================================================================
// 2. RADIUS
// ============================================================================
class AppRadius {
  AppRadius._();

  static const double xs = 6;
  static const double sm = 10;
  static const double md = 16;
  static const double lg = 22;
  static const double xl = 28;
  static const double pill = 999;

  static BorderRadius get card => BorderRadius.circular(md);
  static BorderRadius get button => BorderRadius.circular(pill);
  static BorderRadius get chip => BorderRadius.circular(pill);
  static BorderRadius get heroCard => BorderRadius.circular(xl);
}

// ============================================================================
// 3. SPACING
// ============================================================================
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  static const EdgeInsets screenPadding =
  EdgeInsets.symmetric(horizontal: md, vertical: md);
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
}

// ============================================================================
// 4. TYPOGRAPHY
// ============================================================================
/// Text styles are defined as functions of a base color so the same scale
/// works for both light and dark themes without duplicating every style.
class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Inter'; // swap freely

  static TextTheme buildTextTheme(Color primary, Color secondary) {
    return TextTheme(
      // "Hello, Alex" greeting name / big numbers (e.g. "80")
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 48,
        fontWeight: FontWeight.w800,
        color: primary,
        height: 1.0,
      ),
      // Section hero titles ("Fluency Assessment")
      headlineLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: primary,
        height: 1.2,
      ),
      headlineSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      // Card titles ("English", "Start New Test")
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      // Body copy
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: secondary,
        height: 1.4,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: secondary,
        height: 1.4,
      ),
      // Labels ("TESTS TAKEN", "QUICK ACTIONS", nav bar labels)
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      labelMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: secondary,
        letterSpacing: 0.6, // eyebrow/uppercase labels
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: secondary,
      ),
    );
  }
}

// ============================================================================
// 5. THEME DATA
// ============================================================================
class AppTheme {
  AppTheme._();

  // --------------------------------------------------------------------
  // DARK THEME
  // --------------------------------------------------------------------
  static ThemeData get dark {
    final colorScheme = const ColorScheme.dark().copyWith(
      brightness: Brightness.dark,
      primary: AppColors.brandGreen,
      onPrimary: Colors.black,
      secondary: AppColors.brandOrange,
      onSecondary: Colors.black,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      error: AppColors.error,
      onError: Colors.white,
      outline: AppColors.darkBorder,
    );

    final textTheme = AppTextStyles.buildTextTheme(
      AppColors.darkTextPrimary,
      AppColors.darkTextSecondary,
    );

    return _buildTheme(
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackground: AppColors.darkBackground,
      surface: AppColors.darkSurface,
      surfaceAlt: AppColors.darkSurfaceAlt,
      border: AppColors.darkBorder,
      textMuted: AppColors.darkTextMuted,
    );
  }

  // --------------------------------------------------------------------
  // LIGHT THEME
  // --------------------------------------------------------------------
  static ThemeData get light {
    final colorScheme = const ColorScheme.light().copyWith(
      brightness: Brightness.light,
      primary: AppColors.brandGreen,
      onPrimary: Colors.black,
      secondary: AppColors.brandOrange,
      onSecondary: Colors.black,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightTextPrimary,
      error: AppColors.error,
      onError: Colors.white,
      outline: AppColors.lightBorder,
    );

    final textTheme = AppTextStyles.buildTextTheme(
      AppColors.lightTextPrimary,
      AppColors.lightTextSecondary,
    );

    return _buildTheme(
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackground: AppColors.lightBackground,
      surface: AppColors.lightSurface,
      surfaceAlt: AppColors.lightSurfaceAlt,
      border: AppColors.lightBorder,
      textMuted: AppColors.lightTextMuted,
    );
  }

  // --------------------------------------------------------------------
  // SHARED BUILDER — component themes live here so light/dark never drift
  // --------------------------------------------------------------------
  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required Color scaffoldBackground,
    required Color surface,
    required Color surfaceAlt,
    required Color border,
    required Color textMuted,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      textTheme: textTheme,
      fontFamily: AppTextStyles.fontFamily,
      splashFactory: InkRipple.splashFactory,

      // ---- AppBar --------------------------------------------------
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: textTheme.titleLarge,
      ),

      // ---- Cards (stat tiles, hero card) ----------------------------
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: BorderSide(color: border, width: 1),
        ),
      ),

      // ---- Buttons ("View Detailed Breakdown") -----------------------
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandGreen,
          foregroundColor: Colors.black,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          textStyle: textTheme.titleMedium?.copyWith(color: Colors.black),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: border),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.brandGreen,
          textStyle: textTheme.labelLarge,
        ),
      ),

      // ---- Chips ("B2", "Latest Result") -----------------------------
      chipTheme: ChipThemeData(
        backgroundColor: surfaceAlt,
        labelStyle: textTheme.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.chip),
        side: BorderSide.none,
      ),

      // ---- Bottom navigation -----------------------------------------
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: AppColors.brandGreen,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedLabelStyle: textTheme.labelSmall,
        unselectedLabelStyle: textTheme.labelSmall,
        elevation: 0,
      ),

      // ---- Icons --------------------------------------------------
      iconTheme: IconThemeData(color: colorScheme.onSurface),

      // ---- Dividers -----------------------------------------------
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),

      // ---- Progress indicators (percentile ring) ----------------------
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.brandOrange,
        circularTrackColor: Colors.transparent,
      ),
    );
  }
}

// ============================================================================
// USAGE
// ----------------------------------------------------------------------------
// MaterialApp(
//   theme: AppTheme.light,
//   darkTheme: AppTheme.dark,
//   themeMode: ThemeMode.system, // or ThemeMode.dark / ThemeMode.light
//   ...
// )
//
// Access anywhere:
//   Theme.of(context).colorScheme.primary
//   Theme.of(context).textTheme.headlineLarge
//   AppSpacing.md / AppRadius.card / AppColors.brandOrange
// ============================================================================