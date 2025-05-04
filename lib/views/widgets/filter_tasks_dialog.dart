import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/task_controller.dart';

class FilterTasksDialog extends StatefulWidget {
  const FilterTasksDialog({super.key});

  @override
  State<FilterTasksDialog> createState() => _FilterTasksDialogState();
}

class _FilterTasksDialogState extends State<FilterTasksDialog> {
  final TaskController _taskController = Get.find<TaskController>();

  // Filter states
  final RxBool _showCompleted = true.obs;
  final RxBool _showIncomplete = true.obs;
  final RxString _priorityFilter = 'all'.obs;
  final Rx<DateTime?> _dueDateFilter = Rx<DateTime?>(null);
  final RxBool _filterByDueDate = false.obs;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Tasks'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Obx(() => Checkbox(
                      value: _showCompleted.value,
                      onChanged: (value) {
                        _showCompleted.value = value ?? true;
                      },
                    )),
                const Text('Show Completed Tasks'),
              ],
            ),
            Row(
              children: [
                Obx(() => Checkbox(
                      value: _showIncomplete.value,
                      onChanged: (value) {
                        _showIncomplete.value = value ?? true;
                      },
                    )),
                const Text('Show Incomplete Tasks'),
              ],
            ),
            const Divider(),
            const Text('Priority', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Obx(() => DropdownButton<String>(
                  value: _priorityFilter.value,
                  isExpanded: true,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      _priorityFilter.value = newValue;
                    }
                  },
                  items: <String>['all', 'low', 'medium', 'high'].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value == 'all' ? 'All Priorities' : '${value[0].toUpperCase()}${value.substring(1)}'),
                    );
                  }).toList(),
                )),
            const Divider(),
            const Text('Due Date', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Obx(() => Checkbox(
                      value: _filterByDueDate.value,
                      onChanged: (value) {
                        _filterByDueDate.value = value ?? false;
                      },
                    )),
                const Text('Filter by Due Date'),
              ],
            ),
            Obx(() => _filterByDueDate.value
                ? Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _dueDateFilter.value ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (picked != null) {
                              _dueDateFilter.value = picked;
                            }
                          },
                          child: Text(
                            _dueDateFilter.value != null
                                ? '${_dueDateFilter.value!.day}/${_dueDateFilter.value!.month}/${_dueDateFilter.value!.year}'
                                : 'Select Date',
                          ),
                        ),
                      ),
                      if (_dueDateFilter.value != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _dueDateFilter.value = null;
                          },
                        ),
                    ],
                  )
                : const SizedBox.shrink()),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Apply filters
            _taskController.applyFilters(
              showCompleted: _showCompleted.value,
              showIncomplete: _showIncomplete.value,
              priority: _priorityFilter.value == 'all' ? null : _priorityFilter.value,
              dueDate: _filterByDueDate.value ? _dueDateFilter.value : null,
            );
            Get.back();
          },
          child: const Text('Apply'),
        ),
        TextButton(
          onPressed: () {
            // Reset filters
            _showCompleted.value = true;
            _showIncomplete.value = true;
            _priorityFilter.value = 'all';
            _dueDateFilter.value = null;
            _filterByDueDate.value = false;
            _taskController.resetFilters();
            Get.back();
          },
          child: const Text('Reset'),
        ),
      ],
    );
  }
}
