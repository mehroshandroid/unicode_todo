import 'package:hive_flutter/adapters.dart';

part 'task_dto.g.dart';

@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });
}
