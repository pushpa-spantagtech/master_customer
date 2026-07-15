import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';

ThemeData lightTheme({Color color = AppConstants.lightPrimary}) {
  const Color brandRed = Color(0xFFE71921);
  const Color brandGold = Color(0xFFFFB100);
  const Color ink = Color(0xFF121A2C);
  const Color muted = Color(0xFF667085);
  const Color surface = Color(0xFFF7F8FB);

  final ColorScheme scheme = ColorScheme.fromSeed(
    seedColor: brandRed,
    brightness: Brightness.light,
    primary: brandRed,
    secondary: brandGold,
    surface: surface,
    error: const Color(0xFFEF4444),
  ).copyWith(
    primaryContainer: const Color(0xFFFFE4E6),
    secondaryContainer: const Color(0xFFFFF4D6),
    outline: const Color(0xFFE4E7EC),
    onPrimary: Colors.white,
    onSecondary: ink,
  );

  return ThemeData(
    useMaterial3: true,
    fontFamily: AppConstants.fontFamily,
    primaryColor: brandRed,
    primaryColorDark: const Color(0xFFB51218),
    disabledColor: const Color(0xFFD0D5DD),
    dialogBackgroundColor: Colors.white,
    scaffoldBackgroundColor: surface,
    canvasColor: surface,
    cardColor: Colors.white,
    shadowColor: Colors.black.withValues(alpha: 0.08),
    hintColor: muted,
    brightness: Brightness.light,
    colorScheme: scheme,
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: brandGold,
      selectionColor: Color.fromRGBO(255, 177, 0, 0.24),
      selectionHandleColor: brandGold,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      backgroundColor: surface,
      foregroundColor: ink,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE4E7EC)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE4E7EC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: brandGold, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
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
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: brandRed,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: brandRed,
      unselectedItemColor: muted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: ink),
      bodyMedium: TextStyle(color: ink),
      bodySmall: TextStyle(color: muted),
      titleLarge: TextStyle(color: ink, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(color: ink, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(color: ink, fontWeight: FontWeight.w600),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: brandRed),
    ),
  );
}
