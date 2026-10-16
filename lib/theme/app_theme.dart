import 'package:flutter/material.dart';

/// Кастомные светлая и тёмная темы приложения
abstract final class AppTheme {
  static const _green = Color(0xFF4CAF50);
  static const _darkGreen = Color(0xFF1B5E20);
  static const _lightGreen = Color(0xFF81C784);

  static const _buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );
  static const _buttonPadding = EdgeInsets.symmetric(
    horizontal: 48,
    vertical: 14,
  );
  static const _buttonText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );

  static final ThemeData light = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _green,
      brightness: Brightness.light,
    ),
    // Цвет фона экранов
    scaffoldBackgroundColor: const Color(0xFFF7F9F7),
    // Цвет фона и текста AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: _green,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),
    // Цвет основного текста
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF1C1C1C)),
      bodyMedium: TextStyle(color: Color(0xFF1C1C1C), fontSize: 15),
      titleMedium: TextStyle(color: Color(0xFF1C1C1C)),
    ),
    // Цвет карточек
    cardTheme: const CardThemeData(color: Colors.white, elevation: 1),
    // Цвет иконок
    iconTheme: const IconThemeData(color: Color(0xFF2E7D32)),
    listTileTheme: const ListTileThemeData(iconColor: Color(0xFF2E7D32)),
    // Стиль ElevatedButton: цвет фона, цвет текста и форма
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        padding: _buttonPadding,
        shape: _buttonShape,
        textStyle: _buttonText,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFFDCEDC8),
      indicatorColor: _lightGreen,
    ),
  );

  static final ThemeData dark = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _green,
      brightness: Brightness.dark,
    ),
    // Цвет фона экранов
    scaffoldBackgroundColor: const Color(0xFF121212),
    // Цвет фона и текста AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: _darkGreen,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),
    // Цвет основного текста
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFE6E6E6)),
      bodyMedium: TextStyle(color: Color(0xFFE6E6E6), fontSize: 15),
      titleMedium: TextStyle(color: Color(0xFFE6E6E6)),
    ),
    // Цвет карточек
    cardTheme: const CardThemeData(color: Color(0xFF1E1E1E), elevation: 1),
    // Цвет иконок
    iconTheme: const IconThemeData(color: _lightGreen),
    listTileTheme: const ListTileThemeData(
      iconColor: _lightGreen,
      textColor: Color(0xFFE6E6E6),
    ),
    // Стиль ElevatedButton: цвет фона, цвет текста и форма
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightGreen,
        foregroundColor: Colors.black,
        padding: _buttonPadding,
        shape: _buttonShape,
        textStyle: _buttonText,
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Color(0xFF1E2A1E),
      indicatorColor: _darkGreen,
    ),
  );
}
