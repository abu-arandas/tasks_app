import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/reminder.dart';
import '../services/database_service.dart';

class ReminderController extends GetxController {
  final DatabaseService _databaseService = DatabaseService();
  final RxList<Reminder> reminders = <Reminder>[].obs;
  final RxBool isLoading = false.obs;
  final Uuid _uuid = const Uuid();

  @override
  void onInit() {
    super.onInit();
    fetchReminders();
  }

  // Fetch all reminders from the database
  Future<void> fetchReminders() async {
    isLoading.value = true;
    try {
      reminders.value = await _databaseService.getReminders();
    } catch (e) {
      print('Error fetching reminders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Add a new reminder
  Future<void> addReminder(String taskId, DateTime reminderTime,
      {bool isRepeating = false, String? repeatPattern}) async {
    final reminder = Reminder(
      id: _uuid.v4(),
      taskId: taskId,
      reminderTime: reminderTime,
      isRepeating: isRepeating,
      repeatPattern: repeatPattern,
    );

    try {
      await _databaseService.insertReminder(reminder);
      await _databaseService.logChange('reminder', reminder.id, 'create', reminder.toJson().toString());
      reminders.add(reminder);

      // TODO: Schedule local notification for this reminder
    } catch (e) {
      print('Error adding reminder: $e');
    }
  }

  // Update an existing reminder
  Future<void> updateReminder(Reminder reminder) async {
    try {
      await _databaseService.updateReminder(reminder);
      await _databaseService.logChange('reminder', reminder.id, 'update', reminder.toJson().toString());

      final index = reminders.indexWhere((r) => r.id == reminder.id);
      if (index != -1) {
        reminders[index] = reminder;
      }

      // TODO: Update scheduled notification for this reminder
    } catch (e) {
      print('Error updating reminder: $e');
    }
  }

  // Delete a reminder
  Future<void> deleteReminder(String id) async {
    try {
      await _databaseService.deleteReminder(id);
      await _databaseService.logChange('reminder', id, 'delete', '{"id": "$id"}');
      reminders.removeWhere((reminder) => reminder.id == id);

      // TODO: Cancel scheduled notification for this reminder
    } catch (e) {
      print('Error deleting reminder: $e');
    }
  }

  // Get reminders for a specific task
  List<Reminder> getRemindersForTask(String taskId) {
    return reminders.where((reminder) => reminder.taskId == taskId).toList();
  }

  // Snooze a reminder
  Future<void> snoozeReminder(String id, Duration snoozeDuration) async {
    final index = reminders.indexWhere((reminder) => reminder.id == id);
    if (index == -1) return;

    final reminder = reminders[index];
    final snoozeUntil = DateTime.now().add(snoozeDuration);
    final updatedReminder = reminder.copyWith(
      isSnoozing: true,
      snoozeUntil: snoozeUntil,
    );

    try {
      await _databaseService.updateReminder(updatedReminder);
      await _databaseService.logChange('reminder', reminder.id, 'update', updatedReminder.toJson().toString());
      reminders[index] = updatedReminder;

      // TODO: Reschedule notification for the snoozed time
    } catch (e) {
      print('Error snoozing reminder: $e');
    }
  }

  // Dismiss a reminder
  Future<void> dismissReminder(String id) async {
    final index = reminders.indexWhere((reminder) => reminder.id == id);
    if (index == -1) return;

    final reminder = reminders[index];
    final updatedReminder = reminder.copyWith(isDismissed: true);

    try {
      await _databaseService.updateReminder(updatedReminder);
      await _databaseService.logChange('reminder', reminder.id, 'update', updatedReminder.toJson().toString());
      reminders[index] = updatedReminder;

      // TODO: Cancel notification for this reminder
    } catch (e) {
      print('Error dismissing reminder: $e');
    }
  }
}
