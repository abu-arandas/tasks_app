import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:tasks_app/screens/home_page.dart';
import 'package:tasks_app/screens/sign_in.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Management',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFF9BE7C),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFFFF9EC)),
        scaffoldBackgroundColor: const Color(0xFFFFF9EC),
        textTheme: Theme.of(context).textTheme.apply(
              fontFamily: 'Poppins',
              bodyColor: const Color(0xFF0D253F),
              displayColor: const Color(0xFF0D253F),
            ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.5),
              borderSide: const BorderSide(color: Colors.white)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.5),
              borderSide: const BorderSide(color: Colors.white)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.5),
              borderSide: const BorderSide(color: Colors.white)),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.5),
            borderSide: const BorderSide(color: Color(0xFFe66430)),
          ),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) => snapshot.hasData ? const HomePage() : const SignIn(),
      ),
    );
  }
}
