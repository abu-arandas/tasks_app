import 'package:mockito/mockito.dart';
import 'package:tasks_app/services/database_service.dart';
import 'package:tasks_app/models/task.dart';
import 'package:tasks_app/models/tag.dart';
import 'package:tasks_app/models/reminder.dart';

class MockDatabaseService extends Mock implements DatabaseService {
  final List<Task> _tasks = [];
  final List<Tag> _tags = [];
  final List<Reminder> _reminders = [];

  @override
  Future<List<Task>> getTasks() async {
    return _tasks;
  }

  @override
  Future<void> insertTask(Task task) async {
    _tasks.add(task);
  }

  @override
  Future<void> updateTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((task) => task.id == id);
  }

  @override
  Future<List<Tag>> getTags() async {
    return _tags;
  }

  @override
  Future<void> insertTag(Tag tag) async {
    _tags.add(tag);
  }

  @override
  Future<void> updateTag(Tag tag) async {
    final index = _tags.indexWhere((t) => t.id == tag.id);
    if (index != -1) {
      _tags[index] = tag;
    }
  }

  @override
  Future<void> deleteTag(String id) async {
    _tags.removeWhere((tag) => tag.id == id);
  }

  @override
  Future<List<Reminder>> getReminders() async {
    return _reminders;
  }

  @override
  Future<void> insertReminder(Reminder reminder) async {
    _reminders.add(reminder);
  }

  @override
  Future<void> updateReminder(Reminder reminder) async {
    final index = _reminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      _reminders[index] = reminder;
    }
  }

  @override
  Future<void> deleteReminder(String id) async {
    _reminders.removeWhere((reminder) => reminder.id == id);
  }

  @override
  Future<void> logChange(String entityType, String entityId, String changeType, String data) async {
    // Mock implementation - do nothing
  }

  // Helper methods for testing
  void addMockTask(Task task) {
    _tasks.add(task);
  }

  void addMockTag(Tag tag) {
    _tags.add(tag);
  }

  void addMockReminder(Reminder reminder) {
    _reminders.add(reminder);
  }

  void clearAll() {
    _tasks.clear();
    _tags.clear();
    _reminders.clear();
  }
}
