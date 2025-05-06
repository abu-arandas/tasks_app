import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'views/screens/home_screen.dart';
import 'controllers/task_controller.dart';
import 'controllers/tag_controller.dart';
import 'controllers/reminder_controller.dart';
import 'services/database_service.dart';
import 'services/connectivity_service.dart';
import 'services/theme_service.dart';
import 'services/backup_service.dart';
import 'services/firebase_service.dart';
import 'services/conflict_service.dart';
import 'services/ml_service.dart';
import 'services/plugin_manager.dart';
import 'services/language_service.dart';
import 'utils/error_handler.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Firebase initialization failed: $e');
    // Continue without Firebase in case of error
  }

  // Initialize services
  Get.put(ErrorHandler());
  Get.put(DatabaseService());
  Get.put(ConnectivityService());
  Get.put(ThemeService());
  Get.put(BackupService());

  // Initialize new services for roadmap features
  Get.put(FirebaseService());
  Get.put(ConflictService());
  Get.put(MLService());
  Get.put(PluginManager());
  Get.put(LanguageService());

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
          title: 'Tasks App',
          theme: themeService.lightTheme,
          darkTheme: themeService.darkTheme,
          themeMode: themeService.themeMode.value,
          home: const HomeScreen(),
          debugShowCheckedModeBanner: false,

          // Add localization support
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            Locale('es'), // Spanish
            Locale('fr'), // French
            Locale('de'), // German
            Locale('zh'), // Chinese
            Locale('ja'), // Japanese
            Locale('ar'), // Arabic
          ],
        ));
  }
}
