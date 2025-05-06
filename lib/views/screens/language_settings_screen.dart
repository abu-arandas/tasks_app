import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/language_service.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  final LanguageService _languageService = Get.find<LanguageService>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('language'.tr),
      ),
      body: Obx(() => ListView.builder(
            itemCount: _languageService.availableLanguages.length,
            itemBuilder: (context, index) {
              final languageCode = _languageService.availableLanguages.keys.elementAt(index);
              final languageName = _languageService.availableLanguages[languageCode]!;

              return RadioListTile<String>(
                title: Text(languageName),
                value: languageCode,
                groupValue: _languageService.currentLanguage.value,
                onChanged: (value) {
                  if (value != null) {
                    _languageService.changeLanguage(value);
                  }
                },
              );
            },
          )),
    );
  }
}
