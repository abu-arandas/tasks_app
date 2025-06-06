import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/task_controller.dart';
import '../../utils/error_handler.dart';

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _dueDate;
  String _priority = 'medium';
  final TaskController _taskController = Get.find<TaskController>();
  final ErrorHandler _errorHandler = ErrorHandler();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Task'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter task title',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Enter task description',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Due Date:'),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDueDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                      ),
                      child: Text(
                        _dueDate == null ? 'No date selected' : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Priority:'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPriorityButton('low', 'Low', Colors.green),
                _buildPriorityButton('medium', 'Medium', Colors.amber),
                _buildPriorityButton('high', 'High', Colors.red),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addTask,
          child: const Text('Add Task'),
        ),
      ],
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _addTask() {
    // Validate title
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _errorHandler.handleValidationError('Title', 'Task title cannot be empty');
      return;
    }

    // Validate title length
    if (title.length > 100) {
      _errorHandler.handleValidationError('Title', 'Task title cannot exceed 100 characters');
      return;
    }

    // Validate description length if provided
    final description = _descriptionController.text.trim();
    if (description.isNotEmpty && description.length > 500) {
      _errorHandler.handleValidationError('Description', 'Task description cannot exceed 500 characters');
      return;
    }

    // Validate due date is not in the past
    if (_dueDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dueDate = DateTime(_dueDate!.year, _dueDate!.month, _dueDate!.day);

      if (dueDate.isBefore(today)) {
        _errorHandler.handleValidationError('Due Date', 'Due date cannot be in the past');
        return;
      }
    }

    _taskController.addTask(
      title,
      description: description.isEmpty ? null : description,
      dueDate: _dueDate,
      priority: _priority,
    );

    Navigator.of(context).pop();
  }
}
