import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/controller/authentication.dart';
import '/controller/data.dart';
import '/controller/resposive.dart';

import 'calendar_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => GetBuilder<Authentication>(
        builder: (authController) => GetBuilder<Data>(
          builder: (dataController) => Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              toolbarHeight: 100,
              title: ListTile(
                title: Text(
                  authController.currentUser!.name,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 0.9,
                      ),
                ),
                subtitle: Text(
                  authController.currentUser!.email,
                  style: const TextStyle(color: Colors.black45),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () => authController.signOut(context),
                  icon: const Icon(Icons.logout),
                )
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  // Tasks
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          children: List.generate(
                            TaskProgress.values.length,
                            (index) => task(context, TaskProgress.values[index]),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Categories
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          'Active Projects',
                          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () => dataController.createCategory(context),
                          child: const Text('Add New Category'),
                        ),
                      ],
                    ),
                  ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    direction: Axis.horizontal,
                    children: List.generate(
                      dataController.categories.length,
                      (index) => Div(
                        lg: Col.col3,
                        md: Col.col4,
                        sm: Col.col6,
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CalendarPage(category: dataController.categories[index].id),
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(16),
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
                                    dataController.categories[index].title,
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => dataController.deleteCategory(context, dataController.categories[index].id),
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
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

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

  Widget task(BuildContext context, TaskProgress progress) {
    Color iconBackgroundColor() {
      switch (progress) {
        case TaskProgress.toDo:
          return const Color(0xFFF9BE7C);
        case TaskProgress.inProgress:
          return const Color(0xFF309397);
        case TaskProgress.done:
          return const Color(0xFFE46472);
      }
    }

    IconData icon() {
      switch (progress) {
        case TaskProgress.toDo:
          return Icons.alarm;
        case TaskProgress.inProgress:
          return Icons.blur_circular;
        case TaskProgress.done:
          return Icons.check_circle_outline;
      }
    }

    String title() {
      switch (progress) {
        case TaskProgress.toDo:
          return 'To Do';
        case TaskProgress.inProgress:
          return 'In Progress';
        case TaskProgress.done:
          return 'Done';
      }
    }

    return GetBuilder<Data>(
      builder: (controller) => Div(
        lg: Col.col3,
        md: Col.col4,
        sm: Col.col6,
        child: ListTile(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CalendarPage(progress: progress)),
          ),
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: iconBackgroundColor(),
            child: Icon(icon(), size: 20, color: Colors.white),
          ),
          title: Text(
            title(),
            style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '${controller.tasks.where((element) => element.progress == progress).length} Task.',
            style: const TextStyle(fontSize: 14.0, color: Colors.black45),
          ),
        ),
      ),
    );
  }
}
