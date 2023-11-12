import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'authentication.dart';

import '/screens/sign_in.dart';
import '/screens/home_page.dart';

class Data extends GetxController {
  static Data instance = Get.find();

  // Categories
  List<CategoryModel> categories = [
    CategoryModel(id: '0', title: 'Mobile', user: 'e00arandas@gmail.com'),
    CategoryModel(id: '1', title: 'WEB', user: 'e00arandas@gmail.com'),
    CategoryModel(id: '2', title: 'Data Base', user: 'e00arandas@gmail.com'),
  ];

  void createCategory(BuildContext context) {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    TextEditingController categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add a New Category'),
        content: Form(
          key: formKey,
          child: TextFormField(
            decoration: InputDecoration(
              labelText: 'Category Name',
              labelStyle: const TextStyle(color: Colors.black),
              suffixIconColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.5), borderSide: const BorderSide(color: Colors.black)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.5), borderSide: const BorderSide(color: Colors.black)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.5), borderSide: const BorderSide(color: Colors.black)),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.5),
                borderSide: const BorderSide(color: Color(0xFFe66430)),
              ),
            ),
            controller: categoryController,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value!.isEmpty) {
                return '* required';
              }
              return null;
            },
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                try {
                  if (categories.any((element) => element.title == categoryController.text)) {
                    categories.add(
                      CategoryModel(
                        id: Random().nextInt(999999).toString(),
                        title: categoryController.text,
                        user: Authentication.instance.currentUser!.email,
                      ),
                    );
                    update();

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
              }
            },
            child: const Text('add'),
          ),
        ],
      ),
    );
  }

  void updateCategory({required BuildContext context, required CategoryModel category}) {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    TextEditingController categoryController = TextEditingController(text: category.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update ${category.title}'),
        content: Form(
          key: formKey,
          child: TextFormField(
            decoration: InputDecoration(
              labelText: 'Category Name',
              labelStyle: const TextStyle(color: Colors.black),
              suffixIconColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.5), borderSide: const BorderSide(color: Colors.black)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.5), borderSide: const BorderSide(color: Colors.black)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.5), borderSide: const BorderSide(color: Colors.black)),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.5),
                borderSide: const BorderSide(color: Color(0xFFe66430)),
              ),
            ),
            controller: categoryController,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value!.isEmpty) {
                return '* required';
              }
              return null;
            },
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                try {
                  categories.singleWhere((element) => element.id == category.id).title = category.title;
                  update();

                  Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 5),
                      content: Text('updated'),
                    ),
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
            },
            child: const Text('update'),
          ),
        ],
      ),
    );
  }

  void deleteCategory(context, String id) {
    try {
      categories.removeWhere((element) => element.id == id);
      update();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(duration: Duration(seconds: 5), content: Text('deleted')),
      );

      Navigator.push(context, MaterialPageRoute(builder: (context) => const SignIn()));
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

  // Tasks
  List<TaskModel> tasks = List<TaskModel>.generate(
    12,
    (index) {
      if (index > 6) {
        if (index > 12) {
          return TaskModel(
            id: index.toString(),
            title: 'Test $index',
            startDate: DateTime(2023, 11, index),
            description:
                'Lorem ipsum is placeholder text commonly used in the graphic, print, and publishing industries for previewing layouts and visual mockups.',
            category: ['0', '1'],
            progress: TaskProgress.done,
            user: 'e00arandas@gmail.com',
          );
        } else {
          return TaskModel(
            id: index.toString(),
            title: 'Test $index',
            startDate: DateTime(2023, 11, index),
            description:
                'Lorem ipsum is placeholder text commonly used in the graphic, print, and publishing industries for previewing layouts and visual mockups.',
            category: ['0', '1'],
            progress: TaskProgress.inProgress,
            user: 'e00arandas@gmail.com',
          );
        }
      } else {
        return TaskModel(
          id: index.toString(),
          title: 'Test $index',
          startDate: DateTime(2023, 11, index),
          description:
              'Lorem ipsum is placeholder text commonly used in the graphic, print, and publishing industries for previewing layouts and visual mockups.',
          category: ['0', '1'],
          progress: TaskProgress.toDo,
          user: 'e00arandas@gmail.com',
        );
      }
    },
  );

  void createTask({required BuildContext context, required TaskModel task}) {
    try {
      if (tasks.any((element) => element.id == task.id)) {
        tasks.add(task);
        update();

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
  }

  void updateTask({required BuildContext context, required TaskModel task}) {
    try {
      tasks.singleWhere((element) => element.id == task.id).title = task.title;
      tasks.singleWhere((element) => element.id == task.id).description = task.description;
      tasks.singleWhere((element) => element.id == task.id).category = task.category;
      update();

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

  void deleteTask(context, String id) {
    try {
      tasks.removeWhere((element) => element.id == id);
      update();

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

class CategoryModel {
  String id, title, user;

  CategoryModel({required this.id, required this.title, required this.user});
}

class TaskModel {
  String id, title, description, user;
  DateTime startDate;
  DateTime? endDate;
  TaskProgress progress;
  List<String> category;

  TaskModel({
    required this.id,
    required this.title,
    required this.startDate,
    required this.description,
    required this.category,
    this.endDate,
    required this.progress,
    required this.user,
  });
}

enum TaskProgress { toDo, inProgress, done }
