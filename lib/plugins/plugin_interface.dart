import 'package:flutter/material.dart';

/// Abstract class defining the interface for all plugins in the Tasks App
abstract class PluginInterface {
  /// Unique identifier for the plugin
  String get id;

  /// Display name of the plugin
  String get name;

  /// Description of what the plugin does
  String get description;

  /// Plugin version
  String get version;

  /// Icon to represent the plugin in the UI
  IconData get icon;

  /// Whether the plugin is currently enabled
  bool get isEnabled;
  set isEnabled(bool value);

  /// Initialize the plugin
  Future<bool> initialize();

  /// Clean up resources when plugin is disabled or app is closing
  Future<void> dispose();

  /// Get the settings widget for this plugin
  Widget buildSettingsWidget(BuildContext context);

  /// Get the main widget for this plugin to be displayed in the app
  Widget? buildWidget(BuildContext context);

  /// Handle incoming data from the app
  Future<void> handleData(Map<String, dynamic> data);

  /// Get data from the plugin
  Future<Map<String, dynamic>> getData();
}
