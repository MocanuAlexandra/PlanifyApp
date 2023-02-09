class TaskReminder {
  final String? id;
  final String? taskId;
  final int contentId;
  final String reminder;

  TaskReminder({
    this.id,
    this.taskId,
    required this.contentId,
    required this.reminder,
  });
}
