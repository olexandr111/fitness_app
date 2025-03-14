import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF6A1B9A); // Фіолетовий
const Color accentColor = Color(0xFF00ACC1); // Бірюзовий
const Color backgroundColor = Color(0xFF121212);
const Color cardColor = Color(0xFF1E1E1E);


// Світла тема
const Color lightPrimaryColor = Color(0xFF6200EA); // Фіолетовий
const Color lightAccentColor = Color(0xFF03DAC6); // Бірюзовий
const Color lightBackgroundColor = Color(0xFFF5F5F5); // Світло-сірий
const Color lightCardColor = Colors.white; // Білий
const Color lightTextColor = Color(0xFF212121); // Темно-сірий
const Color lightSecondaryTextColor = Color(0xFF757575); // Світліший сірий

// Темна тема
const Color darkPrimaryColor = Color(0xFF6A1B9A); // Темно-фіолетовий
const Color darkAccentColor = Color(0xFF00ACC1); // Темний бірюзовий
const Color darkBackgroundColor = Color(0xFF121212); // Темний фон
const Color darkCardColor = Color(0xFF1E1E1E); // Темно-сірий для карток
const Color darkTextColor = Colors.white; // Білий текст
const Color darkSecondaryTextColor = Color(0xFFB0BEC5); // Світло-сірий для підзаголовків

class AppColors {
  static Color primaryColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? lightPrimaryColor : darkPrimaryColor;

  static Color accentColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? lightAccentColor : darkAccentColor;

  static Color backgroundColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? lightBackgroundColor : darkBackgroundColor;

  static Color cardColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? lightCardColor : darkCardColor;

  static Color textColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? lightTextColor : darkTextColor;

  static Color secondaryTextColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? lightSecondaryTextColor : darkSecondaryTextColor;
}