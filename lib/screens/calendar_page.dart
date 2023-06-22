import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:horizontal_calendar/horizontal_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:tasks_app/screens/home_page.dart';

class CalendarPage extends StatefulWidget {
  final String? progress, category;
  const CalendarPage({super.key, this.progress, this.category});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime selectedDate = DateTime.now();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();

  TextEditingController descriptionController = TextEditingController();

  List<String> selectedCategory = [];

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot<Object?>>? stream;

    if (widget.progress != null) {
      stream = FirebaseFirestore.instance
          .collection('tasks')
          .where('user', isEqualTo: FirebaseAuth.instance.currentUser!.email)
          .where('progress', isEqualTo: widget.progress)
          .snapshots();
    } else if (widget.category != null) {
      stream = FirebaseFirestore.instance
          .collection('tasks')
          .where('user', isEqualTo: FirebaseAuth.instance.currentUser!.email)
          .where('category', arrayContains: widget.category)
          .snapshots();
    } else {
      stream = FirebaseFirestore.instance
          .collection('tasks')
          .where('user', isEqualTo: FirebaseAuth.instance.currentUser!.email)
          .snapshots();
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: Text(
          DateFormat.yMMMd().format(selectedDate),
          style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () async => await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Create a new task'),
                content: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        // Title
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Title',
                            labelStyle: const TextStyle(color: Colors.grey),
                            suffixIconColor: Colors.white,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.5),
                                borderSide: const BorderSide(color: Colors.grey)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.5),
                                borderSide: const BorderSide(color: Colors.grey)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.5),
                                borderSide: const BorderSide(color: Colors.grey)),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.5),
                              borderSide: const BorderSide(color: Color(0xFFe66430)),
                            ),
                          ),
                          controller: titleController,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return '* required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Description
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Description',
                            labelStyle: const TextStyle(color: Colors.grey),
                            suffixIconColor: Colors.white,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.5),
                                borderSide: const BorderSide(color: Colors.grey)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.5),
                                borderSide: const BorderSide(color: Colors.grey)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.5),
                                borderSide: const BorderSide(color: Colors.grey)),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.5),
                              borderSide: const BorderSide(color: Color(0xFFe66430)),
                            ),
                          ),
                          minLines: 1,
                          maxLines: 5,
                          controller: descriptionController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return '* required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Category
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('categories')
                              .where('user', isEqualTo: FirebaseAuth.instance.currentUser!.email)
                              .snapshots(),
                          builder: (context, categorySnapshot) {
                            if (categorySnapshot.hasData) {
                              return MultiSelectDialogField(
                                title: 'Categories',
                                items: categorySnapshot.data!.docs
                                    .map((e) => MultiSelectItem(e.id, e.id))
                                    .toList(),
                                initialValue: selectedCategory,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return '* required';
                                  }
                                  return null;
                                },
                                onConfirm: (categories) {
                                  for (var category in categories) {
                                    if (selectedCategory.contains(category)) {
                                      selectedCategory
                                          .removeWhere((element) => element == category);
                                    } else {
                                      selectedCategory.add(category);
                                    }
                                  }
                                },
                              );
                            } else {
                              return const CircularProgressIndicator();
                            }
                          },
                        ),
                      ],
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
                              .collection('tasks')
                              .doc()
                              .set({
                                'title': titleController.text,
                                'startDate': selectedDate,
                                'endDate': null,
                                'description': descriptionController.text,
                                'category': selectedCategory,
                                'progress': 'To Do',
                                'user': FirebaseAuth.instance.currentUser!.email,
                              })

                              // Snack
                              .then((value) => ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(content: Text('Added'))))

                              // Navigator
                              .then((value) => Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => const HomePage())));
                        } on FirebaseException catch (error) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(error.message!)));
                        }
                      }
                    },
                    child: const Text('Create Task'),
                  ),
                ],
              ),
            ),
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Dates
            HorizontalCalendar(
              date: selectedDate,
              locale: const Locale('en', 'US'),
              initialDate: selectedDate,
              textColor: Colors.black45,
              backgroundColor: Colors.transparent,
              selectedColor: const Color(0xFFE46472),
              showMonth: true,
              onDateSelected: (date) => setState(() => selectedDate = date),
            ),
            const SizedBox(height: 24),

            // Tasks
            StreamBuilder<QuerySnapshot>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
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

                  List data = snapshot.data!.docs
                      .where((element) =>
                          DateTime(
                              (element['startDate'] as Timestamp).toDate().year,
                              (element['startDate'] as Timestamp).toDate().month,
                              (element['startDate'] as Timestamp).toDate().day) ==
                          DateTime(selectedDate.year, selectedDate.month, selectedDate.day))
                      .toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.length,
                    itemBuilder: (context, index) => Container(
                      margin: const EdgeInsets.symmetric(vertical: 15),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colors(index),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  data[index]['title'],
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (data[index]['progress'] != 'Done')
                                IconButton(
                                  onPressed: () => FirebaseFirestore.instance
                                      .collection('tasks')
                                      .doc(data[index].id)
                                      .delete()

                                      // Snack
                                      .then((value) => ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(content: Text('Deleted')))),
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Color(0xFFe66430),
                                  ),
                                ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              data[index]['description'],
                              style: const TextStyle(
                                fontSize: 14.0,
                                color: Colors.black54,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (data[index]['progress'] == 'To Do')
                                ElevatedButton(
                                  onPressed: () => FirebaseFirestore.instance
                                      .collection('tasks')
                                      .doc(data[index].id)
                                      .update({'progress': 'In Progress'})

                                      // Snack
                                      .then((value) => ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(content: Text('Started')))),
                                  child: const Text('Start'),
                                ),
                              if (data[index]['progress'] == 'In Progress')
                                ElevatedButton(
                                  onPressed: () => FirebaseFirestore.instance
                                      .collection('tasks')
                                      .doc(data[index].id)
                                      .update({'progress': 'Done'})

                                      // Snack
                                      .then((value) => ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(content: Text('Finished')))),
                                  child: const Text('Finish'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
