import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App theme configuration for Word Quest.
class AppTheme {
  AppTheme._();

  // ── Brand Colors ──
  static const Color _primaryGreen = Color(0xFF4CAF50);
  static const Color _accentOrange = Color(0xFFFF9800);
  static const Color _warmBrown = Color(0xFF795548);
  static const Color _skyBlue = Color(0xFF03A9F4);
  static const Color _softYellow = Color(0xFFFFF8E1);
  static const Color _leafGreen = Color(0xFF66BB6A);

  // ── Light Theme ──
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryGreen,
      brightness: Brightness.light,
      primary: _primaryGreen,
      secondary: _accentOrange,
      tertiary: _skyBlue,
      surface: _softYellow,
      onSurface: const Color(0xFF3E2723),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF1F8E9),
      textTheme: _buildTextTheme(Brightness.light),
      appBarTheme: AppBarTheme(
        backgroundColor: _primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.quicksand(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentOrange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 4,
          textStyle: GoogleFonts.quicksand(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      iconTheme: const IconThemeData(
        color: _warmBrown,
        size: 24,
      ),
    );
  }

  // ── Dark Theme ──
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _leafGreen,
      brightness: Brightness.dark,
      primary: _leafGreen,
      secondary: _accentOrange,
      tertiary: _skyBlue,
      surface: const Color(0xFF1A1A2E),
      onSurface: const Color(0xFFE0E0E0),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF0F0F23),
      textTheme: _buildTextTheme(Brightness.dark),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.quicksand(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentOrange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 4,
          textStyle: GoogleFonts.quicksand(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: const Color(0xFF16213E),
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      iconTheme: const IconThemeData(
        color: _leafGreen,
        size: 24,
      ),
    );
  }

  // ── Text Theme ──
  static TextTheme _buildTextTheme(Brightness brightness) {
    final color = brightness == Brightness.light
        ? const Color(0xFF3E2723)
        : const Color(0xFFE0E0E0);

    return TextTheme(
      displayLarge: GoogleFonts.quicksand(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: color,
      ),
      displayMedium: GoogleFonts.quicksand(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: color,
      ),
      displaySmall: GoogleFonts.quicksand(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: color,
      ),
      headlineMedium: GoogleFonts.quicksand(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      headlineSmall: GoogleFonts.quicksand(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleLarge: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleMedium: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      bodyLarge: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      bodyMedium: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      bodySmall: GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: color.withValues(alpha: 0.7),
      ),
      labelLarge: GoogleFonts.quicksand(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    );
  }

  // ── Game-Specific Styles ──

  /// Grid cell text style.
  static TextStyle gridLetterStyle({bool isDark = false}) {
    return GoogleFonts.quicksand(
      fontSize: 18,
      fontWeight: FontWeight.w800,
      color: isDark ? Colors.white : const Color(0xFF3E2723),
    );
  }

  /// Grid cell text style when highlighted.
  static TextStyle gridLetterHighlightedStyle() {
    return GoogleFonts.quicksand(
      fontSize: 18,
      fontWeight: FontWeight.w800,
      color: Colors.white,
    );
  }

  /// Gradient for buttons and accents.
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [_primaryGreen, _leafGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [_accentOrange, Color(0xFFFFB74D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient skyGradient = LinearGradient(
    colors: [Color(0xFF81D4FA), Color(0xFF03A9F4)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Warm background gradient for game screen.
  static const LinearGradient warmBackground = LinearGradient(
    colors: [
      Color(0xFFF1F8E9),
      Color(0xFFC8E6C9),
      Color(0xFFA5D6A7),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkBackground = LinearGradient(
    colors: [
      Color(0xFF0F0F23),
      Color(0xFF1A1A2E),
      Color(0xFF16213E),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Box shadow for cards and elevated elements.
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get buttonShadow => [
        BoxShadow(
          color: _accentOrange.withValues(alpha: 0.3),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];
}
