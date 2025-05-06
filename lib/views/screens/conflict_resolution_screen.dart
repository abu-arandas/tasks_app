import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/conflict.dart';
import '../../models/task.dart';
import '../../models/tag.dart';
import '../../models/reminder.dart';
import '../../services/conflict_service.dart';

class ConflictResolutionScreen extends StatelessWidget {
  final ConflictService _conflictService = Get.find<ConflictService>();

  ConflictResolutionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resolve Conflicts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _conflictService.loadUnresolvedConflicts(),
          ),
        ],
      ),
      body: Obx(() {
        if (_conflictService.conflicts.isEmpty) {
          return const Center(
            child: Text('No conflicts to resolve'),
          );
        }

        return ListView.builder(
          itemCount: _conflictService.conflicts.length,
          itemBuilder: (context, index) {
            final conflict = _conflictService.conflicts[index];
            return _buildConflictCard(context, conflict);
          },
        );
      }),
    );
  }

  Widget _buildConflictCard(BuildContext context, Conflict conflict) {
    // Create title based on entity type
    String title = 'Unknown Conflict';
    Widget contentWidget = const SizedBox.shrink();

    switch (conflict.entityType) {
      case 'task':
        final localTask = Task.fromJson(conflict.localData);
        final remoteTask = Task.fromJson(conflict.remoteData);
        title = 'Task Conflict: ${localTask.title}';
        contentWidget = _buildTaskConflictContent(localTask, remoteTask, conflict);
        break;
      case 'tag':
        final localTag = Tag.fromJson(conflict.localData);
        final remoteTag = Tag.fromJson(conflict.remoteData);
        title = 'Tag Conflict: ${localTag.name}';
        contentWidget = _buildTagConflictContent(localTag, remoteTag, conflict);
        break;
      case 'reminder':
        final localReminder = Reminder.fromJson(conflict.localData);
        final remoteReminder = Reminder.fromJson(conflict.remoteData);
        title = 'Reminder Conflict';
        contentWidget = _buildReminderConflictContent(localReminder, remoteReminder, conflict);
        break;
    }

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ExpansionTile(
        title: Text(title),
        subtitle: Text('Created: ${conflict.createdAt.toString().substring(0, 16)}'),
        children: [contentWidget],
      ),
    );
  }

  Widget _buildTaskConflictContent(Task localTask, Task remoteTask, Conflict conflict) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildComparisonRow('Title', localTask.title, remoteTask.title),
          _buildComparisonRow('Description', localTask.description ?? 'None', remoteTask.description ?? 'None'),
          _buildComparisonRow('Completed', localTask.isCompleted.toString(), remoteTask.isCompleted.toString()),
          _buildComparisonRow('Priority', localTask.priority ?? 'None', remoteTask.priority ?? 'None'),
          _buildComparisonRow('Due Date', localTask.dueDate?.toString().substring(0, 16) ?? 'None',
              remoteTask.dueDate?.toString().substring(0, 16) ?? 'None'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _conflictService.resolveConflict(conflict, true),
                child: const Text('Use Local'),
              ),
              ElevatedButton(
                onPressed: () => _conflictService.resolveConflict(conflict, false),
                child: const Text('Use Remote'),
              ),
              ElevatedButton(
                onPressed: () => _showMergeDialog(conflict, localTask, remoteTask),
                child: const Text('Merge'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTagConflictContent(Tag localTag, Tag remoteTag, Conflict conflict) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildComparisonRow('Name', localTag.name, remoteTag.name),
          _buildComparisonRow('Color', localTag.color, remoteTag.color),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _conflictService.resolveConflict(conflict, true),
                child: const Text('Use Local'),
              ),
              ElevatedButton(
                onPressed: () => _conflictService.resolveConflict(conflict, false),
                child: const Text('Use Remote'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReminderConflictContent(Reminder localReminder, Reminder remoteReminder, Conflict conflict) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildComparisonRow('Time', localReminder.reminderTime.toString().substring(0, 16),
              remoteReminder.reminderTime.toString().substring(0, 16)),
          _buildComparisonRow('Repeating', localReminder.isRepeating.toString(), remoteReminder.isRepeating.toString()),
          _buildComparisonRow('Pattern', localReminder.repeatPattern ?? 'None', remoteReminder.repeatPattern ?? 'None'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _conflictService.resolveConflict(conflict, true),
                child: const Text('Use Local'),
              ),
              ElevatedButton(
                onPressed: () => _conflictService.resolveConflict(conflict, false),
                child: const Text('Use Remote'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String label, String localValue, String remoteValue) {
    final bool isDifferent = localValue != remoteValue;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              color: isDifferent ? Colors.red.withOpacity(0.1) : null,
              child: Text(localValue),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              color: isDifferent ? Colors.green.withOpacity(0.1) : null,
              child: Text(remoteValue),
            ),
          ),
        ],
      ),
    );
  }

  void _showMergeDialog(Conflict conflict, Task localTask, Task remoteTask) {
    final mergedData = Map<String, dynamic>.from(localTask.toJson());

    Get.dialog(
      AlertDialog(
        title: const Text('Merge Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMergeField('Title', localTask.title, remoteTask.title, (value) {
                mergedData['title'] = value;
              }),
              _buildMergeField('Description', localTask.description ?? '', remoteTask.description ?? '', (value) {
                mergedData['description'] = value.isEmpty ? null : value;
              }),
              _buildMergeCheckbox('Completed', localTask.isCompleted, remoteTask.isCompleted, (value) {
                mergedData['isCompleted'] = value;
              }),
              _buildMergeField('Priority', localTask.priority ?? '', remoteTask.priority ?? '', (value) {
                mergedData['priority'] = value.isEmpty ? null : value;
              }),
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
              Get.back();
              _conflictService.mergeAndResolveConflict(conflict, mergedData);
            },
            child: const Text('Save Merged Version'),
          ),
        ],
      ),
    );
  }

  Widget _buildMergeField(String label, String localValue, String remoteValue, Function(String) onChanged) {
    final TextEditingController controller = TextEditingController(text: localValue);
    final bool isDifferent = localValue != remoteValue;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          if (isDifferent)
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    color: Colors.red.withOpacity(0.1),
                    child: Text('Local: $localValue'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    color: Colors.green.withOpacity(0.1),
                    child: Text('Remote: $remoteValue'),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Merged Value',
            ),
            onChanged: onChanged,
          ),
          if (isDifferent)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    controller.text = localValue;
                    onChanged(localValue);
                  },
                  child: const Text('Use Local'),
                ),
                TextButton(
                  onPressed: () {
                    controller.text = remoteValue;
                    onChanged(remoteValue);
                  },
                  child: const Text('Use Remote'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMergeCheckbox(String label, bool localValue, bool remoteValue, Function(bool) onChanged) {
    final bool isDifferent = localValue != remoteValue;
    final RxBool value = localValue.obs;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          if (isDifferent)
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    color: Colors.red.withOpacity(0.1),
                    child: Text('Local: ${localValue ? 'Yes' : 'No'}'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    color: Colors.green.withOpacity(0.1),
                    child: Text('Remote: ${remoteValue ? 'Yes' : 'No'}'),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 4),
          Obx(() => CheckboxListTile(
                title: const Text('Merged Value'),
                value: value.value,
                onChanged: (newValue) {
                  if (newValue != null) {
                    value.value = newValue;
                    onChanged(newValue);
                  }
                },
              )),
          if (isDifferent)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    value.value = localValue;
                    onChanged(localValue);
                  },
                  child: const Text('Use Local'),
                ),
                TextButton(
                  onPressed: () {
                    value.value = remoteValue;
                    onChanged(remoteValue);
                  },
                  child: const Text('Use Remote'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
