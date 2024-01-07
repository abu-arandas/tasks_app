import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:horizontal_calendar/horizontal_calendar.dart';

import '/controller/authentication.dart';
import '../controller/task.dart';
import '/controller/resposive.dart';

import 'task.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime selectedDate = DateTime.now(), now = DateTime.now();

  @override
  void initState() {
    super.initState();

    Timer.periodic(
      const Duration(seconds: 1),
      (arg) => setState(() => now = DateTime.now()),
    );
  }

  @override
  Widget build(BuildContext context) => GetBuilder<Authentication>(
        builder: (authController) => Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: 100,
            title: Text(
              '${DateFormat.yMMMd().format(now)}\n${DateFormat.jms().format(now)}',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 0.9,
                  ),
            ),
            actions: [
              IconButton(
                onPressed: () => authController.signOut(context),
                icon: const Icon(Icons.logout),
              )
            ],
          ),
          body: FutureBuilder(
            future: TaskController.instance.tasks(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<TaskModel> inProgressTasks =
                    snapshot.data!.map((e) => TaskModel.fromJson(e)).where((element) => element.progress == TaskProgress.inProgress).toList();

                inProgressTasks.sort((a, b) => a.startDate.compareTo(b.startDate));

                List<TaskModel> tasks = snapshot.data!
                    .map((e) => TaskModel.fromJson(e))
                    .where((element) =>
                        DateTime(element.startDate.year, element.startDate.month, element.startDate.day) ==
                        DateTime(selectedDate.year, selectedDate.month, selectedDate.day))
                    .toList();

                tasks.sort((a, b) => a.startDate.compareTo(b.startDate));

                return SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      // In Progress Tasks
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // - Title
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'In Progress Tasks',
                                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Text(
                                  inProgressTasks.length.toString(),
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),

                          // Data
                          SizedBox(
                            width: double.maxFinite,
                            height: 200,
                            child: ListView.builder(
                              itemCount: 3,
                              padding: EdgeInsets.zero,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) => Container(
                                width: 300,
                                height: double.maxFinite,
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // -- title
                                    Text(
                                      inProgressTasks[index].title,
                                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                          ),
                                    ),

                                    // -- description
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                        inProgressTasks[index].description,
                                        style: const TextStyle(color: Colors.white),
                                        maxLines: 3,
                                      ),
                                    ),

                                    // -- title & sart date
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${DateFormat.yMMMd().format(inProgressTasks[index].startDate)} : ${DateFormat.jms().format(inProgressTasks[index].startDate)}',
                                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                                color: Colors.white,
                                              ),
                                        ),
                                        IconButton.filled(
                                          onPressed: () => showDialog(
                                            context: context,
                                            builder: (context) => TaskInformation(task: inProgressTasks[index]),
                                          ),
                                          style: IconButton.styleFrom(
                                            backgroundColor: Theme.of(context).colorScheme.onPrimary,
                                          ),
                                          icon: Icon(
                                            Icons.arrow_right,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Tasks
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // - Calendar
                          HorizontalCalendar(
                            date: selectedDate,
                            locale: const Locale('en', 'US'),
                            initialDate: selectedDate,
                            textColor: Colors.black45,
                            backgroundColor: Colors.transparent,
                            selectedColor: Theme.of(context).colorScheme.secondary,
                            onDateSelected: (date) => setState(() => selectedDate = date),
                          ),
                          const SizedBox(height: 24),

                          // Data
                          Wrap(
                            children: List.generate(
                              tasks.length,
                              (index) => Container(
                                constraints: BoxConstraints(
                                  maxWidth: width(Col.col4, Col.col6, Col.col12, context),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: ListTile(
                                  tileColor: progressColor(tasks[index].progress),
                                  contentPadding: const EdgeInsets.all(16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  onTap: () => showDialog(
                                    context: context,
                                    builder: (context) => TaskInformation(task: tasks[index]),
                                  ),

                                  // -- title
                                  title: Text(
                                    tasks[index].title,
                                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                        ),
                                  ),

                                  // -- description
                                  subtitle: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      tasks[index].description,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              } else if (snapshot.hasError) {
                return const Center(child: CircularProgressIndicator());
              } else {
                return Container();
              }
            },
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: ElevatedButton(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => const NewTask(),
            ),
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(300, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.5),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('add a task'),
          ),
        ),
      );
}
