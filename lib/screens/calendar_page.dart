import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:horizontal_calendar/horizontal_calendar.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import '/controller/authentication.dart';
import '/controller/data.dart';
import '/controller/resposive.dart';

class CalendarPage extends StatefulWidget {
  final TaskProgress? progress;
  final String? category;
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

  @override
  Widget build(BuildContext context) => GetBuilder<Authentication>(
        builder: (authController) => GetBuilder<Data>(
          builder: (dataController) {
            List<TaskModel> data;

            if (widget.progress != null) {
              data = dataController.tasks
                  .where((element) =>
                      DateTime(element.startDate.year, element.startDate.month, element.startDate.day) ==
                          DateTime(selectedDate.year, selectedDate.month, selectedDate.day) &&
                      element.user == authController.currentUser!.email &&
                      element.progress == widget.progress)
                  .toList();
            } else if (widget.category != null) {
              data = dataController.tasks
                  .where((element) =>
                      DateTime(element.startDate.year, element.startDate.month, element.startDate.day) ==
                          DateTime(selectedDate.year, selectedDate.month, selectedDate.day) &&
                      element.user == authController.currentUser!.email &&
                      element.category.contains(widget.category))
                  .toList();
            } else {
              data = dataController.tasks
                  .where((element) =>
                      DateTime(element.startDate.year, element.startDate.month, element.startDate.day) ==
                          DateTime(selectedDate.year, selectedDate.month, selectedDate.day) &&
                      element.user == authController.currentUser!.email)
                  .toList();
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
                                        borderRadius: BorderRadius.circular(12.5), borderSide: const BorderSide(color: Colors.grey)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.5), borderSide: const BorderSide(color: Colors.grey)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.5), borderSide: const BorderSide(color: Colors.grey)),
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
                                        borderRadius: BorderRadius.circular(12.5), borderSide: const BorderSide(color: Colors.grey)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.5), borderSide: const BorderSide(color: Colors.grey)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.5), borderSide: const BorderSide(color: Colors.grey)),
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
                                MultiSelectDialogField(
                                  title: const Text('Categories'),
                                  items: dataController.categories.map((e) => MultiSelectItem(e.id, e.id)).toList(),
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
                                        selectedCategory.removeWhere((element) => element == category);
                                      } else {
                                        selectedCategory.add(category);
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                dataController.createTask(
                                  context: context,
                                  task: TaskModel(
                                    id: dataController.tasks.length.toString(),
                                    title: titleController.text,
                                    startDate: DateTime.now(),
                                    description: descriptionController.text,
                                    category: selectedCategory,
                                    progress: TaskProgress.toDo,
                                    user: authController.currentUser!.email,
                                  ),
                                );
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
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: List.generate(
                        data.length,
                        (index) => Div(
                          lg: Col.col4,
                          md: Col.col6,
                          sm: Col.col12,
                          child: Container(
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
                                        data[index].title,
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    if (data[index].progress != TaskProgress.done)
                                      IconButton(
                                        onPressed: () => dataController.deleteTask(context, data[index].id),
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
                                    data[index].description,
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
                                    if (data[index].progress == TaskProgress.toDo)
                                      ElevatedButton(
                                        onPressed: () {
                                          dataController.tasks.singleWhere((element) => element.id == data[index].id).progress =
                                              TaskProgress.inProgress;

                                          // Snack
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Started')),
                                          );
                                        },
                                        child: const Text('Start'),
                                      ),
                                    if (data[index].progress == TaskProgress.inProgress)
                                      ElevatedButton(
                                        onPressed: () {
                                          dataController.tasks.singleWhere((element) => element.id == data[index].id).progress = TaskProgress.done;

                                          // Snack
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Started')),
                                          );
                                        },
                                        child: const Text('Finish'),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
}
