import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/error_handler.dart';

class ThemeService extends GetxController {
  static const String theme = 'theme_mode';
  static const String color = 'primary_color';

  final ErrorHandler _errorHandler = Get.find<ErrorHandler>();

  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;
  final Rx<Color> primaryColor = Colors.blue.obs;

  @override
  void onInit() {
    super.onInit();
    loadThemeSettings();
  }

  Future<void> loadThemeSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load theme mode
      final savedThemeMode = prefs.getString(theme);
      if (savedThemeMode != null) {
        themeMode.value = _getThemeModeFromString(savedThemeMode);
      }

      // Load primary color
      final savedColorValue = prefs.getInt(color);
      if (savedColorValue != null) {
        primaryColor.value = Color(savedColorValue);
      }
    } catch (e) {
      _errorHandler.showErrorSnackbar('Error loading theme settings', e.toString());
    }
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(theme, mode.toString().split('.').last);
  }

  Future<void> savePrimaryColor(Color colors) async {
    primaryColor.value = colors;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(color, colors.toARGB32());
  }

  ThemeMode _getThemeModeFromString(String themeString) {
    switch (themeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  // Get current theme data
  ThemeData get lightTheme => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor.value),
        useMaterial3: true,
        fontFamily: 'Poppins',
      );

  ThemeData get darkTheme => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor.value,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
      );
}
