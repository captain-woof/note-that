import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeCustom {
  static const Color _primaryColor = Color.fromRGBO(7, 91, 154, 1);

  static ThemeData getThemeData() {
    return ThemeData(
        appBarTheme: AppBarTheme(
            titleTextStyle: GoogleFonts.poppins(
              textStyle: TextStyle(
                  color: Colors.grey[50],
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
            actionsIconTheme: IconThemeData(color: Colors.grey[50]),
            iconTheme: IconThemeData(color: Colors.grey[50]),
            backgroundColor: _primaryColor,
            elevation: 4),
        scaffoldBackgroundColor: Colors.white,
        textTheme: TextTheme(
            titleLarge: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: _primaryColor,
                fontSize: 22),
            titleMedium: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: _primaryColor,
                fontSize: 18),
            titleSmall: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: _primaryColor,
              fontSize: 16,
            ),
            bodyLarge: GoogleFonts.lato(
                fontSize: 18, letterSpacing: 0.1, height: 1.75),
            bodyMedium: GoogleFonts.poppins(
                fontSize: 16,
                letterSpacing: 0.1,
                height: 1.75,
                wordSpacing: 0.1),
            bodySmall: GoogleFonts.poppins(
                fontSize: 14,
                letterSpacing: 0.1,
                height: 1.625,
                color: Colors.grey[800]),
            labelLarge: GoogleFonts.poppins(),
            labelSmall:
                GoogleFonts.poppins(color: Colors.grey[800], fontSize: 12)),
        colorScheme: ColorScheme.fromSeed(seedColor: _primaryColor),
        floatingActionButtonTheme:
            const FloatingActionButtonThemeData(backgroundColor: _primaryColor),
        snackBarTheme: const SnackBarThemeData(backgroundColor: _primaryColor),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: _primaryColor, circularTrackColor: null));
  }
}
