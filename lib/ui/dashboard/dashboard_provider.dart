import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../data/task_dto.dart';

final tasksProvider = StateNotifierProvider<TasksNotifier, List<Task>>((ref) {
  return TasksNotifier();
});

class TasksNotifier extends StateNotifier<List<Task>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TasksNotifier() : super([]) {
    loadTasks();
  }

  final Box<Task> tasksBox = Hive.box<Task>('tasksBox');

  void loadTasks() {
    state = tasksBox.values.toList();
  }

  void addTask(Task task) {
    tasksBox.add(task);
    state = [...state, task];
  }

  void toggleTaskCompletion(int index) {
    Task task = state[index];
    task.isCompleted = !task.isCompleted;
    tasksBox.putAt(index, task);
    state = [...state];
  }

  // Method to clear all tasks
  void clearAllTasks() {
    tasksBox.clear();
    state = [];
  }

  // Method to edit a task
  void editTask(int index, String newTitle) {
    Task task = state[index];
    task.title = newTitle;
    tasksBox.putAt(index, task);
    state = [...state];
  }

  // Method to delete a task
  void deleteTask(int index) {
    tasksBox.deleteAt(index);
    state = List.from(state)..removeAt(index);
  }

  Future<void> syncTasksWithFirebase() async {
    final tasks = tasksBox.values.toList();
    final tasksCollection = _firestore.collection('tasks');

    // Sync each task to Firebase
    for (var task in tasks) {
      await tasksCollection.doc(task.id).set({
        'title': task.title,
        'isCompleted': task.isCompleted,
        'timestamp': DateTime.now(),
      });
    }
  }
}
