import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tasks_app/controllers/task_controller.dart';
import 'package:tasks_app/models/task.dart';
import '../helpers/mock_database_service.dart';

void main() {
  late TaskController taskController;
  late MockDatabaseService mockDatabaseService;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    Get.put(mockDatabaseService);
    taskController = TaskController();
  });

  tearDown(() {
    Get.reset();
  });

  group('TaskController Tests', () {
    test('fetchTasks loads tasks from database', () async {
      // Arrange
      final now = DateTime.now();
      final task1 = Task(
        id: 'task-1',
        title: 'Task 1',
        createdAt: now,
        updatedAt: now,
      );
      final task2 = Task(
        id: 'task-2',
        title: 'Task 2',
        createdAt: now,
        updatedAt: now,
      );
      mockDatabaseService.addMockTask(task1);
      mockDatabaseService.addMockTask(task2);

      // Act
      await taskController.fetchTasks();

      // Assert
      expect(taskController.tasks.length, 2);
      expect(taskController.tasks[0].id, 'task-1');
      expect(taskController.tasks[1].id, 'task-2');
    });

    test('addTask adds a task to the database and updates the list', () async {
      // Act
      await taskController.addTask(
        'New Task',
        description: 'Task Description',
        priority: 'high',
      );

      // Assert
      expect(taskController.tasks.length, 1);
      expect(taskController.tasks[0].title, 'New Task');
      expect(taskController.tasks[0].description, 'Task Description');
      expect(taskController.tasks[0].priority, 'high');
    });

    test('updateTask updates a task in the database and in the list', () async {
      // Arrange
      final now = DateTime.now();
      final task = Task(
        id: 'task-1',
        title: 'Original Title',
        createdAt: now,
        updatedAt: now,
      );
      mockDatabaseService.addMockTask(task);
      await taskController.fetchTasks();

      // Act
      await taskController.updateTask(
        Task(
          id: 'task-1',
          title: 'Updated Title',
          description: 'Updated Description',
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Assert
      expect(taskController.tasks.length, 1);
      expect(taskController.tasks[0].title, 'Updated Title');
      expect(taskController.tasks[0].description, 'Updated Description');
    });

    test('deleteTask removes a task from the database and from the list', () async {
      // Arrange
      final now = DateTime.now();
      final task = Task(
        id: 'task-1',
        title: 'Task to Delete',
        createdAt: now,
        updatedAt: now,
      );
      mockDatabaseService.addMockTask(task);
      await taskController.fetchTasks();
      expect(taskController.tasks.length, 1);

      // Act
      await taskController.deleteTask('task-1');

      // Assert
      expect(taskController.tasks.length, 0);
    });

    test('toggleTaskCompletion changes the completion status', () async {
      // Arrange
      final now = DateTime.now();
      final task = Task(
        id: 'task-1',
        title: 'Task',
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
      );
      mockDatabaseService.addMockTask(task);
      await taskController.fetchTasks();
      expect(taskController.tasks[0].isCompleted, false);

      // Act
      await taskController.toggleTaskCompletion('task-1');

      // Assert
      expect(taskController.tasks[0].isCompleted, true);

      // Toggle back
      await taskController.toggleTaskCompletion('task-1');
      expect(taskController.tasks[0].isCompleted, false);
    });
  });
}
