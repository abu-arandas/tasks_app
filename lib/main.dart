import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller/binding.dart';
import 'controller/sql.dart';
import 'controller/authentication.dart';

import 'screens/sign_in.dart';
import 'screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SQL.instance.database;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Task Management',
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Poppins',
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0D253F),
            secondary: const Color(0xFFE46472),
          ),
          appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFFFF9EC)),
          scaffoldBackgroundColor: const Color(0xFFFFF9EC),
          textTheme: Theme.of(context).textTheme.apply(
                fontFamily: 'Poppins',
                bodyColor: const Color(0xFF0D253F),
                displayColor: const Color(0xFF0D253F),
              ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.5),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.5),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.5),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.5),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
          ),
        ),
        initialBinding: Bind(),
        home: OrientationBuilder(
          builder: (context, orientation) => GetBuilder<Authentication>(
            builder: (controller) => controller.currentUser != null ? const HomePage() : const SignIn(),
          ),
        ),
      );
}
