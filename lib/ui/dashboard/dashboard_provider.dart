import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  /// Method to delete a task
  void deleteTask(int index) {
    tasksBox.deleteAt(index);
    state = List.from(state)..removeAt(index);
  }

  /// Syncs the current tasks stored in the Hive database with Firebase Firestore.
  ///
  /// This method first deletes all existing tasks in the Firebase collection
  /// associated with the user's email. After clearing the collection, it uploads
  /// the latest tasks from the local Hive database to Firestore.
  ///
  /// The tasks are stored in a collection named after the user's email address,
  /// with each task document identified by its unique `id`.
  ///
  /// This method assumes that the user is already authenticated via Firebase Auth.
  /// If no user is authenticated, or the user's email is null, the method will not
  /// perform any syncing operation.
  Future<void> syncTasksWithFirebase() async {
    final tasks = tasksBox.values.toList();
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null && user.email != null) {
      final tasksCollection = _firestore.collection(user.email!);

      // Delete all existing documents in the collection
      final existingTasks = await tasksCollection.get();
      for (var doc in existingTasks.docs) {
        await tasksCollection.doc(doc.id).delete();
      }

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

  /// Fetches the tasks from Firebase Firestore and syncs them with the local Hive database.
  ///
  /// This method retrieves the tasks collection associated with the authenticated user's
  /// email from Firestore. It checks each task to see if it already exists in the local
  /// Hive database. Only tasks that are not present in Hive are added, preventing
  /// unnecessary updates.
  ///
  /// The method should be called on app launch or whenever a user logs in to a new device,
  /// ensuring that all tasks are kept in sync across devices.
  Future<void> fetchAndSyncTasksFromFirebase() async {
    User? user = FirebaseAuth.instance.currentUser;

    // Ensure that the user is authenticated and has a valid email.
    if (user != null && user.email != null) {
      final tasksCollection = _firestore.collection(user.email!);

      // Fetch the tasks from Firebase Firestore
      final querySnapshot = await tasksCollection.get();

      // Iterate over each document and check if it already exists in Hive
      for (var doc in querySnapshot.docs) {
        final taskId = doc.id;
        final data = doc.data();

        // Check if the task already exists in Hive
        if (!tasksBox.containsKey(taskId)) {
          final task = Task(
            id: taskId,
            title: data['title'] ?? '',
            isCompleted: data['isCompleted'] ?? false,
          );

          // Add the task to the Hive box
          await tasksBox.put(task.id, task);
        }
      }

      // Load the tasks from Hive into the state
      loadTasks();
    }
  }
}
