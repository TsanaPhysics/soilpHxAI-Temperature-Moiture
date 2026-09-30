import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette
  static const Color background = Color(0xFF0B111E);
  static const Color surface = Color(0xFF141F32);
  static const Color surfaceCard = Color(0xFF1B2A44);
  static const Color surfaceGlass = Color(0x331B2A44);
  
  static const Color primaryEmerald = Color(0xFF10B981);
  static const Color primaryCyan = Color(0xFF06B6D4);
  static const Color accentNeon = Color(0xFF34D399);
  
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color dangerRose = Color(0xFFF43F5E);
  static const Color infoBlue = Color(0xFF38BDF8);
  static const Color neutralText = Color(0xFFE2E8F0);
  static const Color mutedText = Color(0xFF94A3B8);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primaryEmerald,
      colorScheme: const ColorScheme.dark(
        primary: primaryEmerald,
        secondary: primaryCyan,
        surface: surface,
        error: dangerRose,
        onPrimary: Colors.black,
        onSurface: neutralText,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: neutralText,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: neutralText),
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: primaryEmerald.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primaryEmerald,
        unselectedItemColor: mutedText,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 11),
      ),
    );
  }
}
