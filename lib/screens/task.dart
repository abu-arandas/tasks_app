import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/controller/task.dart';
import '/controller/authentication.dart';

class TaskInformation extends StatelessWidget {
  final TaskModel task;
  const TaskInformation({super.key, required this.task});

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(
          task.title,
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.bold,
                height: 0.9,
              ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            info(context: context, title: 'Description', data: task.description),
            info(
              context: context,
              title: 'Time',
              data: task.endDate == null
                  ? '${DateFormat.yMMMd().format(task.startDate)} : ${DateFormat.jms().format(task.startDate)}'
                  : '${DateFormat.yMMMd().format(task.startDate)} : ${DateFormat.jms().format(task.startDate)}  -  ${DateFormat.yMMMd().format(task.endDate!)} : ${DateFormat.jms().format(task.endDate!)}',
            ),
            info(
              context: context,
              title: 'Description',
              data: progressString(task.progress),
            ),
          ],
        ),
        actions: [
          // delete
          if (task.progress != TaskProgress.done) ...{
            ElevatedButton(
              onPressed: () => TaskController.instance.deleteTask(context, task.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: const Text('delete'),
            ),
          },

          // start
          if (task.progress == TaskProgress.toDo) ...{
            ElevatedButton(
              onPressed: () => TaskController.instance.updateTask(
                context: context,
                task: task.copyWith(progress: TaskProgress.inProgress),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: const Text('start'),
            ),
          },

          // finish
          if (task.progress == TaskProgress.inProgress) ...{
            ElevatedButton(
              onPressed: () => TaskController.instance.updateTask(
                context: context,
                task: task.copyWith(progress: TaskProgress.done, endDate: DateTime.now()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: const Text('finish'),
            ),
          },
        ],
      );

  Widget info({required BuildContext context, required String title, required String data}) => Container(
        width: 350,
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Padding(
              padding: const EdgeInsets.all(8).copyWith(top: 0),
              child: Text(data),
            ),
          ],
        ),
      );
}

class NewTask extends StatefulWidget {
  const NewTask({super.key});

  @override
  State<NewTask> createState() => _NewTaskState();
}

class _NewTaskState extends State<NewTask> {
  GlobalKey<FormState> formState = GlobalKey();
  TextEditingController title = TextEditingController(), description = TextEditingController();

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(
          'New Task',
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.bold,
                height: 0.9,
              ),
        ),
        content: Form(
          key: formState,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //  title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  decoration: const InputDecoration(labelText: 'title'),
                  controller: title,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return '* required';
                    }
                    return null;
                  },
                ),
              ),

              // description
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  decoration: const InputDecoration(labelText: 'description', alignLabelWithHint: true),
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  maxLines: 10,
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if (formState.currentState!.validate()) {
                await TaskController.instance.tasks().then((value) => TaskController.instance.createTask(
                      context: context,
                      task: TaskModel(
                        id: value.length,
                        title: title.text,
                        startDate: DateTime.now(),
                        description: description.text,
                        progress: TaskProgress.toDo,
                        user: Authentication.instance.currentUser!.id,
                      ),
                    ));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('finish'),
          ),
        ],
      );
}
