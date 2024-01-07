import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'sql.dart';
import 'authentication.dart';

import '/screens/sign_in.dart';
import '/screens/home_page.dart';

class TaskController extends GetxController {
  static TaskController instance = Get.find();

  Future<List<Map<String, dynamic>>> tasks() async {
    List<Map<String, dynamic>> list = await SQL.queryData('tasks');

    return list.where((element) => element['user'] == Authentication.instance.currentUser!.id).toList();
  }

  void createTask({required BuildContext context, required TaskModel task}) => tasks().then((value) {
        try {
          if (value.any((element) => element['title'].toLowerCase() == task.title.toLowerCase())) {
            SQL.insertData('tasks', task.toJson());

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.green,
                duration: Duration(seconds: 5),
                content: Text('added'),
              ),
            );

            Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.red,
                duration: Duration(seconds: 5),
                content: Text('already exists'),
              ),
            );
          }
        } catch (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(backgroundColor: Colors.red, duration: const Duration(seconds: 5), content: Text(error.toString())),
          );
        }
      });

  void updateTask({required BuildContext context, required TaskModel task}) {
    try {
      SQL.updateData('tasks', task.id, task.toJson());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          duration: Duration(seconds: 5),
          content: Text('welcome'),
        ),
      );

      Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, duration: const Duration(seconds: 5), content: Text(error.toString())),
      );
    }
  }

  void deleteTask(context, int id) {
    try {
      SQL.deleteData('tasks', id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(duration: Duration(seconds: 5), content: Text('deleted')),
      );

      Navigator.push(context, MaterialPageRoute(builder: (context) => const SignIn()));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, duration: const Duration(seconds: 5), content: Text(error.toString())),
      );
    }
  }
}

class TaskModel {
  int id, user;
  String title, description;
  DateTime startDate;
  DateTime? endDate;
  TaskProgress progress;

  TaskModel({
    required this.id,
    required this.title,
    required this.startDate,
    required this.description,
    this.endDate,
    required this.progress,
    required this.user,
  });

  factory TaskModel.fromJson(Map<String, dynamic> data) => TaskModel(
        id: data['id'],
        title: data['title'],
        startDate: DateTime.fromMicrosecondsSinceEpoch(data['startDate']),
        endDate: data['endDate'] != null ? DateTime.fromMicrosecondsSinceEpoch(data['endDate']) : null,
        description: data['description'],
        progress: progressFromString(data['progress']),
        user: data['user'],
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'startDate': startDate.microsecondsSinceEpoch,
        'endDate': endDate?.microsecondsSinceEpoch,
        'progress': progressString(progress),
        'user': user,
      };

  TaskModel copyWith({
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    TaskProgress? progress,
    int? category,
  }) =>
      TaskModel(
        id: id,
        title: title ?? this.title,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        description: description ?? this.description,
        progress: progress ?? this.progress,
        user: user,
      );
}

enum TaskProgress { toDo, inProgress, done }

String progressString(TaskProgress progress) {
  switch (progress) {
    case TaskProgress.toDo:
      return 'To Do';
    case TaskProgress.inProgress:
      return 'In Progress';
    case TaskProgress.done:
      return 'Done';
  }
}

Color progressColor(TaskProgress progress) {
  switch (progress) {
    case TaskProgress.toDo:
      return const Color(0xFFF9BE7C);
    case TaskProgress.inProgress:
      return const Color(0xFF309397);
    case TaskProgress.done:
      return const Color(0xFFE46472);
  }
}

TaskProgress progressFromString(String progress) {
  switch (progress) {
    case 'To Do':
      return TaskProgress.toDo;
    case 'In Progress':
      return TaskProgress.inProgress;
    case 'Done':
      return TaskProgress.done;
    default:
      return TaskProgress.toDo;
  }
}
