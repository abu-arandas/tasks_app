import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage application language settings
class LanguageService extends GetxService {
  // Observable current language code
  final RxString currentLanguage = 'en'.obs;

  // Available languages with their display names
  final Map<String, String> availableLanguages = {
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'de': 'Deutsch',
    'zh': '中文',
    'ja': '日本語',
    'ar': 'العربية',
  };

  @override
  void onInit() {
    super.onInit();
    loadSavedLanguage();
  }

  /// Load the saved language preference from SharedPreferences
  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('language_code') ?? 'en';
    currentLanguage.value = savedLanguage;

    // Update the app locale
    updateAppLanguage(savedLanguage);
  }

  /// Change the application language
  Future<void> changeLanguage(String languageCode) async {
    if (!availableLanguages.containsKey(languageCode)) {
      return; // Invalid language code
    }

    // Save to preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);

    // Update observable and app locale
    currentLanguage.value = languageCode;
    updateAppLanguage(languageCode);
  }

  /// Update the app's locale based on language code
  void updateAppLanguage(String languageCode) {
    Get.updateLocale(Locale(languageCode));
  }

  /// Get the display name for a language code
  String getLanguageDisplayName(String languageCode) {
    return availableLanguages[languageCode] ?? 'Unknown';
  }

  /// Get the current language display name
  String get currentLanguageDisplayName {
    return getLanguageDisplayName(currentLanguage.value);
  }
}
