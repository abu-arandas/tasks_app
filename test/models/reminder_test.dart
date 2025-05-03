import 'package:flutter_test/flutter_test.dart';
import 'package:tasks_app/models/reminder.dart';

void main() {
  group('Reminder Model Tests', () {
    test('Reminder creation with required fields only', () {
      final now = DateTime.now();
      final reminder = Reminder(
        id: 'reminder-id',
        taskId: 'task-id',
        reminderTime: now,
      );

      expect(reminder.id, 'reminder-id');
      expect(reminder.taskId, 'task-id');
      expect(reminder.reminderTime, now);
      expect(reminder.isRepeating, false);
      expect(reminder.repeatPattern, null);
      expect(reminder.isDismissed, false);
      expect(reminder.isSnoozing, false);
      expect(reminder.snoozeUntil, null);
    });

    test('Reminder creation with all fields', () {
      final now = DateTime.now();
      final snoozeUntil = now.add(const Duration(minutes: 10));
      final reminder = Reminder(
        id: 'reminder-id',
        taskId: 'task-id',
        reminderTime: now,
        isRepeating: true,
        repeatPattern: 'daily',
        isDismissed: true,
        isSnoozing: true,
        snoozeUntil: snoozeUntil,
      );

      expect(reminder.id, 'reminder-id');
      expect(reminder.taskId, 'task-id');
      expect(reminder.reminderTime, now);
      expect(reminder.isRepeating, true);
      expect(reminder.repeatPattern, 'daily');
      expect(reminder.isDismissed, true);
      expect(reminder.isSnoozing, true);
      expect(reminder.snoozeUntil, snoozeUntil);
    });

    test('Reminder.fromJson creates a Reminder correctly', () {
      final now = DateTime.now();
      final nowString = now.toIso8601String();
      final snoozeUntil = now.add(const Duration(minutes: 10));
      final snoozeUntilString = snoozeUntil.toIso8601String();

      final json = {
        'id': 'reminder-id',
        'taskId': 'task-id',
        'reminderTime': nowString,
        'isRepeating': true,
        'repeatPattern': 'daily',
        'isDismissed': true,
        'isSnoozing': true,
        'snoozeUntil': snoozeUntilString,
      };

      final reminder = Reminder.fromJson(json);

      expect(reminder.id, 'reminder-id');
      expect(reminder.taskId, 'task-id');
      expect(reminder.reminderTime.toIso8601String(), nowString);
      expect(reminder.isRepeating, true);
      expect(reminder.repeatPattern, 'daily');
      expect(reminder.isDismissed, true);
      expect(reminder.isSnoozing, true);
      expect(reminder.snoozeUntil?.toIso8601String(), snoozeUntilString);
    });

    test('Reminder.toJson converts a Reminder to JSON correctly', () {
      final now = DateTime.now();
      final snoozeUntil = now.add(const Duration(minutes: 10));
      final reminder = Reminder(
        id: 'reminder-id',
        taskId: 'task-id',
        reminderTime: now,
        isRepeating: true,
        repeatPattern: 'daily',
        isDismissed: true,
        isSnoozing: true,
        snoozeUntil: snoozeUntil,
      );

      final json = reminder.toJson();

      expect(json['id'], 'reminder-id');
      expect(json['taskId'], 'task-id');
      expect(json['reminderTime'], now.toIso8601String());
      expect(json['isRepeating'], true);
      expect(json['repeatPattern'], 'daily');
      expect(json['isDismissed'], true);
      expect(json['isSnoozing'], true);
      expect(json['snoozeUntil'], snoozeUntil.toIso8601String());
    });

    test('Reminder.copyWith creates a new Reminder with updated fields', () {
      final now = DateTime.now();
      final original = Reminder(
        id: 'reminder-id',
        taskId: 'task-id',
        reminderTime: now,
      );

      final newTime = now.add(const Duration(hours: 1));
      final snoozeUntil = now.add(const Duration(minutes: 10));
      final updated = original.copyWith(
        reminderTime: newTime,
        isRepeating: true,
        repeatPattern: 'weekly',
        isSnoozing: true,
        snoozeUntil: snoozeUntil,
      );

      // Original should be unchanged
      expect(original.reminderTime, now);
      expect(original.isRepeating, false);
      expect(original.repeatPattern, null);
      expect(original.isSnoozing, false);
      expect(original.snoozeUntil, null);

      // Updated should have new values
      expect(updated.id, 'reminder-id'); // Unchanged
      expect(updated.taskId, 'task-id'); // Unchanged
      expect(updated.reminderTime, newTime);
      expect(updated.isRepeating, true);
      expect(updated.repeatPattern, 'weekly');
      expect(updated.isSnoozing, true);
      expect(updated.snoozeUntil, snoozeUntil);
    });
  });
}
