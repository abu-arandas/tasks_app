import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/reminder.dart';

import '../services/database_service.dart';
import '../utils/error_handler.dart';

class ReminderController extends GetxController {
  final DatabaseService _databaseService = DatabaseService();
  final RxList<Reminder> reminders = <Reminder>[].obs;
  final RxBool isLoading = false.obs;
  final Uuid _uuid = const Uuid();
  final ErrorHandler _errorHandler = Get.find<ErrorHandler>();

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
      _errorHandler.log('Successfully fetched ${reminders.length} reminders', level: ErrorHandler.info);
    } catch (e, stackTrace) {
      _errorHandler.handleDatabaseError(e, customMessage: 'Failed to load reminders');
      _errorHandler.log('Error fetching reminders', level: ErrorHandler.error, errors: e, stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  // Add a new reminder
  Future<void> addReminder(String taskId, DateTime reminderTime,
      {bool isRepeating = false, String? repeatPattern}) async {
    // Validate reminder time is in the future
    if (reminderTime.isBefore(DateTime.now())) {
      _errorHandler.handleValidationError('Reminder Time', 'Reminder time must be in the future');
      return;
    }

    // Validate repeat pattern if isRepeating is true
    if (isRepeating && (repeatPattern == null || repeatPattern.isEmpty)) {
      _errorHandler.handleValidationError('Repeat Pattern', 'Repeat pattern must be specified for recurring reminders');
      return;
    }

    isLoading.value = true;
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

      _errorHandler.showSuccessSnackbar('Success', 'Reminder added successfully');
    } catch (e, stackTrace) {
      _errorHandler.handleDatabaseError(e, customMessage: 'Failed to add reminder');
      _errorHandler.log('Error adding reminder', level: ErrorHandler.error, errors: e, stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  // Update an existing reminder
  Future<void> updateReminder(Reminder reminder) async {
    // Validate reminder time for non-dismissed reminders
    if (!reminder.isDismissed && reminder.reminderTime.isBefore(DateTime.now()) && !reminder.isSnoozing) {
      _errorHandler.handleValidationError('Reminder Time', 'Reminder time must be in the future');
      return;
    }

    // Validate repeat pattern if isRepeating is true
    if (reminder.isRepeating && (reminder.repeatPattern == null || reminder.repeatPattern!.isEmpty)) {
      _errorHandler.handleValidationError('Repeat Pattern', 'Repeat pattern must be specified for recurring reminders');
      return;
    }

    isLoading.value = true;
    try {
      await _databaseService.updateReminder(reminder);
      await _databaseService.logChange('reminder', reminder.id, 'update', reminder.toJson().toString());

      final index = reminders.indexWhere((r) => r.id == reminder.id);
      if (index != -1) {
        reminders[index] = reminder;
      }

      _errorHandler.showSuccessSnackbar('Success', 'Reminder updated successfully');
    } catch (e, stackTrace) {
      _errorHandler.handleDatabaseError(e, customMessage: 'Failed to update reminder');
      _errorHandler.log('Error updating reminder', level: ErrorHandler.error, errors: e, stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  // Delete a reminder
  Future<void> deleteReminder(String id) async {
    isLoading.value = true;
    try {
      await _databaseService.deleteReminder(id);
      await _databaseService.logChange('reminder', id, 'delete', '{"id": "$id"}');
      reminders.removeWhere((reminder) => reminder.id == id);
      _errorHandler.showSuccessSnackbar('Success', 'Reminder deleted successfully');
    } catch (e, stackTrace) {
      _errorHandler.handleDatabaseError(e, customMessage: 'Failed to delete reminder');
      _errorHandler.log('Error deleting reminder', level: ErrorHandler.error, errors: e, stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  // Get reminders for a specific task
  List<Reminder> getRemindersForTask(String taskId) {
    return reminders.where((reminder) => reminder.taskId == taskId).toList();
  }

  // Snooze a reminder
  Future<void> snoozeReminder(String id, Duration snoozeDuration) async {
    if (snoozeDuration.inMinutes < 1) {
      _errorHandler.handleValidationError('Snooze Duration', 'Snooze duration must be at least 1 minute');
      return;
    }

    final index = reminders.indexWhere((reminder) => reminder.id == id);
    if (index == -1) {
      _errorHandler.handleValidationError('Reminder', 'Reminder not found');
      return;
    }

    isLoading.value = true;
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

      _errorHandler.showSuccessSnackbar('Success', 'Reminder snoozed successfully');
    } catch (e, stackTrace) {
      _errorHandler.handleDatabaseError(e, customMessage: 'Failed to snooze reminder');
      _errorHandler.log('Error snoozing reminder', level: ErrorHandler.error, errors: e, stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  // Dismiss a reminder
  Future<void> dismissReminder(String id) async {
    final index = reminders.indexWhere((reminder) => reminder.id == id);
    if (index == -1) {
      _errorHandler.handleValidationError('Reminder', 'Reminder not found');
      return;
    }

    isLoading.value = true;
    final reminder = reminders[index];
    final updatedReminder = reminder.copyWith(isDismissed: true);

    try {
      await _databaseService.updateReminder(updatedReminder);
      await _databaseService.logChange('reminder', reminder.id, 'update', updatedReminder.toJson().toString());
      reminders[index] = updatedReminder;
      _errorHandler.showSuccessSnackbar('Success', 'Reminder dismissed');
    } catch (e, stackTrace) {
      _errorHandler.handleDatabaseError(e, customMessage: 'Failed to dismiss reminder');
      _errorHandler.log('Error dismissing reminder', level: ErrorHandler.error, errors: e, stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }
}
