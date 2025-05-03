import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../services/database_service.dart';

class TaskController extends GetxController {
  final DatabaseService _databaseService = DatabaseService();
  final RxList<Task> tasks = <Task>[].obs;
  final RxBool isLoading = false.obs;
  final Uuid _uuid = const Uuid();

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
    } catch (e) {
      print('Error fetching tasks: $e');
    } finally {
      isLoading.value = false;
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
      await _databaseService.insertTask(task);
      await _databaseService.logChange('task', task.id, 'create', task.toJson().toString());
      tasks.add(task);
    } catch (e) {
      print('Error adding task: $e');
    }
  }

  // Update an existing task
  Future<void> updateTask(Task task) async {
    final updatedTask = task.copyWith(updatedAt: DateTime.now());

    try {
      await _databaseService.updateTask(updatedTask);
      await _databaseService.logChange('task', task.id, 'update', updatedTask.toJson().toString());

      final index = tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        tasks[index] = updatedTask;
      }
    } catch (e) {
      print('Error updating task: $e');
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
      await _databaseService.updateTask(updatedTask);
      await _databaseService.logChange('task', task.id, 'update', updatedTask.toJson().toString());
      tasks[index] = updatedTask;
    } catch (e) {
      print('Error toggling task completion: $e');
    }
  }

  // Delete a task
  Future<void> deleteTask(String id) async {
    try {
      await _databaseService.deleteTask(id);
      await _databaseService.logChange('task', id, 'delete', '{"id": "$id"}');
      tasks.removeWhere((task) => task.id == id);
    } catch (e) {
      print('Error deleting task: $e');
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
