import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/reminder_controller.dart';
import '../../controllers/task_controller.dart';
import '../../models/reminder.dart';
import '../../models/task.dart';

class ReminderManagementScreen extends StatefulWidget {
  const ReminderManagementScreen({super.key});

  @override
  State<ReminderManagementScreen> createState() => _ReminderManagementScreenState();
}

class _ReminderManagementScreenState extends State<ReminderManagementScreen> {
  final ReminderController _reminderController = Get.find<ReminderController>();
  final TaskController _taskController = Get.find<TaskController>();

  @override
  void initState() {
    super.initState();
    _reminderController.fetchReminders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddReminderDialog(context),
            tooltip: 'Add Reminder',
          ),
        ],
      ),
      body: Obx(() {
        if (_reminderController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_reminderController.reminders.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No reminders set',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap the + button to add a reminder',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Group reminders by date
        final Map<String, List<Reminder>> groupedReminders = {};
        for (final reminder in _reminderController.reminders) {
          final dateKey = _formatDate(reminder.reminderTime);
          if (!groupedReminders.containsKey(dateKey)) {
            groupedReminders[dateKey] = [];
          }
          groupedReminders[dateKey]!.add(reminder);
        }

        // Sort dates
        final sortedDates = groupedReminders.keys.toList()..sort((a, b) => _parseDate(a).compareTo(_parseDate(b)));

        return ListView.builder(
          itemCount: sortedDates.length,
          itemBuilder: (context, index) {
            final dateKey = sortedDates[index];
            final reminders = groupedReminders[dateKey]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    dateKey,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                ...reminders.map((reminder) => _buildReminderItem(reminder)),
                const Divider(),
              ],
            );
          },
        );
      }),
    );
  }

  Widget _buildReminderItem(Reminder reminder) {
    // Find associated task
    final Task? task = _taskController.tasks.firstWhereOrNull(
      (task) => task.id == reminder.taskId,
    );

    return Dismissible(
      key: Key(reminder.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _reminderController.deleteReminder(reminder.id),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: reminder.isDismissed
              ? Colors.grey
              : reminder.isSnoozing
                  ? Colors.orange
                  : Colors.blue,
          child: Icon(
            reminder.isRepeating
                ? Icons.repeat
                : reminder.isSnoozing
                    ? Icons.snooze
                    : Icons.notifications_active,
            color: Colors.white,
          ),
        ),
        title: Text(
          task?.title ?? 'Unknown Task',
          style: TextStyle(
            decoration: reminder.isDismissed ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatTime(reminder.reminderTime),
              style: TextStyle(
                color: _isOverdue(reminder) && !reminder.isDismissed ? Colors.red : null,
              ),
            ),
            if (reminder.isRepeating && reminder.repeatPattern != null)
              Text('Repeats: ${_formatRepeatPattern(reminder.repeatPattern!)}'),
            if (reminder.isSnoozing && reminder.snoozeUntil != null)
              Text('Snoozed until: ${_formatTime(reminder.snoozeUntil!)}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!reminder.isDismissed)
              IconButton(
                icon: const Icon(Icons.snooze),
                onPressed: () => _showSnoozeDialog(context, reminder),
                tooltip: 'Snooze',
              ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditReminderDialog(context, reminder),
              tooltip: 'Edit',
            ),
          ],
        ),
      ),
    );
  }

  void _showAddReminderDialog(BuildContext context) {
    Task? selectedTask;
    DateTime selectedDateTime = DateTime.now().add(const Duration(hours: 1));
    bool isRepeating = false;
    String repeatPattern = 'daily';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Reminder'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task selection
                  DropdownButtonFormField<Task>(
                    decoration: const InputDecoration(
                      labelText: 'Select Task',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedTask,
                    items: _taskController.tasks
                        .map((task) => DropdownMenuItem<Task>(
                              value: task,
                              child: Text(
                                task.title,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                        .toList(),
                    onChanged: (Task? value) {
                      setState(() {
                        selectedTask = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Date & Time picker
                  ListTile(
                    title: const Text('Reminder Date & Time'),
                    subtitle: Text(
                      '${_formatDate(selectedDateTime)} at ${_formatTimeOnly(selectedDateTime)}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDateTime,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );

                      if (pickedDate != null) {
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                        );

                        if (pickedTime != null) {
                          setState(() {
                            selectedDateTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  // Repeating options
                  SwitchListTile(
                    title: const Text('Repeat Reminder'),
                    value: isRepeating,
                    onChanged: (value) {
                      setState(() {
                        isRepeating = value;
                      });
                    },
                  ),
                  if (isRepeating)
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Repeat Pattern',
                        border: OutlineInputBorder(),
                      ),
                      value: repeatPattern,
                      items: const [
                        DropdownMenuItem(value: 'daily', child: Text('Daily')),
                        DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                        DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                      ],
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() {
                            repeatPattern = value;
                          });
                        }
                      },
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (selectedTask != null) {
                    _reminderController.addReminder(
                      selectedTask!.id,
                      selectedDateTime,
                      isRepeating: isRepeating,
                      repeatPattern: isRepeating ? repeatPattern : null,
                    );
                    Get.back();
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditReminderDialog(BuildContext context, Reminder reminder) {
    DateTime selectedDateTime = reminder.reminderTime;
    bool isRepeating = reminder.isRepeating;
    String repeatPattern = reminder.repeatPattern ?? 'daily';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Reminder'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date & Time picker
                  ListTile(
                    title: const Text('Reminder Date & Time'),
                    subtitle: Text(
                      '${_formatDate(selectedDateTime)} at ${_formatTimeOnly(selectedDateTime)}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDateTime,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );

                      if (pickedDate != null) {
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                        );

                        if (pickedTime != null) {
                          setState(() {
                            selectedDateTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  // Repeating options
                  SwitchListTile(
                    title: const Text('Repeat Reminder'),
                    value: isRepeating,
                    onChanged: (value) {
                      setState(() {
                        isRepeating = value;
                      });
                    },
                  ),
                  if (isRepeating)
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Repeat Pattern',
                        border: OutlineInputBorder(),
                      ),
                      value: repeatPattern,
                      items: const [
                        DropdownMenuItem(value: 'daily', child: Text('Daily')),
                        DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                        DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                      ],
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() {
                            repeatPattern = value;
                          });
                        }
                      },
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  _reminderController.updateReminder(reminder);
                  Get.back();
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSnoozeDialog(BuildContext context, Reminder reminder) {
    int snoozeMinutes = 15; // Default snooze time

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Snooze Reminder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Snooze for:'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                _buildSnoozeChip(context, 5, snoozeMinutes, (value) {
                  snoozeMinutes = value;
                }),
                _buildSnoozeChip(context, 15, snoozeMinutes, (value) {
                  snoozeMinutes = value;
                }),
                _buildSnoozeChip(context, 30, snoozeMinutes, (value) {
                  snoozeMinutes = value;
                }),
                _buildSnoozeChip(context, 60, snoozeMinutes, (value) {
                  snoozeMinutes = value;
                }),
                _buildSnoozeChip(context, 120, snoozeMinutes, (value) {
                  snoozeMinutes = value;
                }),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _reminderController.snoozeReminder(reminder.id, Duration(minutes: snoozeMinutes));
              Get.back();
            },
            child: const Text('Snooze'),
          ),
        ],
      ),
    );
  }

  Widget _buildSnoozeChip(BuildContext context, int minutes, int selectedMinutes, Function(int) onSelected) {
    return StatefulBuilder(
      builder: (context, setState) {
        return ChoiceChip(
          label: Text(minutes < 60 ? '$minutes min' : '${minutes ~/ 60} hr'),
          selected: minutes == selectedMinutes,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                onSelected(minutes);
              });
            }
          },
        );
      },
    );
  }

  // Helper methods for date and time formatting
  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    if (dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day) {
      return 'Today';
    } else if (dateTime.year == tomorrow.year && dateTime.month == tomorrow.month && dateTime.day == tomorrow.day) {
      return 'Tomorrow';
    } else if (dateTime.year == yesterday.year && dateTime.month == yesterday.month && dateTime.day == yesterday.day) {
      return 'Yesterday';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} at ${_formatTimeOnly(dateTime)}';
  }

  String _formatTimeOnly(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatRepeatPattern(String pattern) {
    switch (pattern) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      default:
        return pattern;
    }
  }

  bool _isOverdue(Reminder reminder) {
    return !reminder.isDismissed && !reminder.isSnoozing && reminder.reminderTime.isBefore(DateTime.now());
  }

  DateTime _parseDate(String formattedDate) {
    final now = DateTime.now();
    if (formattedDate == 'Today') {
      return DateTime(now.year, now.month, now.day);
    } else if (formattedDate == 'Tomorrow') {
      return DateTime(now.year, now.month, now.day + 1);
    } else if (formattedDate == 'Yesterday') {
      return DateTime(now.year, now.month, now.day - 1);
    } else {
      final parts = formattedDate.split('/');
      return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
    }
  }
}
