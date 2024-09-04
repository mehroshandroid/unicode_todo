import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:unicode_todo/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await Firebase.initializeApp();
    await Hive.initFlutter(); // Initialize Hive for testing
    if (!Hive.isBoxOpen('tasksBox')) {
      await Hive.openBox('tasksBox'); // Open the required box for testing
    }
  });
  group('App Integration Test', () {
    testWidgets('Login, Add Task, and Logout', (WidgetTester tester) async {
      // Launch the app
      // app.main();
      await tester.pumpWidget(
        const ProviderScope(
          child: MyApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Step 1: Perform Login
      final emailField = find.byKey(const ValueKey('emailField'));
      final passwordField = find.byKey(const ValueKey('passwordField'));
      final loginButton = find.byKey(const ValueKey('loginButton'));

      await tester.enterText(emailField, 'mehrosh@gmail.com');
      await tester.enterText(passwordField, '123qwe');
      await tester.tap(loginButton);

      // Wait for login to complete
      await tester.pumpAndSettle();

      // Step 2: Add a Task
      final taskField = find.byKey(const ValueKey('taskField'));
      final addTaskButton = find.byKey(const ValueKey('addTaskButton'));

      await tester.enterText(taskField, 'New Task');
      await tester.tap(addTaskButton);

      // Wait for the task to be added
      await tester.pumpAndSettle();

      // Verify if the task was added
      expect(find.text('New Task'), findsOneWidget);

      // Step 3: Navigate to Settings and Logout
      final settingsButton = find.byKey(const ValueKey('settingsButton'));
      await tester.tap(settingsButton);

      // Wait for navigation
      await tester.pumpAndSettle();

      final logoutButton = find.byKey(const ValueKey('logoutButton'));
      await tester.tap(logoutButton);

      // Wait for logout to complete
      await tester.pumpAndSettle();

      // Verify if navigated back to login screen
      expect(find.text('Login'), findsOneWidget);
    });
  });

  tearDownAll(() async {
    if (Hive.isBoxOpen('tasksBox')) {
      await Hive.box('tasksBox').close();
      await Hive.deleteBoxFromDisk('tasksBo');
    }
  });
}
