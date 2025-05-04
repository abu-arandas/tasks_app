import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';
import '../models/tag.dart';
import '../models/reminder.dart';
import '../utils/error_handler.dart';
import '../utils/database_optimizer.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;
  final ErrorHandler _errorHandler = ErrorHandler();
  final DatabaseOptimizer _databaseOptimizer = DatabaseOptimizer();

  // Singleton pattern
  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'tasks_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    // Tasks table
    await db.execute('''
      CREATE TABLE tasks(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        isCompleted INTEGER NOT NULL,
        dueDate TEXT,
        priority TEXT,
        isRecurring INTEGER NOT NULL,
        recurrencePattern TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Tags table
    await db.execute('''
      CREATE TABLE tags(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        color TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    // Reminders table
    await db.execute('''
      CREATE TABLE reminders(
        id TEXT PRIMARY KEY,
        taskId TEXT NOT NULL,
        reminderTime TEXT NOT NULL,
        isRepeating INTEGER NOT NULL,
        repeatPattern TEXT,
        isDismissed INTEGER NOT NULL,
        isSnoozing INTEGER NOT NULL,
        snoozeUntil TEXT,
        FOREIGN KEY (taskId) REFERENCES tasks (id) ON DELETE CASCADE
      )
    ''');

    // Task-Tag relationship table
    await db.execute('''
      CREATE TABLE task_tags(
        taskId TEXT NOT NULL,
        tagId TEXT NOT NULL,
        PRIMARY KEY (taskId, tagId),
        FOREIGN KEY (taskId) REFERENCES tasks (id) ON DELETE CASCADE,
        FOREIGN KEY (tagId) REFERENCES tags (id) ON DELETE CASCADE
      )
    ''');

    // Subtasks table (for hierarchical tasks)
    await db.execute('''
      CREATE TABLE subtasks(
        id TEXT PRIMARY KEY,
        parentId TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        isCompleted INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (parentId) REFERENCES tasks (id) ON DELETE CASCADE
      )
    ''');

    // Change journal for offline operations
    await db.execute('''
      CREATE TABLE change_journal(
        id TEXT PRIMARY KEY,
        entityType TEXT NOT NULL,
        entityId TEXT NOT NULL,
        operation TEXT NOT NULL,
        data TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        synced INTEGER NOT NULL
      )
    ''');
  }

  // CRUD operations for Tasks
  Future<void> insertTask(Task task) async {
    final db = await database;
    await db.insert('tasks', task.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);

    // Insert task-tag relationships
    for (String tagId in task.tagIds) {
      await db.insert('task_tags', {
        'taskId': task.id,
        'tagId': tagId,
      });
    }
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    try {
      return await _databaseOptimizer.executeWithPerformanceTracking<List<Task>>(
        'getTasks',
        () async {
          final List<Map<String, dynamic>> maps = await db.query('tasks');
          final tasks = List.generate(maps.length, (i) {
            Task task = Task.fromJson(maps[i]);
            // Load tags for each task
            _loadTaskTags(task);
            return task;
          });
          return tasks;
        },
      );
    } catch (e, stackTrace) {
      _errorHandler.handleDatabaseError(e, customMessage: 'Failed to fetch tasks');
      _errorHandler.log('Error in getTasks', level: ErrorHandler.error, errors: e, stackTrace: stackTrace);
      return [];
    }
  }

  Future<void> _loadTaskTags(Task task) async {
    final db = await database;
    final List<Map<String, dynamic>> tagMaps = await db.rawQuery('''
      SELECT tagId FROM task_tags WHERE taskId = ?
    ''', [task.id]);

    task.tagIds = List.generate(tagMaps.length, (i) => tagMaps[i]['tagId'] as String);
  }

  Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update(
      'tasks',
      task.toJson(),
      where: 'id = ?',
      whereArgs: [task.id],
    );

    // Update task-tag relationships
    await db.delete('task_tags', where: 'taskId = ?', whereArgs: [task.id]);
    for (String tagId in task.tagIds) {
      await db.insert('task_tags', {
        'taskId': task.id,
        'tagId': tagId,
      });
    }
  }

  Future<void> deleteTask(String id) async {
    final db = await database;
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD operations for Tags
  Future<void> insertTag(Tag tag) async {
    final db = await database;
    await db.insert('tags', tag.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Tag>> getTags() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tags');

    return List.generate(maps.length, (i) => Tag.fromJson(maps[i]));
  }

  Future<void> updateTag(Tag tag) async {
    final db = await database;
    await db.update(
      'tags',
      tag.toJson(),
      where: 'id = ?',
      whereArgs: [tag.id],
    );
  }

  Future<void> deleteTag(String id) async {
    final db = await database;
    await db.delete(
      'tags',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD operations for Reminders
  Future<void> insertReminder(Reminder reminder) async {
    final db = await database;
    await db.insert('reminders', reminder.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Reminder>> getReminders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('reminders');

    return List.generate(maps.length, (i) => Reminder.fromJson(maps[i]));
  }

  Future<List<Reminder>> getRemindersForTask(String taskId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reminders',
      where: 'taskId = ?',
      whereArgs: [taskId],
    );

    return List.generate(maps.length, (i) => Reminder.fromJson(maps[i]));
  }

  Future<void> updateReminder(Reminder reminder) async {
    final db = await database;
    await db.update(
      'reminders',
      reminder.toJson(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  Future<void> deleteReminder(String id) async {
    final db = await database;
    await db.delete(
      'reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Change journal operations for offline sync
  Future<void> logChange(String entityType, String entityId, String operation, String data) async {
    final db = await database;
    await db.insert('change_journal', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'entityType': entityType,
      'entityId': entityId,
      'operation': operation,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
      'synced': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getUnsynced() async {
    final db = await database;
    return await db.query(
      'change_journal',
      where: 'synced = ?',
      whereArgs: [0],
      orderBy: 'timestamp ASC',
    );
  }

  Future<void> markAsSynced(String id) async {
    final db = await database;
    await db.update(
      'change_journal',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAllTasks() async {
    final db = await database;

    await db.delete('tasks');
    await db.delete('reminders');
    await db.delete('task_tags');
    await db.delete('subtasks');
  }
}
