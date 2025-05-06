import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../plugins/plugin_interface.dart';
import '../services/ml_service.dart';
import '../controllers/task_controller.dart';
import '../utils/error_handler.dart';

/// A plugin that uses ML to provide smart task suggestions to users
class SmartSuggestionsPlugin implements PluginInterface {
  final MLService _mlService = Get.find<MLService>();
  final TaskController _taskController = Get.find<TaskController>();
  final ErrorHandler errorHandler = Get.find<ErrorHandler>();

  bool _isEnabled = false;
  final RxList<Map<String, dynamic>> _suggestions = <Map<String, dynamic>>[].obs;
  final RxBool _isLoading = false.obs;

  @override
  String get id => 'smart_suggestions';

  @override
  String get name => 'Smart Suggestions';

  @override
  String get description => 'Uses machine learning to suggest tasks based on your patterns';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.lightbulb_outline;

  @override
  bool get isEnabled => _isEnabled;

  @override
  set isEnabled(bool value) {
    _isEnabled = value;
  }

  @override
  Future<bool> initialize() async {
    try {
      // Check if ML model is loaded
      if (!_mlService.isModelLoaded.value) {
        // Wait for model to load
        await Future.delayed(const Duration(seconds: 2));
        if (!_mlService.isModelLoaded.value) {
          return false;
        }
      }

      // Generate initial suggestions
      await refreshSuggestions();
      return true;
    } catch (e) {
      errorHandler.showErrorSnackbar('Failed to initialize Smart Suggestions plugin', e.toString());
      return false;
    }
  }

  @override
  Future<void> dispose() async {
    _suggestions.clear();
  }

  @override
  Widget buildSettingsWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Smart Suggestions Settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        SwitchListTile(
          title: const Text('Enable Automatic Suggestions'),
          subtitle: const Text('Automatically generate suggestions when you open the app'),
          value: _autoSuggest.value,
          onChanged: (value) {
            _autoSuggest.value = value;
            _saveSettings();
          },
        ),
        ListTile(
          title: const Text('Suggestion Frequency'),
          subtitle: const Text('How often to generate new suggestions'),
          trailing: DropdownButton<String>(
            value: _suggestionFrequency.value,
            onChanged: (String? newValue) {
              if (newValue != null) {
                _suggestionFrequency.value = newValue;
                _saveSettings();
              }
            },
            items: <String>['Daily', 'Weekly', 'Monthly'].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () async {
              await refreshSuggestions();
              Get.snackbar(
                'Suggestions Updated',
                'New task suggestions have been generated',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Refresh Suggestions Now'),
          ),
        ),
      ],
    );
  }

  @override
  Widget? buildWidget(BuildContext context) {
    if (!isEnabled) return null;

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Suggested Tasks',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Obx(
                  () => _isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: refreshSuggestions,
                        ),
                ),
              ],
            ),
          ),
          Obx(() {
            if (_suggestions.isEmpty && !_isLoading.value) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No suggestions available. Try refreshing.'),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                return ListTile(
                  title: Text(suggestion['title']),
                  subtitle: Text(suggestion['reason']),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _addSuggestedTask(suggestion),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  @override
  Future<void> handleData(Map<String, dynamic> data) async {
    // Handle incoming data from the app
    if (data.containsKey('refresh_suggestions')) {
      await refreshSuggestions();
    }
  }

  @override
  Future<Map<String, dynamic>> getData() async {
    // Return plugin data to the app
    return {
      'suggestions': _suggestions,
      'last_updated': DateTime.now().toIso8601String(),
    };
  }

  // Private methods
  final RxBool _autoSuggest = true.obs;
  final RxString _suggestionFrequency = 'Daily'.obs;

  Future<void> _saveSettings() async {
    // In a real implementation, save settings to SharedPreferences
  }

  Future<void> refreshSuggestions() async {
    try {
      _isLoading.value = true;
      final newSuggestions = await _mlService.generateTaskSuggestions();
      _suggestions.assignAll(newSuggestions);
    } catch (e) {
      errorHandler.showErrorSnackbar('Failed to refresh suggestions', e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  void _addSuggestedTask(Map<String, dynamic> suggestion) {
    _taskController.addTask(
      suggestion['title'],
      description: suggestion['description'] ?? '',
      dueDate: suggestion['dueDate'] ?? DateTime.now(),
      priority: suggestion['priority'] ?? 'Medium',
      tagIds: suggestion['tagIds'] ?? [],
    );

    Get.snackbar(
      'Task Added',
      'The suggested task has been added to your list',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
