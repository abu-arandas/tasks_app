import 'package:get/get.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/task.dart';
import '../utils/error_handler.dart';
import 'database_service.dart';

class MLService extends GetxController {
  final DatabaseService _databaseService = DatabaseService();
  final ErrorHandler _errorHandler = Get.find<ErrorHandler>();

  Interpreter? _interpreter;
  final RxBool isModelLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadModel();
  }

  @override
  void onClose() {
    _interpreter?.close();
    super.onClose();
  }

  // Load the TensorFlow Lite model
  Future<void> _loadModel() async {
    try {
      // In a real app, you would have a pre-trained model file
      // For now, we'll create a placeholder for future implementation
      // _interpreter = await Interpreter.fromAsset('assets/task_suggestion_model.tflite');

      // Simulate model loading for demonstration
      await Future.delayed(const Duration(seconds: 1));
      isModelLoaded.value = true;

      _errorHandler.showSuccessSnackbar('ML Model Loaded', 'Task suggestion model is ready');
    } catch (e) {
      _errorHandler.showErrorSnackbar('Model Loading Failed', e.toString());
      isModelLoaded.value = false;
    }
  }

  // Generate task suggestions based on user history
  Future<List<Map<String, dynamic>>> generateTaskSuggestions() async {
    if (!isModelLoaded.value) {
      await _loadModel();
      if (!isModelLoaded.value) {
        return [];
      }
    }

    try {
      // Get user's task history
      final tasks = await _databaseService.getTasks();

      // In a real implementation, we would:
      // 1. Extract features from tasks (completion patterns, time of day, etc.)
      // 2. Run these features through the TensorFlow model
      // 3. Process the output to generate suggestions

      // For now, we'll use a rule-based approach to simulate ML suggestions
      return _generateSimulatedSuggestions(tasks);
    } catch (e) {
      _errorHandler.showErrorSnackbar('Suggestion Generation Failed', e.toString());
      return [];
    }
  }

  // Simulate ML-based suggestions using rule-based logic
  List<Map<String, dynamic>> _generateSimulatedSuggestions(List<Task> tasks) {
    final suggestions = <Map<String, dynamic>>[];

    // Only proceed if we have enough task history
    if (tasks.isEmpty) {
      return suggestions;
    }

    // Analyze task patterns
    final completedTasks = tasks.where((task) => task.isCompleted).toList();

    // Get most common tags
    final tagFrequency = <String, int>{};
    for (var task in tasks) {
      for (var tagId in task.tagIds) {
        tagFrequency[tagId] = (tagFrequency[tagId] ?? 0) + 1;
      }
    }

    // Sort tags by frequency
    final sortedTags = tagFrequency.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    // Get most common words in titles
    final titleWords = <String, int>{};
    for (var task in tasks) {
      final words = task.title.toLowerCase().split(' ');
      for (var word in words) {
        if (word.length > 3) {
          // Ignore short words
          titleWords[word] = (titleWords[word] ?? 0) + 1;
        }
      }
    }

    // Sort words by frequency
    final sortedWords = titleWords.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    // Generate suggestions based on patterns

    // Suggestion 1: Regular task based on most common tag
    if (sortedTags.isNotEmpty) {
      suggestions.add({
        'title': 'New ${sortedTags.first.key} task',
        'priority': 'medium',
        'tagIds': [sortedTags.first.key],
        'confidence': 0.85,
      });
    }

    // Suggestion 2: Based on most common words in titles
    if (sortedWords.length >= 2) {
      suggestions.add({
        'title': '${sortedWords[0].key.toUpperCase()} ${sortedWords[1].key}',
        'priority': 'high',
        'tagIds': sortedTags.isNotEmpty ? [sortedTags.first.key] : [],
        'confidence': 0.75,
      });
    }

    // Suggestion 3: Follow-up to recently completed task
    if (completedTasks.isNotEmpty) {
      final recentCompleted = completedTasks.reduce((a, b) => a.updatedAt.isAfter(b.updatedAt) ? a : b);

      suggestions.add({
        'title': 'Follow up on: ${recentCompleted.title}',
        'priority': recentCompleted.priority,
        'tagIds': recentCompleted.tagIds,
        'confidence': 0.65,
      });
    }

    return suggestions;
  }

  // Analyze task completion patterns
  Map<String, dynamic> analyzeCompletionPatterns(List<Task> tasks) {
    if (tasks.isEmpty) {
      return {};
    }

    // Calculate completion rate by priority
    final priorityCompletion = <String, Map<String, dynamic>>{};
    for (var task in tasks) {
      final priority = task.priority ?? 'medium';
      if (!priorityCompletion.containsKey(priority)) {
        priorityCompletion[priority] = {
          'total': 0,
          'completed': 0,
        };
      }

      priorityCompletion[priority]!['total'] = priorityCompletion[priority]!['total'] + 1;
      if (task.isCompleted) {
        priorityCompletion[priority]!['completed'] = priorityCompletion[priority]!['completed'] + 1;
      }
    }

    // Calculate completion rates
    for (var priority in priorityCompletion.keys) {
      final total = priorityCompletion[priority]!['total'];
      final completed = priorityCompletion[priority]!['completed'];
      priorityCompletion[priority]!['rate'] = total > 0 ? completed / total : 0;
    }

    // Calculate average time to completion
    final completedWithDates = tasks.where((task) => task.isCompleted).toList();

    int totalDays = 0;
    for (var task in completedWithDates) {
      final days = task.updatedAt.difference(task.createdAt).inDays;
      totalDays += days;
    }

    final avgCompletionDays = completedWithDates.isNotEmpty ? totalDays / completedWithDates.length : 0;

    return {
      'priorityCompletion': priorityCompletion,
      'avgCompletionDays': avgCompletionDays,
      'totalTasks': tasks.length,
      'completedTasks': tasks.where((task) => task.isCompleted).length,
    };
  }
}

// Extension to capitalize first letter of a string
extension StringExtension on String {
  String get capitalize => '${this[0].toUpperCase()}${substring(1)}';
}
