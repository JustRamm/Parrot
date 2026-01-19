import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors meticulously sampled from the Logo
  static const Color logoSage = Color(0xFF698F79);   // The Parrot Green
  static const Color logoRose = Color(0xFFE295A2);   // The Hand Pink
  static const Color logoBerry = Color(0xFFA12D4E);  // The Hand Dark Accent
  
  // Professional Minimalist Neutral Palette
  static const Color primaryDark = Color(0xFF2D3436); // Deep Charcoal
  static const Color backgroundClean = Color(0xFFF9FAFB); // Pure Light Gray
  static const Color surfaceWhite = Colors.white;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: logoSage,
        primary: logoSage,         // Sage is now the core brand color
        secondary: logoRose,       // Rose as the subtle accent
        tertiary: logoBerry,       // Berry for high-contrast/critical actions
        surface: surfaceWhite,
        background: backgroundClean,
      ),
      scaffoldBackgroundColor: backgroundClean,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w800,
          color: primaryDark,
          letterSpacing: -1,
        ),
        headlineMedium: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          color: primaryDark,
        ),
        titleLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          color: primaryDark,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: primaryDark,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: primaryDark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: logoSage,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      // Custom styling for the Editable Transcription area
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: logoSage, width: 1.5),
        ),
      ),
    );
  }
}
