import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/theme_service.dart';

class ThemeSettingsScreen extends StatelessWidget {
  final ThemeService _themeService = Get.find<ThemeService>();

  // List of available colors for theme customization
  final List<Color> _availableColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
  ];

  ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Settings'),
      ),
      body: Obx(() => ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Theme mode selection
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'App Theme',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      RadioListTile<ThemeMode>(
                        title: const Text('Light'),
                        value: ThemeMode.light,
                        groupValue: _themeService.themeMode.value,
                        onChanged: (ThemeMode? value) {
                          if (value != null) {
                            _themeService.saveThemeMode(value);
                          }
                        },
                      ),
                      RadioListTile<ThemeMode>(
                        title: const Text('Dark'),
                        value: ThemeMode.dark,
                        groupValue: _themeService.themeMode.value,
                        onChanged: (ThemeMode? value) {
                          if (value != null) {
                            _themeService.saveThemeMode(value);
                          }
                        },
                      ),
                      RadioListTile<ThemeMode>(
                        title: const Text('System Default'),
                        value: ThemeMode.system,
                        groupValue: _themeService.themeMode.value,
                        onChanged: (ThemeMode? value) {
                          if (value != null) {
                            _themeService.saveThemeMode(value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Primary color selection
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Primary Color',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _availableColors.map((color) {
                          return GestureDetector(
                            onTap: () {
                              _themeService.savePrimaryColor(color);
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _themeService.primaryColor.value == color ? Colors.white : Colors.transparent,
                                  width: 3,
                                ),
                                boxShadow: [
                                  if (_themeService.primaryColor.value == color)
                                    BoxShadow(
                                      color: color.withOpacity(0.5),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                ],
                              ),
                              child: _themeService.primaryColor.value == color
                                  ? const Icon(Icons.check, color: Colors.white)
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
