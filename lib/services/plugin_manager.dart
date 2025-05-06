import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../plugins/plugin_interface.dart';
import '../plugins/smart_suggestions_plugin.dart';
import '../utils/error_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PluginManager extends GetxController {
  final ErrorHandler _errorHandler = Get.find<ErrorHandler>();
  final RxList<PluginInterface> plugins = <PluginInterface>[].obs;
  final RxList<PluginInterface> enabledPlugins = <PluginInterface>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadPlugins();
  }

  @override
  void onClose() {
    // Dispose all enabled plugins
    for (var plugin in enabledPlugins) {
      plugin.dispose();
    }
    super.onClose();
  }

  // Load all available plugins
  Future<void> _loadPlugins() async {
    try {
      // In a real implementation, this would dynamically load plugins
      // For now, we'll manually register the built-in plugins
      
      // Register the Smart Suggestions plugin
      final smartSuggestionsPlugin = SmartSuggestionsPlugin();
      await registerPlugin(smartSuggestionsPlugin);

      // Load plugin enabled states from preferences
      final prefs = await SharedPreferences.getInstance();
      final enabledPluginIds = prefs.getStringList('enabled_plugins') ?? [];

      // Update enabled state based on saved preferences
      for (var plugin in plugins) {
        if (enabledPluginIds.contains(plugin.id)) {
          plugin.isEnabled = true;
          if (await plugin.initialize()) {
            enabledPlugins.add(plugin);
          }
        }
      }
    } catch (e) {
      _errorHandler.showErrorSnackbar('Plugin Loading Failed', e.toString());
    }
  }

  // Register a new plugin
  Future<bool> registerPlugin(PluginInterface plugin) async {
    try {
      // Check if plugin with same ID already exists
      if (plugins.any((p) => p.id == plugin.id)) {
        _errorHandler.showErrorSnackbar(
            'Plugin Registration Failed', 'A plugin with ID ${plugin.id} is already registered');
        return false;
      }

      // Add to available plugins
      plugins.add(plugin);

      // If plugin should be enabled, initialize it
      if (plugin.isEnabled) {
        if (await plugin.initialize()) {
          enabledPlugins.add(plugin);
          await _saveEnabledPlugins();
          return true;
        } else {
          plugin.isEnabled = false;
          return false;
        }
      }

      return true;
    } catch (e) {
      _errorHandler.showErrorSnackbar('Plugin Registration Failed', e.toString());
      return false;
    }
  }

  // Enable a plugin
  Future<bool> enablePlugin(String pluginId) async {
    try {
      final plugin = plugins.firstWhere((p) => p.id == pluginId, orElse: () => throw Exception('Plugin not found'));

      if (plugin.isEnabled) return true; // Already enabled

      // Initialize the plugin
      if (await plugin.initialize()) {
        plugin.isEnabled = true;
        enabledPlugins.add(plugin);
        await _saveEnabledPlugins();
        return true;
      }

      return false;
    } catch (e) {
      _errorHandler.showErrorSnackbar('Enable Plugin Failed', e.toString());
      return false;
    }
  }

  // Disable a plugin
  Future<bool> disablePlugin(String pluginId) async {
    try {
      final plugin = enabledPlugins.firstWhere((p) => p.id == pluginId,
          orElse: () => throw Exception('Plugin not found or not enabled'));

      // Dispose the plugin
      await plugin.dispose();
      plugin.isEnabled = false;
      enabledPlugins.remove(plugin);
      await _saveEnabledPlugins();
      return true;
    } catch (e) {
      _errorHandler.showErrorSnackbar('Disable Plugin Failed', e.toString());
      return false;
    }
  }

  // Save the list of enabled plugin IDs
  Future<void> _saveEnabledPlugins() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabledIds = enabledPlugins.map((p) => p.id).toList();
      await prefs.setStringList('enabled_plugins', enabledIds);
    } catch (e) {
      _errorHandler.showErrorSnackbar('Save Plugin Settings Failed', e.toString());
    }
  }

  // Get a plugin by ID
  PluginInterface? getPlugin(String pluginId) {
    try {
      return plugins.firstWhere((p) => p.id == pluginId);
    } catch (e) {
      return null;
    }
  }

  // Send data to all enabled plugins
  Future<void> broadcastToPlugins(Map<String, dynamic> data) async {
    for (var plugin in enabledPlugins) {
      try {
        await plugin.handleData(data);
      } catch (e) {
        _errorHandler.showErrorSnackbar(
            'Plugin Communication Failed', 'Error sending data to ${plugin.name}: ${e.toString()}');
      }
    }
  }

  // Get widgets from all enabled plugins
  List<Widget> getPluginWidgets(BuildContext context) {
    return enabledPlugins
        .map((plugin) => plugin.buildWidget(context))
        .where((widget) => widget != null)
        .cast<Widget>()
        .toList();
  }
}
