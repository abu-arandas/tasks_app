import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../models/task.dart';
import '../../controllers/task_controller.dart';
import '../screens/task_detail_screen.dart';

class TaskListItem extends StatelessWidget {
  final Task task;

  const TaskListItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final TaskController taskController = Get.find<TaskController>();

    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => taskController.deleteTask(task.id),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => taskController.toggleTaskCompletion(task.id),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            icon: task.isCompleted ? Icons.close : Icons.check,
            label: task.isCompleted ? 'Undo' : 'Complete',
          ),
        ],
      ),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) => taskController.toggleTaskCompletion(task.id),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: task.description != null && task.description!.isNotEmpty
            ? Text(
                task.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: task.isCompleted ? Colors.grey : null,
                ),
              )
            : null,
        trailing: task.dueDate != null ? _buildDueDate(task.dueDate!, task.isCompleted) : null,
        onTap: () {
          Get.to(() => TaskDetailScreen(task: task));
        },
      ),
    );
  }

  Widget _buildDueDate(DateTime dueDate, bool isCompleted) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);

    final bool isOverdue = dueDay.isBefore(today) && !isCompleted;
    final bool isToday = dueDay.isAtSameMomentAs(today);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOverdue
            ? Colors.red.withOpacity(0.1)
            : isToday
                ? Colors.amber.withOpacity(0.1)
                : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _formatDueDate(dueDate),
        style: TextStyle(
          fontSize: 12,
          color: isOverdue
              ? Colors.red
              : isToday
                  ? Colors.amber.shade800
                  : Colors.blue,
          fontWeight: isOverdue || isToday ? FontWeight.bold : null,
        ),
      ),
    );
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dueDate = DateTime(date.year, date.month, date.day);

    if (dueDate.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (dueDate.isAtSameMomentAs(tomorrow)) {
      return 'Tomorrow';
    } else if (dueDate.isAtSameMomentAs(yesterday)) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
