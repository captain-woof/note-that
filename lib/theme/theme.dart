import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeCustom {
  static const Color _primaryColor = Color.fromRGBO(7, 91, 154, 1);

  static ThemeData getThemeData() {
    return ThemeData(
        appBarTheme: AppBarTheme(
            titleTextStyle: GoogleFonts.montserrat(
              textStyle: const TextStyle(
                  color: _primaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w700),
            ),
            actionsIconTheme: const IconThemeData(color: _primaryColor),
            iconTheme: const IconThemeData(color: _primaryColor),
            backgroundColor: Colors.white,
            elevation: 0),
        scaffoldBackgroundColor: Colors.white,
        textTheme: TextTheme(
            titleLarge: GoogleFonts.lato(
                fontWeight: FontWeight.w600,
                color: _primaryColor,
                fontSize: 28,
                letterSpacing: 0.1),
            titleMedium: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: _primaryColor,
                fontSize: 24),
            titleSmall: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: _primaryColor,
              fontSize: 20,
            ),
            bodyLarge: GoogleFonts.lato(
                fontSize: 20, letterSpacing: 0.1, height: 1.75),
            bodyMedium: GoogleFonts.poppins(
                fontSize: 18,
                letterSpacing: 0.1,
                height: 1.75,
                wordSpacing: 0.1),
            bodySmall: GoogleFonts.poppins(
                fontSize: 16,
                letterSpacing: 0.1,
                height: 1.625,
                color: Colors.grey[800]),
            labelLarge: GoogleFonts.poppins(),
            labelSmall: GoogleFonts.poppins()),
        colorScheme: ColorScheme.fromSeed(seedColor: _primaryColor),
        floatingActionButtonTheme:
            const FloatingActionButtonThemeData(backgroundColor: _primaryColor),
        snackBarTheme: const SnackBarThemeData(backgroundColor: _primaryColor),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: _primaryColor, circularTrackColor: null));
  }
}
