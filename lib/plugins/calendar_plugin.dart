import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'plugin_interface.dart';
import '../models/task.dart';
import '../utils/error_handler.dart';

class CalendarPlugin implements PluginInterface {
  final ErrorHandler _errorHandler = Get.find<ErrorHandler>();
  bool _isEnabled = false;
  final RxList<Task> calendarEvents = <Task>[].obs;

  @override
  String get id => 'calendar_plugin';

  @override
  String get name => 'Calendar Integration';

  @override
  String get description => 'Integrates tasks with your device calendar';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.calendar_today;

  @override
  bool get isEnabled => _isEnabled;

  @override
  set isEnabled(bool value) {
    _isEnabled = value;
  }

  @override
  Future<bool> initialize() async {
    try {
      // Load plugin settings
      final prefs = await SharedPreferences.getInstance();
      _isEnabled = prefs.getBool('calendar_plugin_enabled') ?? false;

      // In a real implementation, we would:
      // 1. Request calendar permissions
      // 2. Initialize calendar API
      // 3. Load existing calendar events

      // For demonstration, we'll just simulate success
      await Future.delayed(const Duration(milliseconds: 500));

      return true;
    } catch (e) {
      _errorHandler.showErrorSnackbar('Calendar Plugin Init Failed', e.toString());
      return false;
    }
  }

  @override
  Future<void> dispose() async {
    // Clean up resources
    calendarEvents.clear();
  }

  @override
  Widget buildSettingsWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Calendar Settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Sync tasks to calendar'),
            subtitle: const Text('Add tasks with due dates to your calendar'),
            value: true, // This would be a real setting in a full implementation
            onChanged: (value) {
              // Save setting
            },
          ),
          SwitchListTile(
            title: const Text('Show calendar events as tasks'),
            subtitle: const Text('Import calendar events into your task list'),
            value: false, // This would be a real setting in a full implementation
            onChanged: (value) {
              // Save setting
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // This would trigger a manual sync in a real implementation
              _errorHandler.showSuccessSnackbar('Calendar Sync', 'Calendar synchronized successfully');
            },
            child: const Text('Sync Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget? buildWidget(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Text(
                  'Upcoming Calendar Events',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('No upcoming events'),
            // In a real implementation, we would show actual calendar events here
          ],
        ),
      ),
    );
  }

  @override
  Future<void> handleData(Map<String, dynamic> data) async {
    // Process incoming data from the app
    if (data.containsKey('task') && data['action'] == 'add_to_calendar') {
      final task = Task.fromJson(data['task']);
      if (task.dueDate != null) {
        // In a real implementation, we would add this task to the calendar
        calendarEvents.add(task);
      }
    }
  }

  @override
  Future<Map<String, dynamic>> getData() async {
    // Return data to the app
    return {
      'calendar_events': calendarEvents.map((task) => task.toJson()).toList(),
    };
  }

  // Calendar-specific methods

  Future<bool> addTaskToCalendar(Task task) async {
    if (task.dueDate == null) {
      return false;
    }

    try {
      // In a real implementation, we would:
      // 1. Convert the task to a calendar event
      // 2. Add it to the device calendar
      // 3. Store the calendar event ID with the task

      // For demonstration, we'll just add it to our local list
      calendarEvents.add(task);

      return true;
    } catch (e) {
      _errorHandler.showErrorSnackbar('Add to Calendar Failed', e.toString());
      return false;
    }
  }

  Future<bool> removeTaskFromCalendar(Task task) async {
    try {
      // In a real implementation, we would:
      // 1. Find the calendar event associated with this task
      // 2. Remove it from the device calendar

      // For demonstration, we'll just remove it from our local list
      calendarEvents.removeWhere((t) => t.id == task.id);

      return true;
    } catch (e) {
      _errorHandler.showErrorSnackbar('Remove from Calendar Failed', e.toString());
      return false;
    }
  }
}
