import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/task.dart';
import '../../controllers/task_controller.dart';
import '../../controllers/tag_controller.dart';
import '../../controllers/reminder_controller.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime? _dueDate;
  late String _priority;
  late bool _isCompleted;

  final TaskController _taskController = Get.find<TaskController>();
  final TagController _tagController = Get.find<TagController>();
  final ReminderController _reminderController = Get.find<ReminderController>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description ?? '');
    _dueDate = widget.task.dueDate;
    _priority = widget.task.priority ?? 'medium';
    _isCompleted = widget.task.isCompleted;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _deleteTask();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Switch(
                  value: _isCompleted,
                  onChanged: (value) {
                    setState(() {
                      _isCompleted = value;
                    });
                  },
                ),
                Text(_isCompleted ? 'Completed' : 'Pending'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Due Date:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDueDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _dueDate == null ? 'No date selected' : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                      ),
                    ),
                  ),
                ),
                if (_dueDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _dueDate = null;
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Priority:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPriorityButton('low', 'Low', Colors.green),
                _buildPriorityButton('medium', 'Medium', Colors.amber),
                _buildPriorityButton('high', 'High', Colors.red),
              ],
            ),
            const SizedBox(height: 24),
            _buildTagsSection(),
            const SizedBox(height: 24),
            _buildRemindersSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveTask,
        child: const Icon(Icons.save),
      ),
    );
  }

  Widget _buildPriorityButton(String value, String label, Color color) {
    return InkWell(
      onTap: () {
        setState(() {
          _priority = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _priority == value ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _priority == value ? color : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: _priority == value ? color : Colors.grey.shade700,
            fontWeight: _priority == value ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Tags:', style: TextStyle(fontWeight: FontWeight.bold)),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Tag'),
              onPressed: () {
                // TODO: Implement add tag functionality
              },
            ),
          ],
        ),
        Obx(() {
          if (_tagController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final taskTags =
              widget.task.tagIds.map((tagId) => _tagController.getTagById(tagId)).where((tag) => tag != null).toList();

          if (taskTags.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('No tags added'),
            );
          }

          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: taskTags.map((tag) {
              return Chip(
                label: Text(tag!.name),
                backgroundColor: Color(int.parse('0xFF${tag.color.substring(1)}')),
                labelStyle: const TextStyle(color: Colors.white),
                deleteIcon: const Icon(Icons.clear, size: 18, color: Colors.white),
                onDeleted: () {
                  // TODO: Implement remove tag functionality
                },
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildRemindersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Reminders:', style: TextStyle(fontWeight: FontWeight.bold)),
            TextButton.icon(
              icon: const Icon(Icons.add_alarm),
              label: const Text('Add Reminder'),
              onPressed: () {
                // TODO: Implement add reminder functionality
              },
            ),
          ],
        ),
        Obx(() {
          final taskReminders = _reminderController.getRemindersForTask(widget.task.id);

          if (taskReminders.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('No reminders set'),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: taskReminders.length,
            itemBuilder: (context, index) {
              final reminder = taskReminders[index];
              return ListTile(
                leading: const Icon(Icons.alarm),
                title: Text(
                  '${reminder.reminderTime.day}/${reminder.reminderTime.month}/${reminder.reminderTime.year} at ${reminder.reminderTime.hour}:${reminder.reminderTime.minute.toString().padLeft(2, '0')}',
                ),
                subtitle: reminder.isRepeating ? Text('Repeats ${reminder.repeatPattern}') : null,
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _reminderController.deleteReminder(reminder.id);
                  },
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _saveTask() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task title cannot be empty')),
      );
      return;
    }

    final updatedTask = widget.task.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      isCompleted: _isCompleted,
      dueDate: _dueDate,
      priority: _priority,
      updatedAt: DateTime.now(),
    );

    _taskController.updateTask(updatedTask);
    Navigator.of(context).pop();
  }

  void _deleteTask() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _taskController.deleteTask(widget.task.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
