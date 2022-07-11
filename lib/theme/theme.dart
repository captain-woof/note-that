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
        textTheme: TextTheme(
            titleLarge: GoogleFonts.lato(
                fontWeight: FontWeight.w600,
                color: _primaryColor,
                fontSize: 20,
                letterSpacing: 0.1),
            titleMedium: GoogleFonts.lato(
                fontWeight: FontWeight.w500,
                color: _primaryColor,
                fontSize: 18,
                letterSpacing: 0.1),
            titleSmall: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: _primaryColor,
              fontSize: 16,
            ),
            bodyLarge: GoogleFonts.lato(fontSize: 18, letterSpacing: 0.1),
            bodyMedium: GoogleFonts.poppins(fontSize: 16, letterSpacing: 0.1),
            bodySmall: GoogleFonts.poppins(fontSize: 14, letterSpacing: 0.1),
            labelLarge: GoogleFonts.poppins(),
            labelSmall: GoogleFonts.poppins()),
        colorScheme: ColorScheme.fromSeed(seedColor: _primaryColor),
        floatingActionButtonTheme:
            const FloatingActionButtonThemeData(backgroundColor: _primaryColor),
        snackBarTheme: const SnackBarThemeData(backgroundColor: _primaryColor));
  }
}
