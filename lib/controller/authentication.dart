import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/screens/sign_in.dart';
import '/screens/sign_up.dart';
import '/screens/home_page.dart';

class Authentication extends GetxController {
  static Authentication instance = Get.find();

  UserModel? currentUser;

  List<UserModel> users = [
    UserModel(name: 'Ehab Arandas', email: 'e00arandas@gmail.com', password: '123456'),
    UserModel(name: 'Ehab Arandas', email: 'e.aeandas@gmail.com', password: '123456'),
  ];

  void signIn({required BuildContext context, required String email, required String password}) {
    try {
      if (users.any((element) => element.email == email)) {
        if (users.singleWhere((element) => element.email == email).password == password) {
          currentUser = users.singleWhere((element) => element.email == email);
          update();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              duration: Duration(seconds: 5),
              content: Text('welcome back'),
            ),
          );

          Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(duration: Duration(seconds: 5), content: Text('wrong password')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            content: const Text('email not registered'),
            action: SnackBarAction(
              label: 'Sign Up',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUp())),
            ),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, duration: const Duration(seconds: 5), content: Text(error.toString())),
      );
    }
  }

  void signUp({required BuildContext context, required UserModel user}) {
    try {
      if (!users.any((element) => element.email == user.email)) {
        users.add(user);
        currentUser = user;
        update();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
            content: Text('welcome'),
          ),
        );

        Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            content: const Text('email already exists'),
            action: SnackBarAction(
              label: 'Sign In',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignIn())),
            ),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, duration: const Duration(seconds: 5), content: Text(error.toString())),
      );
    }
  }

  void signOut(context) {
    try {
      currentUser = null;
      update();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(duration: Duration(seconds: 5), content: Text('good bye')),
      );

      Navigator.push(context, MaterialPageRoute(builder: (context) => const SignIn()));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, duration: const Duration(seconds: 5), content: Text(error.toString())),
      );
    }
  }
}

class UserModel {
  String name, email, password;

  UserModel({required this.name, required this.email, required this.password});
}
