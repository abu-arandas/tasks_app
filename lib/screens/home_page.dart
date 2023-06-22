import 'package:flutter/material.dart';
import 'package:tasks_app/screens/calendar_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController categoryController = TextEditingController();

  // TODO after first sign in / sign up delete the initState
  @override
  void initState() {
    super.initState();

    for (var i = 0; i < 6; i++) {
      FirebaseFirestore.instance.collection('categories').doc(i.toString()).set({
        'title': 'Test $i',
        'user': FirebaseAuth.instance.currentUser!.email,
      });
    }

    for (var i = 0; i < 18; i++) {
      if (i > 6) {
        if (i > 12) {
          FirebaseFirestore.instance.collection('tasks').doc(i.toString()).set({
            'title': 'Test $i',
            'startDate': DateTime.now(),
            'endDate': null,
            'description':
                'Lorem ipsum is placeholder text commonly used in the graphic, print, and publishing industries for previewing layouts and visual mockups.',
            'category': [0, 1],
            'progress': 'Done',
            'user': FirebaseAuth.instance.currentUser!.email,
          });
        } else {
          FirebaseFirestore.instance.collection('tasks').doc(i.toString()).set({
            'title': 'Test $i',
            'startDate': DateTime.now(),
            'endDate': null,
            'description':
                'Lorem ipsum is placeholder text commonly used in the graphic, print, and publishing industries for previewing layouts and visual mockups.',
            'category': [2, 3],
            'progress': 'In Progress',
            'user': FirebaseAuth.instance.currentUser!.email,
          });
        }
      } else {
        FirebaseFirestore.instance.collection('tasks').doc(i.toString()).set({
          'title': 'Test $i',
          'startDate': DateTime.now(),
          'endDate': null,
          'description':
              'Lorem ipsum is placeholder text commonly used in the graphic, print, and publishing industries for previewing layouts and visual mockups.',
          'category': [4, 5],
          'progress': 'To Do',
          'user': FirebaseAuth.instance.currentUser!.email,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        title: ListTile(
          title: Text(
            FirebaseAuth.instance.currentUser!.displayName!,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            FirebaseAuth.instance.currentUser!.email!,
            style: const TextStyle(color: Colors.black45),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Tasks
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'My Tasks',
                        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CalendarPage()),
                        ),
                        child: const Text('Show More'),
                      ),
                    ],
                  ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    direction: Axis.horizontal,
                    children: [
                      task('TO DO'),
                      task('In Progress'),
                      task('Done'),
                    ],
                  ),
                ],
              ),
            ),

            // Categories
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'Active Projects',
                        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () async => await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Add a New Category'),
                            content: SingleChildScrollView(
                              child: Form(
                                key: formKey,
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Category Name',
                                    labelStyle: const TextStyle(color: Colors.black),
                                    suffixIconColor: Colors.white,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.5),
                                        borderSide: const BorderSide(color: Colors.black)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.5),
                                        borderSide: const BorderSide(color: Colors.black)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.5),
                                        borderSide: const BorderSide(color: Colors.black)),
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
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    try {
                                      // Create Task
                                      await FirebaseFirestore.instance
                                          .collection('categories')
                                          .doc(categoryController.text)
                                          .set({
                                            'title': categoryController.text,
                                            'user': FirebaseAuth.instance.currentUser!.email,
                                          })

                                          // Snack
                                          .then((value) => ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(content: Text('Added'))))

                                          // Navigator
                                          .then((value) => Navigator.pop(context));
                                    } on FirebaseException catch (error) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(content: Text(error.message!)));
                                    }
                                  }
                                },
                                child: const Text('add'),
                              ),
                            ],
                          ),
                        ),
                        child: const Text('Add New Category'),
                      ),
                    ],
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('categories')
                        .where('user', isEqualTo: FirebaseAuth.instance.currentUser!.email)
                        .snapshots(),
                    builder: (context, categoriesSnapshot) {
                      if (categoriesSnapshot.hasData) {
                        Color colors(int index) {
                          List<Color> colors = const [
                            Color(0xFFF9BE7C),
                            Color(0xFF309397),
                            Color(0xFFE46472),
                            Color(0xFF6488E4),
                          ];

                          if (colors.length <= index) {
                            return colors[((index - 1) / colors.length).round()];
                          } else {
                            return colors[index];
                          }
                        }

                        return Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          direction: Axis.horizontal,
                          children: List.generate(
                            categoriesSnapshot.data!.docs.length,
                            (index) => InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CalendarPage(
                                        category: categoriesSnapshot.data!.docs[index].id)),
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.all(16),
                                constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.4),
                                decoration: BoxDecoration(
                                  color: colors(index),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        categoriesSnapshot.data!.docs[index]['title'],
                                        style: const TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => FirebaseFirestore.instance
                                          .collection('categories')
                                          .doc(categoriesSnapshot.data!.docs[index].id)
                                          .delete()

                                          // Snack
                                          .then((value) => ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                                  const SnackBar(content: Text('Deleted')))),
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Color(0xFFe66430),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget task(String progress) {
    Color iconBackgroundColor = progress == 'TO DO'
        ? const Color(0xFFF9BE7C)
        : progress == 'In Progress'
            ? const Color(0xFF309397)
            : const Color(0xFFE46472);

    IconData icon = progress == 'TO DO'
        ? Icons.alarm
        : progress == 'In Progress'
            ? Icons.blur_circular
            : Icons.check_circle_outline;

    String title = progress == 'TO DO'
        ? 'To Do'
        : progress == 'In Progress'
            ? 'In Progress'
            : 'Done';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tasks')
          .where('user', isEqualTo: FirebaseAuth.instance.currentUser!.email)
          .where('progress', isEqualTo: title)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListTile(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CalendarPage(progress: title)),
            ),
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: iconBackgroundColor,
              child: Icon(icon, size: 20, color: Colors.white),
            ),
            title: Text(
              title,
              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${snapshot.data!.docs.length} task.',
              style: const TextStyle(fontSize: 14.0, color: Colors.black45),
            ),
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
