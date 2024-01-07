import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'sql.dart';

import '/screens/sign_in.dart';
import '/screens/sign_up.dart';
import '/screens/home_page.dart';

class Authentication extends GetxController {
  static Authentication instance = Get.find();

  UserModel? currentUser = UserModel(
    id: 0,
    email: 'e00arandas@gmail.com',
    password: '123456',
  );

  Future<List<Map<String, dynamic>>> users() async => await SQL.queryData('users');

  void signIn({required BuildContext context, required String email, required String password}) async => await users().then((value) {
        try {
          if (value.any((element) => element['email'] == email)) {
            if (value.singleWhere((element) => element['email'] == email)['password'] == password) {
              currentUser = UserModel.fromJson(
                value.singleWhere((element) => element['email'] == email),
              );
              update();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 5),
                  content: Text('welcome back'),
                ),
              );

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
                (route) => false,
              );
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
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUp()),
                    (route) => false,
                  ),
                ),
              ),
            );
          }
        } catch (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              content: Text(error.toString()),
            ),
          );
        }
      });

  void signUp({required BuildContext context, required UserModel user}) async => await users().then((value) {
        try {
          if (!value.any((element) => element['email'] == user.email)) {
            SQL.insertData('users', user.toJson());

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
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const SignIn()),
                    (route) => false,
                  ),
                ),
              ),
            );
          }
        } catch (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              content: Text(error.toString()),
            ),
          );
        }
      });

  void signOut(context) {
    try {
      currentUser = null;
      update();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(duration: Duration(seconds: 5), content: Text('good bye')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SignIn()),
        (route) => false,
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          content: Text(error.toString()),
        ),
      );
    }
  }
}

class UserModel {
  int id;
  String email, password;

  UserModel({
    required this.id,
    required this.email,
    required this.password,
  });

  factory UserModel.fromJson(Map<String, dynamic> data) => UserModel(
        id: data['id'],
        email: data['email'],
        password: data['password'],
      );

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}
