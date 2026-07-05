import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  //==================================================
  // COLORS
  //==================================================

  static const Color primary = Color(0xFF7B3F00);
  static const Color secondary = Color(0xFFD4AF37);

  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);

  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color darkBackground = Color(0xFF0F172A);

  static const Color lightSurface = Colors.white;
  static const Color darkSurface = Color(0xFF1E293B);

  static const Color lightText = Color(0xFF111827);
  static const Color darkText = Color(0xFFF8FAFC);

  static const Color lightSubtitle = Color(0xFF6B7280);
  static const Color darkSubtitle = Color(0xFFCBD5E1);

  static const double radius = 22;

  //==================================================
  // LIGHT THEME
  //==================================================

  static ThemeData get lightTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,

      colorScheme: scheme.copyWith(
        primary: primary,
        secondary: secondary,
        surface: lightSurface,
      ),

      scaffoldBackgroundColor: lightBackground,

      fontFamily: "Roboto",

      visualDensity: VisualDensity.adaptivePlatformDensity,
            //==================================================
      // APP BAR
      //==================================================

      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: lightText,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 70,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: lightText,
        ),
      ),

      //==================================================
      // CARD
      //==================================================

      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 2,
        shadowColor: Colors.black12,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),

      //==================================================
      // ELEVATED BUTTON
      //==================================================

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(170, 56),
          padding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 18,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),

      //==================================================
      // OUTLINED BUTTON
      //==================================================

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(170, 56),
          side: const BorderSide(
            color: primary,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),

      //==================================================
      // INPUTS
      //==================================================

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: primary,
            width: 2,
          ),
        ),
      ),

      //==================================================
      // NAVIGATION BAR
      //==================================================

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: secondary.withValues(alpha: .15),
      ),

      //==================================================
      // SNACKBAR
      //==================================================

      snackBarTheme: SnackBarThemeData(
        backgroundColor: primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 15,
        ),
      ),
            //==================================================
      // DIVIDER
      //==================================================

      dividerTheme: const DividerThemeData(
        color: Color(0xFFE5E7EB),
        thickness: 1,
      ),

      //==================================================
      // TEXT THEME
      //==================================================

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 54,
          fontWeight: FontWeight.bold,
          color: lightText,
        ),
        displayMedium: TextStyle(
          fontSize: 42,
          fontWeight: FontWeight.bold,
          color: lightText,
        ),
        headlineLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: lightText,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: lightText,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: lightText,
        ),
        bodyLarge: TextStyle(
          fontSize: 17,
          color: lightText,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          color: lightSubtitle,
          height: 1.6,
        ),
      ),
    );
  }

  //==================================================
  // DARK THEME
  //==================================================

  static ThemeData get darkTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(
        primary: primary,
        secondary: secondary,
        surface: darkSurface,
      ),
      scaffoldBackgroundColor: darkBackground,
      fontFamily: "Roboto",

      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: darkSurface,
        foregroundColor: darkText,
        surfaceTintColor: Colors.transparent,
      ),

      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(170, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: darkText,
          fontSize: 54,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: darkText,
          fontSize: 42,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: darkText,
          fontSize: 34,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: darkText,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: darkText,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: darkText,
          fontSize: 17,
        ),
        bodyMedium: TextStyle(
          color: darkSubtitle,
          fontSize: 15,
        ),
      ),
    );
  }
}