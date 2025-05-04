import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/task_controller.dart';
import '../widgets/task_list_item.dart';
import '../widgets/add_task_dialog.dart';
import '../widgets/filter_tasks_dialog.dart';
import '../widgets/no_search_results.dart';
import '../../utils/error_handler.dart';
import 'board_view_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // RxBool to track search bar visibility
  final RxBool _showSearchBar = false.obs;

  @override
  Widget build(BuildContext context) {
    // Initialize the task controller
    final TaskController taskController = Get.put(TaskController());
    final ErrorHandler errorHandler = Get.put(ErrorHandler());

    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine if we're on a tablet or larger device
        final isTablet = constraints.maxWidth > 600;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Offline Tasks'),
            actions: [
              IconButton(
                icon: const Icon(Icons.dashboard),
                onPressed: () {
                  Get.to(() => const BoardViewScreen());
                },
                tooltip: 'Board View',
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Get.to(() => SettingsScreen());
                },
                tooltip: 'Settings',
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  taskController.fetchTasks();
                  errorHandler.showSuccessSnackbar('Refreshed', 'Task list refreshed');
                },
              ),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const FilterTasksDialog(),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  // Toggle search bar visibility
                  taskController.searchQuery.value = '';
                  _showSearchBar.value = !_showSearchBar.value;
                  if (!_showSearchBar.value) {
                    // Reset search when closing
                    taskController.resetFilters();
                  }
                },
              ),
            ],
          ),
          body: Obx(() {
            // Show search bar if enabled
            if (_showSearchBar.value) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search tasks...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            taskController.searchTasks('');
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: (value) {
                        taskController.searchTasks(value);
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildTaskList(taskController, isTablet),
                  ),
                ],
              );
            }

            if (taskController.isLoading.value) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading tasks...'),
                  ],
                ),
              );
            }

            // Check if we're showing filtered tasks or all tasks
            final displayTasks = taskController.isFiltered.value || taskController.searchQuery.value.isNotEmpty
                ? taskController.filteredTasks
                : taskController.tasks;

            if (displayTasks.isEmpty) {
              // Show different empty state based on whether we're searching or filtering
              if (taskController.searchQuery.value.isNotEmpty) {
                return NoSearchResults(
                  searchQuery: taskController.searchQuery.value,
                  onClearSearch: () {
                    taskController.searchTasks('');
                    if (_showSearchBar.value) {
                      _showSearchBar.value = false;
                    }
                  },
                );
              }

              // Default empty state when no tasks exist
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.task_alt, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No tasks yet',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text('Tap the + button to add a new task'),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _showAddTaskDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Task'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return _buildTaskList(taskController, isTablet);
          }),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddTaskDialog(context),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  // Helper method to build task list based on screen size
  Widget _buildTaskList(TaskController taskController, bool isTablet) {
    // Determine which task list to display (filtered or all)
    final displayTasks = taskController.isFiltered.value || taskController.searchQuery.value.isNotEmpty
        ? taskController.filteredTasks
        : taskController.tasks;

    if (isTablet) {
      // Grid layout for tablets
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: displayTasks.length,
        itemBuilder: (context, index) {
          final task = displayTasks[index];
          return TaskListItem(task: task);
        },
      );
    } else {
      // List layout for phones
      return ListView.builder(
        itemCount: displayTasks.length,
        itemBuilder: (context, index) {
          final task = displayTasks[index];
          return TaskListItem(task: task);
        },
      );
    }
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddTaskDialog(),
    );
  }
}
