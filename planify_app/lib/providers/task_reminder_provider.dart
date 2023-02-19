import 'package:flutter/material.dart';

import '../helpers/database_helper.dart';
import '../models/task_reminder.dart';

class TaskReminderProvider with ChangeNotifier {
  List<TaskReminder> _reminders = [];

  List<TaskReminder> get remindersList {
    return [..._reminders];
  }

  Future<void> fetchReminders(String taskId) async {
    final notificationsData = await DBHelper.fetchReminders(taskId);

    _reminders = notificationsData.map(
      (reminder) {
        return TaskReminder(
          id: reminder['id'],
          contentId: reminder['contentId'],
          reminder: reminder['reminder'],
        );
      },
    ).toList();
  }
}
