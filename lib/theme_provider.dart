import 'package:fitness_appp/colors.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  final Box _settingsBox = Hive.box('settings');

  ThemeProvider() {
    _isDarkMode = _settingsBox.get('isDarkMode', defaultValue: false) as bool;
  }
  bool get isDarkMode => _isDarkMode;

  ThemeData get themeData => _isDarkMode ? _darkTheme : _lightTheme;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _settingsBox.put('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: lightPrimaryColor,
    scaffoldBackgroundColor: lightBackgroundColor,
    cardColor: lightCardColor,
    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: lightTextColor),
      bodyMedium: TextStyle(fontSize: 16, color: lightTextColor),
      bodySmall: TextStyle(fontSize: 14, color: lightSecondaryTextColor),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: lightTextColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightPrimaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: lightPrimaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    ),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.deepPurple,
      accentColor: lightAccentColor,
      backgroundColor: lightBackgroundColor,
      cardColor: lightCardColor,
      brightness: Brightness.light,
    ),
  );

  final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: darkPrimaryColor,
    scaffoldBackgroundColor: darkBackgroundColor,
    cardColor: darkCardColor,
    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkTextColor),
      bodyMedium: TextStyle(fontSize: 16, color: darkTextColor),
      bodySmall: TextStyle(fontSize: 14, color: darkSecondaryTextColor),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: darkTextColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkPrimaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    ),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.purple,
      accentColor: darkAccentColor,
      backgroundColor: darkBackgroundColor,
      cardColor: darkCardColor,
      brightness: Brightness.dark,
    ),
  );
}