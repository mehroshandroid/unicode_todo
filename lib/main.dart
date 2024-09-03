import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:unicode_todo/core/app_localizations.dart';
import 'package:unicode_todo/ui/dashboard/dashboard_provider.dart';
import 'package:unicode_todo/ui/login/login_screen.dart';
import 'package:workmanager/workmanager.dart';
import 'firebase_options.dart';

import 'data/task_dto.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final container = ProviderContainer();
    final tasksNotifier = container.read(tasksProvider.notifier);
    await tasksNotifier.syncTasksWithFirebase();
    return Future.value(true);
  });
}

Future<void> main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox<Task>('tasksBox');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //work manager initialization
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  Workmanager().registerPeriodicTask(
    "syncTaskWithFirebase",
    "syncTaskWithFirebase",
    frequency: const Duration(hours: 6),
  );

  runApp(const ProviderScope(child: MyApp()) );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) {
          return supportedLocales.first;
        }
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      supportedLocales: const [
        Locale('en', ''),
        Locale('ar', ''),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: LoginScreen(),
    );
  }
}