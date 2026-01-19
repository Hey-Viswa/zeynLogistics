import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color _primary = Color(0xFF0F766E); // Deep Teal
  static const Color _secondary = Color(0xFF0EA5E9); // Sky Blue Accent
  static const Color _surface = Color(0xFFF8FAFC); // Cool Grey/White
  static const Color _background = Color(0xFFFFFFFF);
  static const Color _error = Color(0xFFEF4444);

  static ThemeData getLightTheme([ColorScheme? dynamicScheme]) {
    final colorScheme =
        dynamicScheme ??
        ColorScheme.fromSeed(
          seedColor: _primary,
          primary: _primary,
          secondary: _secondary,
          surface: _surface,
          background: _background,
          error: _error,
          brightness: Brightness.light,
        );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: _surface,
      colorScheme: colorScheme,

      // Typography
      textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.0,
          color: const Color(0xFF1E293B), // Slate 800
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: const Color(0xFF1E293B),
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF334155), // Slate 700
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF334155),
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          height: 1.5,
          color: const Color(0xFF475569), // Slate 600
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          height: 1.5,
          color: const Color(0xFF64748B), // Slate 500
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),

      // App Bar
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: _surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1E293B),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),

      // Buttons
      filledButtonTheme: FilledButtonThemeData(
        style:
            FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              elevation: 0,
            ).copyWith(
              elevation: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.pressed)) return 0;
                return 2; // Subtle shadow
              }),
            ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1,
          ), // Slate 200
        ),
        color: Colors.white,
        margin: EdgeInsets.zero,
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _error),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          color: const Color(0xFF94A3B8), // Slate 400
        ),
      ),
    );
  }

  static ThemeData getDarkTheme([ColorScheme? dynamicScheme]) {
    final colorScheme =
        dynamicScheme ??
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF14B8A6),
          primary: const Color(0xFF14B8A6), // Teal 500
          secondary: const Color(0xFF0EA5E9), // Sky 500
          surface: const Color(0xFF121212), // Material Dark Surface
          background: const Color(0xFF000000),
          error: const Color(0xFFCF6679),
          brightness: Brightness.dark,
          primaryContainer: const Color(0xFF0F2522), // Very dark teal tint
          onPrimaryContainer: const Color(0xFFCCFBF1),
          secondaryContainer: const Color(0xFF0C1F2B), // Very dark sky tint
          onSecondaryContainer: const Color(0xFFE0F2FE),
          surfaceContainer: const Color(
            0xFF1E1E1E,
          ), // Slightly lighter for cards
          surfaceContainerHigh: const Color(0xFF2C2C2C),
          onSurface: const Color(0xFFE0E0E0),
          onSurfaceVariant: const Color(0xFFA0A0A0),
        );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF000000), // Pure Black for OLED
      colorScheme: colorScheme,

      // Typography
      textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.0,
          color: const Color(0xFFFFFFFF),
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: const Color(0xFFF0F0F0),
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFE0E0E0),
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFD0D0D0),
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          height: 1.5,
          color: const Color(0xFFD0D0D0),
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          height: 1.5,
          color: const Color(0xFFB0B0B0),
        ),
      ),

      // App Bar
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: const Color(0xFF000000),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFFFFFFF),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFFFFFFF)),
      ),

      // Buttons
      filledButtonTheme: FilledButtonThemeData(
        style:
            FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary, // Text color on button
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              elevation: 0,
            ).copyWith(
              elevation: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.pressed)) return 0;
                return 4; // Glow effect
              }),
            ),
      ),

      // Cards
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        color: const Color(0xFF121212),
        margin: EdgeInsets.zero,
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFF606060)),
      ),
    );
  }

  // Backwards compatibility wrappers
  static final lightTheme = getLightTheme();
  static final darkTheme = getDarkTheme();
}
