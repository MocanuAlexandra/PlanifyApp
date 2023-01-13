import 'package:planify_app/models/task_adress.dart';

enum Priority { casual, necessary, important }

class Task {
  final String? id;
  final String? title;
  final DateTime? dueDate;
  final String? time;
  final TaskAdress? address;
  final String? priority;
  bool isDone;

  Task({
    this.id,
    this.title,
    this.dueDate,
    this.time,
    this.address,
    this.priority,
    this.isDone = false,
  });
}
