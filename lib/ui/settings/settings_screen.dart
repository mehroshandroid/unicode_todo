import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicode_todo/core/app_localizations.dart';

import '../dashboard/dashboard_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.translate('settings'),
          style: const TextStyle(fontSize: 24),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              child: const Text("Clear all tasks", style: TextStyle(
                fontSize: 16
              ),),
              onTap: () {
                ref.read(tasksProvider.notifier).clearAllTasks();
              },
            )
          ],
        ),
      ),
    );
  }
}
