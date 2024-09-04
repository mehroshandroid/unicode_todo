import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicode_todo/ui/dashboard/dashboard_provider.dart';
import 'package:unicode_todo/ui/settings/settings_screen.dart';

import '../../core/app_localizations.dart';
import '../../data/task_dto.dart';
import '../../utils/nav_utils.dart';

class DashboardScreen extends ConsumerWidget {
  DashboardScreen({super.key});

  final TextEditingController taskController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);
    final activeTasks = tasks.where((task) => !task.isCompleted).toList();
    final completedTasks = tasks.where((task) => task.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.translate('to_do'),
          style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.w900),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              child: const Icon(Icons.settings),
              onTap: () {
                navigateTo(context, const SettingsScreen());
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: taskController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!
                          .translate('add_todo_item'),
                    ),
                    textInputAction: TextInputAction.done,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (taskController.text.trim().isEmpty) {
                      // Show a message if the input is empty
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context)!
                              .translate('enter_valid_task')),
                        ),
                      );
                    } else {
                      // Add the task to the list
                      ref.read(tasksProvider.notifier).addTask(
                            Task(
                                id: DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString(),
                                title: taskController.text.trim()),
                          );
                      // Clear the text field
                      taskController.clear();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: activeTasks.length,
                itemBuilder: (context, index) {
                  // Find the original index of the task in the full tasks list
                  final originalIndex = tasks.indexOf(activeTasks[index]);
                  final task = activeTasks[index];
                  return ListTile(
                    leading: Checkbox(
                      value: task.isCompleted,
                      onChanged: (value) {
                        ref
                            .read(tasksProvider.notifier)
                            .toggleTaskCompletion(originalIndex);
                      },
                    ),
                    title: Text(task.title),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            // Show a dialog to edit the task
                            showDialog(
                              context: context,
                              builder: (context) {
                                final TextEditingController editController =
                                    TextEditingController(text: task.title);

                                return AlertDialog(
                                  title: const Text('Edit Task'),
                                  content: TextField(
                                    controller: editController,
                                    decoration: const InputDecoration(
                                        hintText: 'Enter new title'),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        final newTitle =
                                            editController.text.trim();
                                        if (newTitle.isNotEmpty) {
                                          ref
                                              .read(tasksProvider.notifier)
                                              .editTask(
                                                  originalIndex, newTitle);
                                          Navigator.of(context).pop();
                                        } else {
                                          // Show a message if the input is empty
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Task title cannot be empty.'),
                                            ),
                                          );
                                        }
                                      },
                                      child: const Text('Save'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            // Delete the task
                            ref
                                .read(tasksProvider.notifier)
                                .deleteTask(originalIndex);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (completedTasks.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                "Completed Tasks",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: completedTasks.length,
                  itemBuilder: (context, index) {
                    // Find the original index of the task in the full tasks list
                    final originalIndex = tasks.indexOf(completedTasks[index]);
                    final task = completedTasks[index];
                    return ListTile(
                      leading: Checkbox(
                        value: task.isCompleted,
                        onChanged: (value) {
                          ref
                              .read(tasksProvider.notifier)
                              .toggleTaskCompletion(originalIndex);
                        },
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
