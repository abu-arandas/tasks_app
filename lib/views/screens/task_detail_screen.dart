import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tasks_app/utils/error_handler.dart';
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
  late bool _isRecurring;
  late String? _recurrencePattern;
  late List<Task> _subtasks;

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
    _isRecurring = widget.task.isRecurring;
    _recurrencePattern = widget.task.recurrencePattern;
    _subtasks = List<Task>.from(widget.task.subtasks ?? []);
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
            // Recurring task options
            Row(
              children: [
                const Text('Recurring:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Switch(
                  value: _isRecurring,
                  onChanged: (value) {
                    setState(() {
                      _isRecurring = value;
                      if (!_isRecurring) {
                        _recurrencePattern = null;
                      } else {
                        _recurrencePattern ??= 'daily';
                      }
                    });
                  },
                ),
                Text(_isRecurring ? 'Yes' : 'No'),
              ],
            ),
            if (_isRecurring) ...[
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Recurrence Pattern',
                  border: OutlineInputBorder(),
                ),
                value: _recurrencePattern,
                items: const [
                  DropdownMenuItem(value: 'daily', child: Text('Daily')),
                  DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                  DropdownMenuItem(value: 'custom', child: Text('Custom')),
                ],
                onChanged: (value) {
                  setState(() {
                    _recurrencePattern = value;
                  });
                },
              ),
            ],
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
            const SizedBox(height: 24),
            _buildSubtasksSection(),
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
                _showTagSelectionDialog();
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
                  setState(() {
                    widget.task.tagIds.remove(tag.id);
                  });
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
                _showAddReminderDialog();
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
    // Validate title
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      Get.find<ErrorHandler>().handleValidationError('Title', 'Task title cannot be empty');
      return;
    }

    // Validate title length
    if (title.length > 100) {
      Get.find<ErrorHandler>().handleValidationError('Title', 'Task title cannot exceed 100 characters');
      return;
    }

    // Validate description length if provided
    final description = _descriptionController.text.trim();
    if (description.isNotEmpty && description.length > 500) {
      Get.find<ErrorHandler>().handleValidationError('Description', 'Task description cannot exceed 500 characters');
      return;
    }

    // Validate due date is not in the past if it was changed
    if (_dueDate != null && _dueDate != widget.task.dueDate) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dueDate = DateTime(_dueDate!.year, _dueDate!.month, _dueDate!.day);

      if (dueDate.isBefore(today)) {
        Get.find<ErrorHandler>().handleValidationError('Due Date', 'Due date cannot be in the past');
        return;
      }
    }

    final updatedTask = widget.task.copyWith(
      title: title,
      description: description.isEmpty ? null : description,
      isCompleted: _isCompleted,
      dueDate: _dueDate,
      priority: _priority,
      subtasks: _subtasks,
      isRecurring: _isRecurring,
      recurrencePattern: _recurrencePattern,
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

  void _showTagSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Tags'),
        content: SizedBox(
          width: double.maxFinite,
          child: Obx(() {
            if (_tagController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_tagController.tags.isEmpty) {
              return const Text('No tags available. Create some tags first.');
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: _tagController.tags.length,
              itemBuilder: (context, index) {
                final tag = _tagController.tags[index];
                final isSelected = widget.task.tagIds.contains(tag.id);

                return CheckboxListTile(
                  title: Text(tag.name),
                  value: isSelected,
                  activeColor: Color(int.parse('0xFF${tag.color.substring(1)}')),
                  onChanged: (selected) {
                    setState(() {
                      if (selected!) {
                        if (!widget.task.tagIds.contains(tag.id)) {
                          widget.task.tagIds.add(tag.id);
                        }
                      } else {
                        widget.task.tagIds.remove(tag.id);
                      }
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            );
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              _showCreateTagDialog();
            },
            child: const Text('Create New Tag'),
          ),
        ],
      ),
    );
  }

  void _showCreateTagDialog() {
    final nameController = TextEditingController();
    String selectedColor = _tagController.getPredefinedColors()[0]['value'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Tag'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Tag Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Select Color:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tagController.getPredefinedColors().map((colorMap) {
                final color = colorMap['value'];
                return InkWell(
                  onTap: () {
                    selectedColor = color;
                    Navigator.of(context).pop();
                    _showCreateTagDialog(); // Reopen with selected color
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(int.parse('0xFF${color.substring(1)}')),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selectedColor == color ? Colors.white : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                _tagController.addTag(nameController.text.trim(), selectedColor);
                Navigator.of(context).pop();
                _showTagSelectionDialog(); // Reopen tag selection
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Subtasks:', style: TextStyle(fontWeight: FontWeight.bold)),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Subtask'),
              onPressed: () {
                _showAddSubtaskDialog();
              },
            ),
          ],
        ),
        if (_subtasks.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('No subtasks added'),
          )
        else
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                final Task item = _subtasks.removeAt(oldIndex);
                _subtasks.insert(newIndex, item);
              });
            },
            children: _subtasks.asMap().entries.map((entry) {
              final int index = entry.key;
              final Task subtask = entry.value;
              return ListTile(
                key: Key('subtask_${subtask.id}'),
                leading: Checkbox(
                  value: subtask.isCompleted,
                  onChanged: (value) {
                    setState(() {
                      _subtasks[index] = subtask.copyWith(isCompleted: value ?? false);
                    });
                  },
                ),
                title: Text(
                  subtask.title,
                  style: TextStyle(
                    decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
                    color: subtask.isCompleted ? Colors.grey : null,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _showEditSubtaskDialog(index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () {
                        setState(() {
                          _subtasks.removeAt(index);
                        });
                      },
                    ),
                    ReorderableDragStartListener(
                      index: index,
                      child: const Icon(Icons.drag_handle),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  void _showAddSubtaskDialog() {
    final TextEditingController titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Subtask'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Subtask Title',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final title = titleController.text.trim();
              if (title.isNotEmpty) {
                setState(() {
                  _subtasks.add(Task(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: title,
                    isCompleted: false,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ));
                });
                Navigator.of(context).pop();
              } else {
                Get.find<ErrorHandler>().handleValidationError('Subtask', 'Subtask title cannot be empty');
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditSubtaskDialog(int index) {
    final TextEditingController titleController = TextEditingController(text: _subtasks[index].title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Subtask'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Subtask Title',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final title = titleController.text.trim();
              if (title.isNotEmpty) {
                setState(() {
                  _subtasks[index] = _subtasks[index].copyWith(
                    title: title,
                    updatedAt: DateTime.now(),
                  );
                });
                Navigator.of(context).pop();
              } else {
                Get.find<ErrorHandler>().handleValidationError('Subtask', 'Subtask title cannot be empty');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddReminderDialog() {
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    bool isRepeating = false;
    String repeatPattern = 'daily';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Reminder'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text('Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                ),
                ListTile(
                  title: Text('Time: ${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}'),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (picked != null) {
                      setState(() {
                        selectedTime = picked;
                      });
                    }
                  },
                ),
                SwitchListTile(
                  title: const Text('Repeat'),
                  value: isRepeating,
                  onChanged: (value) {
                    setState(() {
                      isRepeating = value;
                    });
                  },
                ),
                if (isRepeating)
                  DropdownButtonFormField<String>(
                    value: repeatPattern,
                    decoration: const InputDecoration(
                      labelText: 'Repeat Pattern',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'daily', child: Text('Daily')),
                      DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                      DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        repeatPattern = value!;
                      });
                    },
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final reminderTime = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );

                  _reminderController.addReminder(
                    widget.task.id,
                    reminderTime,
                    isRepeating: isRepeating,
                    repeatPattern: isRepeating ? repeatPattern : null,
                  );

                  Navigator.of(context).pop();
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }
}
