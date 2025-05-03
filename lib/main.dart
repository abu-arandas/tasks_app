import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'views/screens/home_screen.dart';
import 'controllers/task_controller.dart';
import 'controllers/tag_controller.dart';
import 'controllers/reminder_controller.dart';
import 'services/database_service.dart';
import 'services/connectivity_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  Get.put(DatabaseService());
  Get.put(ConnectivityService());

  // Initialize controllers
  Get.put(TaskController());
  Get.put(TagController());
  Get.put(ReminderController());

  runApp(const TasksApp());
}

class TasksApp extends StatelessWidget {
  const TasksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offline Tasks App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
