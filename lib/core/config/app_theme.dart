import 'package:flutter/material.dart';

/// Tema visual centralizado do VanPro.
/// Material3 com cores amber (primária) + blueGrey (superfícies).
class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.amber,
        brightness: Brightness.light,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blueGrey.shade800,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.amber,
        brightness: Brightness.dark,
      );
}
