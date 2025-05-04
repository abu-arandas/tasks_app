import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import '../controllers/task_controller.dart';
import '../controllers/tag_controller.dart';
import '../models/task.dart';
import '../models/tag.dart';
import '../utils/error_handler.dart';

class BackupService extends GetxController {
  final TaskController _taskController = Get.find<TaskController>();
  final TagController _tagController = Get.find<TagController>();
  final ErrorHandler _errorHandler = Get.find<ErrorHandler>();

  // Create a backup of all tasks and tags
  Future<void> createBackup(BuildContext context) async {
    try {
      // Prepare backup data
      final Map<String, dynamic> backupData = {
        'tasks': _taskController.tasks.map((task) => task.toJson()).toList(),
        'tags': _tagController.tags.map((tag) => tag.toJson()).toList(),
        'backup_date': DateTime.now().toIso8601String(),
        'app_version': '1.0.0',
      };

      // Convert to JSON
      final String jsonData = jsonEncode(backupData);

      // Get the documents directory
      final Directory? directory = await getExternalStorageDirectory();
      if (directory == null) {
        _errorHandler.showErrorSnackbar('Backup Failed', 'Could not access storage directory');
        return;
      }

      // Create backup filename with timestamp
      final String timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').replaceAll('.', '-');
      final String fileName = 'tasks_backup_$timestamp.json';
      final String filePath = '${directory.path}/$fileName';

      // Write the file
      final File file = File(filePath);
      await file.writeAsString(jsonData);

      // Show success message
      _errorHandler.showSuccessSnackbar(
        'Backup Created',
        'Backup saved to: $filePath',
      );
    } catch (e) {
      _errorHandler.showErrorSnackbar('Failed to create backup', e.toString());
    }
  }

  // Restore from a backup file
  Future<void> restoreBackup(BuildContext context) async {
    try {
      // Pick a file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        // User canceled the picker
        return;
      }

      final String? filePath = result.files.single.path;
      if (filePath == null) {
        _errorHandler.showErrorSnackbar('Restore Failed', 'Could not access the selected file');
        return;
      }

      // Read the file
      final File file = File(filePath);
      final String jsonData = await file.readAsString();

      // Parse the JSON
      final Map<String, dynamic> backupData = jsonDecode(jsonData);

      // Show confirmation dialog
      final bool confirm = await _showRestoreConfirmationDialog(backupData);
      if (!confirm) return;

      // Restore tasks
      if (backupData.containsKey('tasks')) {
        final List<dynamic> tasksJson = backupData['tasks'];
        final List<Task> tasks = tasksJson.map((json) => Task.fromJson(json)).toList();
        await _taskController.restoreTasksFromBackup(tasks);
      }

      // Restore tags
      if (backupData.containsKey('tags')) {
        final List<dynamic> tagsJson = backupData['tags'];
        final List<Tag> tags = tagsJson.map((json) => Tag.fromJson(json)).toList();
        await _tagController.restoreTags(tags);
      }

      // Show success message
      _errorHandler.showSuccessSnackbar(
        'Restore Completed',
        'Your data has been restored successfully',
      );
    } catch (e) {
      _errorHandler.showErrorSnackbar('Failed to restore backup', e.toString());
    }
  }

  // Show confirmation dialog before restoring
  Future<bool> _showRestoreConfirmationDialog(
    Map<String, dynamic> backupData,
  ) async {
    final String backupDate = backupData['backup_date'] ?? 'Unknown date';
    final int taskCount = (backupData['tasks'] as List?)?.length ?? 0;
    final int tagCount = (backupData['tags'] as List?)?.length ?? 0;

    return await showDialog<bool>(
          context: Get.context!,
          builder: (context) => AlertDialog(
            title: const Text('Restore Backup'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Backup date: ${DateTime.parse(backupDate).toLocal()}'),
                const SizedBox(height: 8),
                Text('Tasks: $taskCount'),
                Text('Tags: $tagCount'),
                const SizedBox(height: 16),
                const Text(
                  'Warning: This will replace all your current data. This action cannot be undone.',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Restore'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
