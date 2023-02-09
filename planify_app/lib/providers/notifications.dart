import 'package:flutter/material.dart';

import '../models/task_notification.dart';
import '../database/database_helper.dart';

class Notifications with ChangeNotifier {
  List<TaskNotification> _notifications = [];

  List<TaskNotification> get categoriesList {
    return [..._notifications];
  }

  Future<void> fetchNotifications(String taskId) async {
    final notificationsData = await DBHelper.fetchNotifications(taskId);

    _notifications = notificationsData.map(
      (notification) {
        return TaskNotification(
          id: notification['id'],
          contentId: notification['contentId'],
          reminder: notification['reminder'],
        );
      },
    ).toList();
  }
}
