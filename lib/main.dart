import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller/binding.dart';

import 'screens/sign_in.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Task Management',
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Poppins',
          colorSchemeSeed: const Color(0xFFF9BE7C),
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
        home: OrientationBuilder(builder: (context, orientation) => const SignIn()),
      );
}
