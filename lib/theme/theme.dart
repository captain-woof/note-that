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
            titleLarge: GoogleFonts.montserrat(),
            titleMedium: GoogleFonts.lato(),
            titleSmall: GoogleFonts.poppins(),
            bodyLarge: GoogleFonts.lato(),
            bodyMedium: GoogleFonts.poppins(),
            bodySmall: GoogleFonts.poppins(),
            labelLarge: GoogleFonts.poppins(),
            labelSmall: GoogleFonts.poppins()),
        colorScheme: ColorScheme.fromSeed(seedColor: _primaryColor),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: _primaryColor
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: _primaryColor
        )
        );
  }
}
