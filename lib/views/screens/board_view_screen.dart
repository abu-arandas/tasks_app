import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../controllers/task_controller.dart';
import '../../models/task.dart';
import '../widgets/task_card.dart';

class BoardViewScreen extends StatefulWidget {
  const BoardViewScreen({super.key});

  @override
  State<BoardViewScreen> createState() => _BoardViewScreenState();
}

class _BoardViewScreenState extends State<BoardViewScreen> {
  final TaskController _taskController = Get.find<TaskController>();

  // Categories for the Kanban board
  final List<String> _categories = ['To Do', 'In Progress', 'Done'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Board View'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Get.back(); // Return to list view
            },
            tooltip: 'Switch to List View',
          ),
        ],
      ),
      body: Obx(() {
        // Get all tasks
        final List<Task> allTasks =
            _taskController.isFiltered.value ? _taskController.filteredTasks : _taskController.tasks;

        return _taskController.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: MasonryGridView.count(
                  crossAxisCount: _getCrossAxisCount(context),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final List<Task> categoryTasks = _getCategoryTasks(allTasks, category);

                    return _buildCategoryColumn(category, categoryTasks);
                  },
                ),
              );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _taskController.showAddTaskDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Determine the number of columns based on screen width
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 3;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  // Get tasks for a specific category
  List<Task> _getCategoryTasks(List<Task> allTasks, String category) {
    switch (category) {
      case 'To Do':
        return allTasks
            .where((task) => !task.isCompleted && (task.priority == 'high' || task.priority == 'medium'))
            .toList();
      case 'In Progress':
        return allTasks.where((task) => !task.isCompleted && task.priority == 'low').toList();
      case 'Done':
        return allTasks.where((task) => task.isCompleted).toList();
      default:
        return [];
    }
  }

  // Build a column for a category
  Widget _buildCategoryColumn(String category, List<Task> tasks) {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: _getCategoryColor(category),
            child: Text(
              '$category (${tasks.length})',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          if (tasks.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: Text('No tasks')),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: TaskCard(task: tasks[index]),
                );
              },
            ),
        ],
      ),
    );
  }

  // Get color for category header
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'To Do':
        return Colors.blue;
      case 'In Progress':
        return Colors.orange;
      case 'Done':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
