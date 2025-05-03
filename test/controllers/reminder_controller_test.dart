import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tasks_app/controllers/reminder_controller.dart';
import 'package:tasks_app/models/reminder.dart';
import '../helpers/mock_database_service.dart';

void main() {
  late ReminderController reminderController;
  late MockDatabaseService mockDatabaseService;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    Get.put(mockDatabaseService);
    reminderController = ReminderController();
  });

  tearDown(() {
    Get.reset();
  });

  group('ReminderController Tests', () {
    test('fetchReminders loads reminders from database', () async {
      // Arrange
      final now = DateTime.now();
      final reminder1 = Reminder(
        id: 'reminder-1',
        taskId: 'task-1',
        reminderTime: now,
      );
      final reminder2 = Reminder(
        id: 'reminder-2',
        taskId: 'task-2',
        reminderTime: now.add(const Duration(hours: 1)),
      );
      mockDatabaseService.addMockReminder(reminder1);
      mockDatabaseService.addMockReminder(reminder2);

      // Act
      await reminderController.fetchReminders();

      // Assert
      expect(reminderController.reminders.length, 2);
      expect(reminderController.reminders[0].id, 'reminder-1');
      expect(reminderController.reminders[1].id, 'reminder-2');
    });

    test('addReminder adds a reminder to the database and updates the list', () async {
      // Arrange
      final reminderTime = DateTime.now().add(const Duration(hours: 1));

      // Act
      await reminderController.addReminder(
        'task-1',
        reminderTime,
        isRepeating: true,
        repeatPattern: 'daily',
      );

      // Assert
      expect(reminderController.reminders.length, 1);
      expect(reminderController.reminders[0].taskId, 'task-1');
      expect(reminderController.reminders[0].reminderTime, reminderTime);
      expect(reminderController.reminders[0].isRepeating, true);
      expect(reminderController.reminders[0].repeatPattern, 'daily');
    });

    test('updateReminder updates a reminder in the database and in the list', () async {
      // Arrange
      final now = DateTime.now();
      final reminder = Reminder(
        id: 'reminder-1',
        taskId: 'task-1',
        reminderTime: now,
      );
      mockDatabaseService.addMockReminder(reminder);
      await reminderController.fetchReminders();

      // Create updated reminder
      final updatedTime = now.add(const Duration(hours: 2));
      final updatedReminder = reminder.copyWith(
        reminderTime: updatedTime,
        isRepeating: true,
        repeatPattern: 'weekly',
      );

      // Act
      await reminderController.updateReminder(updatedReminder);

      // Assert
      expect(reminderController.reminders.length, 1);
      expect(reminderController.reminders[0].reminderTime, updatedTime);
      expect(reminderController.reminders[0].isRepeating, true);
      expect(reminderController.reminders[0].repeatPattern, 'weekly');
    });

    test('deleteReminder removes a reminder from the database and from the list', () async {
      // Arrange
      final now = DateTime.now();
      final reminder = Reminder(
        id: 'reminder-1',
        taskId: 'task-1',
        reminderTime: now,
      );
      mockDatabaseService.addMockReminder(reminder);
      await reminderController.fetchReminders();
      expect(reminderController.reminders.length, 1);

      // Act
      await reminderController.deleteReminder('reminder-1');

      // Assert
      expect(reminderController.reminders.length, 0);
    });

    test('dismissReminder marks a reminder as dismissed', () async {
      // Arrange
      final now = DateTime.now();
      final reminder = Reminder(
        id: 'reminder-1',
        taskId: 'task-1',
        reminderTime: now,
        isDismissed: false,
      );
      mockDatabaseService.addMockReminder(reminder);
      await reminderController.fetchReminders();
      expect(reminderController.reminders[0].isDismissed, false);

      // Act
      await reminderController.dismissReminder('reminder-1');

      // Assert
      expect(reminderController.reminders[0].isDismissed, true);
    });

    test('snoozeReminder marks a reminder as snoozing with snooze time', () async {
      // Arrange
      final now = DateTime.now();
      final reminder = Reminder(
        id: 'reminder-1',
        taskId: 'task-1',
        reminderTime: now,
        isSnoozing: false,
      );
      mockDatabaseService.addMockReminder(reminder);
      await reminderController.fetchReminders();
      expect(reminderController.reminders[0].isSnoozing, false);

      // Act
      await reminderController.snoozeReminder(
        'reminder-1',
        const Duration(minutes: 10),
      ); // Snooze for 10 minutes

      // Assert
      expect(reminderController.reminders[0].isSnoozing, true);
      expect(reminderController.reminders[0].snoozeUntil, isNotNull);

      // Verify snooze time is approximately 10 minutes from now
      final snoozeTime = reminderController.reminders[0].snoozeUntil!;
      final expectedTime = now.add(const Duration(minutes: 10));

      // Allow a small tolerance for test execution time
      final difference = snoozeTime.difference(expectedTime).inSeconds.abs();
      expect(difference < 5, true); // Within 5 seconds of expected time
    });
  });
}
