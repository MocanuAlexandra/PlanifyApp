import 'package:planify_app/models/task_adress.dart';

class Task {
  final String? id;
  final String? title;
  final DateTime? dueDate;
  final TaskAdress? address;

  Task({
    this.id,
    this.title,
    this.dueDate,
    this.address,
  });
}
