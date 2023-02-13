import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

import '../models/task_reminder.dart';
import '../helpers/utility.dart';
import '../models/task.dart';

class NotificationService {
  static Map notifiedPlaces = {};

  static void initialize() {
    AwesomeNotifications().initialize(
        // set the icon to null if you want to use the default app icon
        null,
        [
          NotificationChannel(
              channelGroupKey: 'basic_channel_group',
              channelKey: 'basic_channel',
              channelName: 'Basic notifications',
              channelDescription: 'Notification channel for basic tests',
              defaultColor: const Color(0xFF9D50DD),
              ledColor: Colors.white)
        ],
        debug: true);
  }

  static void setListeners(BuildContext context) {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: (ReceivedAction receivedAction) {
        return NotificationService.onActionReceivedMethod(
            context, receivedAction);
      },
      onDismissActionReceivedMethod: (ReceivedAction receivedAction) {
        return NotificationService.onDismissActionReceivedMethod(
            context, receivedAction);
      },
    );

    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        // This is just a basic example. For real apps, you must show some
        // friendly dialog box before call the request method.
        // This is very important to not harm the user experience
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      BuildContext context, ReceivedAction receivedAction) async {}

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      BuildContext context, ReceivedAction receivedAction) async {}

  static DateTime createLocationBasedNotification(String taskId,
      String locationName, String type, DateTime notificationTime) {
    //create the notification
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: type.hashCode + notificationTime.hashCode,
        channelKey: 'basic_channel',
        title: "You are near $locationName ",
        body: "You have a task you can do in this $type",
        displayOnBackground: true,
        displayOnForeground: true,
        groupKey: taskId,
      ),
      schedule: NotificationCalendar(
        hour: notificationTime.hour,
        minute: notificationTime.minute,
        repeats: false,
      ),
    );

    return notificationTime;
  }

  static void createNotification(
      Task newTask, String reminder, TaskReminder newReminder, String taskId) {
    //set the date & time of the notification
    TimeOfDay? notificationTime;
    DateTime? notificationDate;

    if (newTask.time != null) {
      notificationTime = Utility.reminderToTime(reminder, newTask.time!);
    }
    if (newTask.dueDate != null) {
      notificationDate = Utility.reminderToDate(reminder, newTask.dueDate!);
    }

    //create the notification
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: newReminder.contentId,
        channelKey: 'basic_channel',
        title: "Reminder for task: ${newTask.title}",
        body: Utility.notificationBodyString(newTask.dueDate, newTask.time),
        displayOnBackground: true,
        displayOnForeground: true,
        groupKey: taskId,
      ),
      schedule: notificationDate != null
          ? NotificationCalendar(
              day: notificationDate.day,
              month: notificationDate.month,
              year: notificationDate.year,
              repeats: false,
            )
          : notificationTime != null
              ? NotificationCalendar(
                  hour: notificationTime.hour,
                  minute: notificationTime.minute,
                  repeats: false,
                )
              : null,
    );
  }

//delete all notifications for a group key
  static void deleteNotification(String groupKey) {
    AwesomeNotifications().cancelNotificationsByGroupKey(groupKey);
  }

  static checkIfUserWasNotifiedAboutPlaceType(taskId, type, now) {
    var key = "$taskId-$type";
    if (notifiedPlaces.containsKey(key)) {
      var lastNotified = notifiedPlaces[key];
      var difference = now.difference(lastNotified);
      if (difference.inMinutes <= 30) {
        return true;
      }
    }
    notifiedPlaces[key] = now;
    return false;
  }
}
