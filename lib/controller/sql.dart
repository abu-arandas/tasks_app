// ignore_for_file: depend_on_referenced_packages

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'task.dart';

class SQL {
  static final SQL instance = SQL._init();
  SQL._init();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async => await openDatabase(
        join(await getDatabasesPath(), 'data.db'),
        onCreate: (Database db, int version) async {
          // Users
          await db.execute('CREATE TABLE IF NOT EXISTS users(id INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT, password TEXT)');
          await db.execute('INSERT INTO users VALUES (0, "e00arandas@gmail.com", "123456")');

          // Tasks
          await db.execute(
              'CREATE TABLE IF NOT EXISTS tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, description TEXT, startDate INTEGER, endDate INTEGER, progress TEXT, user INTEGER)');
        },
        version: 1,
        onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
      ).whenComplete(() {
        List<TaskModel> tasks = List<TaskModel>.generate(
          18,
          (index) {
            if (index > 6) {
              if (index > 12) {
                return TaskModel(
                  id: index,
                  title: 'Test $index',
                  startDate: DateTime.now(),
                  description:
                      'Lorem ipsum is placeholder text commonly used in the graphic, print, and publishing industries for previewing layouts and visual mockups.',
                  progress: TaskProgress.done,
                  user: 0,
                );
              } else {
                return TaskModel(
                  id: index,
                  title: 'Test $index',
                  startDate: DateTime.now(),
                  description:
                      'Lorem ipsum is placeholder text commonly used in the graphic, print, and publishing industries for previewing layouts and visual mockups.',
                  progress: TaskProgress.inProgress,
                  user: 0,
                );
              }
            } else {
              return TaskModel(
                id: index,
                title: 'Test $index',
                startDate: DateTime.now(),
                description:
                    'Lorem ipsum is placeholder text commonly used in the graphic, print, and publishing industries for previewing layouts and visual mockups.',
                progress: TaskProgress.toDo,
                user: 0,
              );
            }
          },
        );

        for (var task in tasks) {
          insertData('tasks', task.toJson());
        }
      });

  static Future<int> insertData(String table, Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert(table, row);
  }

  static Future<List<Map<String, dynamic>>> queryData(String table) async {
    final db = await instance.database;
    return await db.query(table);
  }

  static Future<int> updateData(String table, int id, Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.update(table, row, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> deleteData(String table, int id) async {
    final db = await instance.database;
    return await db.delete(table, where: '$id = ?', whereArgs: [id]);
  }
}
