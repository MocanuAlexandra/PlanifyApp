enum Priority { Important, Medium, Low }

class Task {
  final String? id;
  final String? title;
  final DateTime? dueDate;
  final bool isDone;
  final Priority? priority;

  Task({this.id,this.title, this.dueDate, this.isDone = false, this.priority});
}
