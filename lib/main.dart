import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'views/screens/home_screen.dart';
import 'controllers/task_controller.dart';
import 'controllers/tag_controller.dart';
import 'controllers/reminder_controller.dart';
import 'services/database_service.dart';
import 'services/connectivity_service.dart';
import 'services/theme_service.dart';
import 'services/backup_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  Get.put(DatabaseService());
  Get.put(ConnectivityService());
  Get.put(ThemeService());
  Get.put(BackupService());

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
    final ThemeService themeService = Get.find<ThemeService>();
    
    return Obx(() => GetMaterialApp(
      title: 'Offline Tasks App',
      theme: themeService.lightTheme,
      darkTheme: themeService.darkTheme,
      themeMode: themeService.themeMode.value,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    ));
  }
}
