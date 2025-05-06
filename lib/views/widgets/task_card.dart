import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/task.dart';
import '../../controllers/task_controller.dart';
import '../screens/task_detail_screen.dart';

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final TaskController taskController = Get.find<TaskController>();

    // Determine card color based on priority
    Color cardColor;
    switch (task.priority) {
      case 'high':
        cardColor = Colors.red.shade50;
        break;
      case 'medium':
        cardColor = Colors.orange.shade50;
        break;
      case 'low':
        cardColor = Colors.green.shade50;
        break;
      default:
        cardColor = Colors.grey.shade50;
    }

    return Card(
      color: cardColor,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: InkWell(
        onTap: () => Get.to(() => TaskDetailScreen(task: task)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Checkbox(
                    value: task.isCompleted,
                    onChanged: (_) => taskController.toggleTaskCompletion(task.id),
                  ),
                ],
              ),
              if (task.description != null && task.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    task.description!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (task.dueDate != null)
                    Chip(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      label: Text(
                        '${task.dueDate!.day}/${task.dueDate!.month}',
                        style: const TextStyle(fontSize: 10),
                      ),
                      backgroundColor: _getDueDateColor(task.dueDate!),
                      padding: EdgeInsets.zero,
                    ),
                  if (task.isRecurring) const Icon(Icons.repeat, size: 16, color: Colors.blue),
                  if (task.subtasks != null && task.subtasks!.isNotEmpty)
                    Text(
                      '${task.subtasks!.where((subtask) => subtask.isCompleted).length}/${task.subtasks!.length}',
                      style: const TextStyle(fontSize: 12),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Get color based on due date proximity
  Color _getDueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;

    if (difference < 0) {
      return Colors.red.shade200; // Overdue
    } else if (difference == 0) {
      return Colors.orange.shade200; // Due today
    } else if (difference <= 3) {
      return Colors.yellow.shade200; // Due soon
    } else {
      return Colors.green.shade200; // Due later
    }
  }
}
