import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';

ThemeData darkTheme({Color primary = AppConstants.darkPrimary}) {
  const Color brandRed = Color(0xFFFF4D55);
  const Color brandGold = Color(0xFFFFB100);
  const Color surface = Color(0xFF111827);
  const Color card = Color(0xFF1F2937);
  const Color text = Color(0xFFF9FAFB);
  const Color muted = Color(0xFF98A2B3);

  final ColorScheme scheme = ColorScheme.fromSeed(
    seedColor: brandRed,
    brightness: Brightness.dark,
    primary: brandRed,
    secondary: brandGold,
    surface: surface,
    error: const Color(0xFFFF6767),
  ).copyWith(
    primaryContainer: const Color(0xFF3B1216),
    secondaryContainer: const Color(0xFF3D2B05),
    outline: const Color(0xFF344054),
    onPrimary: Colors.white,
    onSecondary: Colors.black,
  );

  return ThemeData(
    useMaterial3: true,
    fontFamily: AppConstants.fontFamily,
    primaryColor: brandRed,
    primaryColorDark: const Color(0xFFB51218),
    disabledColor: const Color(0xFF475467),
    scaffoldBackgroundColor: surface,
    canvasColor: surface,
    shadowColor: Colors.black.withValues(alpha: 0.25),
    brightness: Brightness.dark,
    hintColor: muted,
    cardColor: card,
    colorScheme: scheme,
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: brandGold,
      selectionColor: Color.fromRGBO(255, 177, 0, 0.24),
      selectionHandleColor: brandGold,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: surface,
      foregroundColor: text,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: card,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF344054)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF344054)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: brandGold, width: 1.4),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        elevation: 0,
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: text),
      bodyMedium: TextStyle(color: text),
      bodySmall: TextStyle(color: muted),
      titleLarge: TextStyle(color: text, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(color: text, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(color: text, fontWeight: FontWeight.w600),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: brandRed),
    ),
  );
}
