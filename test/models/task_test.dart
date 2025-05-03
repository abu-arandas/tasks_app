import 'package:flutter_test/flutter_test.dart';
import 'package:tasks_app/models/task.dart';

void main() {
  group('Task Model Tests', () {
    test('Task creation with required fields only', () {
      final now = DateTime.now();
      final task = Task(
        id: 'test-id',
        title: 'Test Task',
        createdAt: now,
        updatedAt: now,
      );

      expect(task.id, 'test-id');
      expect(task.title, 'Test Task');
      expect(task.isCompleted, false);
      expect(task.priority, 'medium');
      expect(task.tagIds, []);
      expect(task.isRecurring, false);
      expect(task.createdAt, now);
      expect(task.updatedAt, now);
    });

    test('Task creation with all fields', () {
      final now = DateTime.now();
      final dueDate = now.add(const Duration(days: 1));
      final task = Task(
        id: 'test-id',
        title: 'Test Task',
        description: 'Test Description',
        isCompleted: true,
        dueDate: dueDate,
        priority: 'high',
        tagIds: ['tag1', 'tag2'],
        isRecurring: true,
        recurrencePattern: 'daily',
        createdAt: now,
        updatedAt: now,
      );

      expect(task.id, 'test-id');
      expect(task.title, 'Test Task');
      expect(task.description, 'Test Description');
      expect(task.isCompleted, true);
      expect(task.dueDate, dueDate);
      expect(task.priority, 'high');
      expect(task.tagIds, ['tag1', 'tag2']);
      expect(task.isRecurring, true);
      expect(task.recurrencePattern, 'daily');
      expect(task.createdAt, now);
      expect(task.updatedAt, now);
    });

    test('Task.fromJson creates a Task correctly', () {
      final now = DateTime.now();
      final nowString = now.toIso8601String();
      final dueDate = now.add(const Duration(days: 1));
      final dueDateString = dueDate.toIso8601String();

      final json = {
        'id': 'test-id',
        'title': 'Test Task',
        'description': 'Test Description',
        'isCompleted': true,
        'dueDate': dueDateString,
        'priority': 'high',
        'tagIds': ['tag1', 'tag2'],
        'isRecurring': true,
        'recurrencePattern': 'daily',
        'createdAt': nowString,
        'updatedAt': nowString,
      };

      final task = Task.fromJson(json);

      expect(task.id, 'test-id');
      expect(task.title, 'Test Task');
      expect(task.description, 'Test Description');
      expect(task.isCompleted, true);
      expect(task.dueDate?.toIso8601String(), dueDateString);
      expect(task.priority, 'high');
      expect(task.tagIds, ['tag1', 'tag2']);
      expect(task.isRecurring, true);
      expect(task.recurrencePattern, 'daily');
      expect(task.createdAt.toIso8601String(), nowString);
      expect(task.updatedAt.toIso8601String(), nowString);
    });

    test('Task.toJson converts a Task to JSON correctly', () {
      final now = DateTime.now();
      final dueDate = now.add(const Duration(days: 1));
      final task = Task(
        id: 'test-id',
        title: 'Test Task',
        description: 'Test Description',
        isCompleted: true,
        dueDate: dueDate,
        priority: 'high',
        tagIds: ['tag1', 'tag2'],
        isRecurring: true,
        recurrencePattern: 'daily',
        createdAt: now,
        updatedAt: now,
      );

      final json = task.toJson();

      expect(json['id'], 'test-id');
      expect(json['title'], 'Test Task');
      expect(json['description'], 'Test Description');
      expect(json['isCompleted'], true);
      expect(json['dueDate'], dueDate.toIso8601String());
      expect(json['priority'], 'high');
      expect(json['tagIds'], ['tag1', 'tag2']);
      expect(json['isRecurring'], true);
      expect(json['recurrencePattern'], 'daily');
      expect(json['createdAt'], now.toIso8601String());
      expect(json['updatedAt'], now.toIso8601String());
    });

    test('Task.copyWith creates a new Task with updated fields', () {
      final now = DateTime.now();
      final original = Task(
        id: 'test-id',
        title: 'Test Task',
        createdAt: now,
        updatedAt: now,
      );

      final updated = original.copyWith(
        title: 'Updated Title',
        description: 'New Description',
        isCompleted: true,
      );

      // Original should be unchanged
      expect(original.title, 'Test Task');
      expect(original.description, null);
      expect(original.isCompleted, false);

      // Updated should have new values
      expect(updated.id, 'test-id'); // Unchanged
      expect(updated.title, 'Updated Title');
      expect(updated.description, 'New Description');
      expect(updated.isCompleted, true);
      expect(updated.createdAt, now); // Unchanged
    });
  });
}
