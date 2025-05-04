import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../services/database_service.dart';
import '../utils/error_handler.dart';
import '../views/screens/task_detail_screen.dart';
import '../views/widgets/add_task_dialog.dart';

class TaskController extends GetxController {
  final DatabaseService _databaseService = DatabaseService();
  final RxList<Task> tasks = <Task>[].obs;
  final RxList<Task> filteredTasks = <Task>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isFiltered = false.obs;
  final RxString searchQuery = ''.obs;
  final Uuid _uuid = const Uuid();
  final ErrorHandler _errorHandler = ErrorHandler();

  // Method to show add task dialog
  void showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddTaskDialog(),
    );
  }

  // Method to navigate to task detail
  void navigateToTaskDetail(Task task) {
    Get.to(() => TaskDetailScreen(task: task));
  }

  // Restore tasks from backup
  Future<void> restoreTasksFromBackup(List<Task> backupTasks) async {
    isLoading.value = true;
    try {
      // Clear existing tasks
      await _databaseService.clearAllTasks();

      // Insert all tasks from backup
      for (final task in backupTasks) {
        await _databaseService.insertTask(task);
      }

      // Refresh tasks list
      await fetchTasks();
      _errorHandler.log('Restored ${backupTasks.length} tasks from backup', level: ErrorHandler.info);
    } catch (e, stackTrace) {
      _errorHandler.handleDatabaseError(e, customMessage: 'Failed to restore tasks from backup');
      _errorHandler.log('Error restoring tasks from backup',
          level: ErrorHandler.error, errors: e, stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchTasks();
  }

  // Fetch all tasks from the database
  Future<void> fetchTasks() async {
    isLoading.value = true;
    try {
      tasks.value = await _databaseService.getTasks();
      _applyCurrentFilters();
      _errorHandler.log('Successfully fetched ${tasks.length} tasks', level: ErrorHandler.info);
    } catch (e, stackTrace) {
      _errorHandler.handleDatabaseError(e, customMessage: 'Failed to load tasks');
      _errorHandler.log('Error fetching tasks', level: ErrorHandler.error, errors: e, stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  // Apply filters to tasks
  void applyFilters({
    bool showCompleted = true,
    bool showIncomplete = true,
    String? priority,
    DateTime? dueDate,
  }) {
    isFiltered.value = true;

    filteredTasks.value = tasks.where((task) {
      // Filter by completion status
      if (!(showCompleted && task.isCompleted) && !(showIncomplete && !task.isCompleted)) {
        return false;
      }

      // Filter by priority
      if (priority != null && task.priority != priority) {
        return false;
      }

      // Filter by due date
      if (dueDate != null && task.dueDate != null) {
        final taskDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
        final filterDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
        if (taskDate != filterDate) {
          return false;
        }
      }

      // Apply search query if exists
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        return task.title.toLowerCase().contains(query) || (task.description?.toLowerCase().contains(query) ?? false);
      }

      return true;
    }).toList();

    _errorHandler.log(
        'Applied filters: showCompleted=$showCompleted, showIncomplete=$showIncomplete, priority=$priority, dueDate=$dueDate',
        level: ErrorHandler.info);
  }

  // Reset all filters
  void resetFilters() {
    isFiltered.value = false;
    searchQuery.value = '';
    filteredTasks.value = tasks;
    _errorHandler.log('Filters reset', level: ErrorHandler.info);
  }

  // Search tasks by query
  void searchTasks(String query) {
    searchQuery.value = query;
    _applyCurrentFilters();
  }

  // Apply current filters (internal method)
  void _applyCurrentFilters() {
    if (isFiltered.value) {
      // Re-apply existing filters
      applyFilters();
    } else if (searchQuery.value.isNotEmpty) {
      // Only apply search
      filteredTasks.value = tasks.where((task) {
        final query = searchQuery.value.toLowerCase();
        return task.title.toLowerCase().contains(query) || (task.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    } else {
      // No filters or search
      filteredTasks.value = tasks;
    }
  }

  // Add a new task
  Future<void> addTask(String title,
      {String? description, DateTime? dueDate, String? priority, List<String>? tagIds}) async {
    final now = DateTime.now();
    final task = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority ?? 'medium',
      tagIds: tagIds ?? [],
      createdAt: now,
      updatedAt: now,
    );

    try {
      isLoading.value = true;
      await _databaseService.insertTask(task);
      await _databaseService.logChange('task', task.id, 'create', task.toJson().toString());
      tasks.add(task);
      _applyCurrentFilters();
      _errorHandler.showSuccessSnackbar('Success', 'Task added successfully');
    } catch (e, stackTrace) {
      _errorHandler.handleDatabaseError(e, customMessage: 'Failed to add task');
      _errorHandler.log('Error adding task', level: ErrorHandler.error, errors: e, stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  // Update an existing task
  Future<void> updateTask(Task task) async {
    final updatedTask = task.copyWith(updatedAt: DateTime.now());

    try {
      isLoading.value = true;
      await _databaseService.updateTask(updatedTask);
      await _databaseService.logChange('task', task.id, 'update', updatedTask.toJson().toString());

      final index = tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        tasks[index] = updatedTask;
        _applyCurrentFilters();
        _applyCurrentFilters();
      }
      _errorHandler.showSuccessSnackbar('Success', 'Task updated successfully');
    } catch (e, stackTrace) {
      _errorHandler.handleDatabaseError(e, customMessage: 'Failed to update task');
      _errorHandler.log('Error updating task', level: ErrorHandler.error, errors: e, stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  // Toggle task completion status
  Future<void> toggleTaskCompletion(String id) async {
    final index = tasks.indexWhere((task) => task.id == id);
    if (index == -1) return;

    final task = tasks[index];
    final updatedTask = task.copyWith(
      isCompleted: !task.isCompleted,
      updatedAt: DateTime.now(),
    );

    try {
      isLoading.value = true;
      await _databaseService.updateTask(updatedTask);
      await _databaseService.logChange('task', task.id, 'update', updatedTask.toJson().toString());
      tasks[index] = updatedTask;
      _applyCurrentFilters();
      _errorHandler.showSuccessSnackbar(
          'Success', updatedTask.isCompleted ? 'Task marked as completed' : 'Task marked as incomplete');
    } catch (e, stackTrace) {
      _errorHandler.handleDatabaseError(e, customMessage: 'Failed to update task status');
      _errorHandler.log('Error toggling task completion', level: ErrorHandler.error, errors: e, stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  // Delete a task
  Future<void> deleteTask(String id) async {
    try {
      isLoading.value = true;
      await _databaseService.deleteTask(id);
      await _databaseService.logChange('task', id, 'delete', '{"id": "$id"}');
      tasks.removeWhere((task) => task.id == id);
      _applyCurrentFilters();
      _errorHandler.showSuccessSnackbar('Success', 'Task deleted successfully');
    } catch (e, stackTrace) {
      _errorHandler.handleDatabaseError(e, customMessage: 'Failed to delete task');
      _errorHandler.log('Error deleting task', level: ErrorHandler.error, errors: e, stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  // Filter tasks by completion status
  List<Task> getTasksByCompletionStatus(bool isCompleted) {
    return tasks.where((task) => task.isCompleted == isCompleted).toList();
  }

  // Filter tasks by tag
  List<Task> getTasksByTag(String tagId) {
    return tasks.where((task) => task.tagIds.contains(tagId)).toList();
  }

  // Filter tasks by priority
  List<Task> getTasksByPriority(String priority) {
    return tasks.where((task) => task.priority == priority).toList();
  }

  // Get tasks due today
  List<Task> getTasksDueToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return tasks.where((task) {
      if (task.dueDate == null) return false;
      final dueDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
      return dueDate.isAtSameMomentAs(today);
    }).toList();
  }

  // Get overdue tasks
  List<Task> getOverdueTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return tasks.where((task) {
      if (task.dueDate == null) return false;
      final dueDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
      return dueDate.isBefore(today) && !task.isCompleted;
    }).toList();
  }
}
