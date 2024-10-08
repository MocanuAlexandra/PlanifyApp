import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../database_helper_service.dart';
import '../../helpers/utility.dart';
import '../../models/task.dart';
import '../../models/task_reminder.dart';

class LocalNotificationService {
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
              defaultColor: const Color.fromARGB(255, 1, 96, 100),
              ledColor: Colors.white)
        ],
        debug: true);
  }

  static void setListeners(BuildContext context) {
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: LocalNotificationService.onActionReceivedMethod,
        onDismissActionReceivedMethod:
            LocalNotificationService.onDismissActionReceivedMethod);

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
      ReceivedAction receivedAction) async {}

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (receivedAction.buttonKeyPressed == 'delay') {
      //get the task id
      var taskId = receivedAction.payload!['groupKey'];

      //get the task
      var task = await DBHelper.getTaskById(taskId!);

      //create a new notification with a delay of 5 minutes
      _createLocalNotification(taskId, task);
    } else if (receivedAction.buttonKeyPressed == 'done') {
      //get the task id
      var taskId = receivedAction.payload!['groupKey'];

      //mark the task as done
      DBHelper.markTaskAsDone(taskId!);
    } else if (receivedAction.buttonKeyPressed == 'ok') {
      //close the notification
      AwesomeNotifications().cancel(receivedAction.id!);
    }
  }

  static void createLocationBasedNotification(String taskId, String taskTitle,
      String locationName, String type, DateTime notificationTime) {
    //create the notification
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: type.hashCode + notificationTime.hashCode,
        channelKey: 'basic_channel',
        title: "You are near $locationName ",
        body: "You have a task you can do here: $taskTitle",
        displayOnBackground: true,
        displayOnForeground: true,
        groupKey: taskId,
        payload: {
          'groupKey': taskId,
        },
      ),
      schedule: NotificationCalendar(
          hour: notificationTime.hour, minute: notificationTime.minute),
      actionButtons: [
        NotificationActionButton(
          key: 'done',
          label: 'MARK AS DONE',
          autoDismissible: true,
          actionType: ActionType.SilentAction,
        ),
      ],
    );
  }

  /// Use this method to create a local notification
  static void createNotificationForTask(
      Task newTask, String reminder, TaskReminder newReminder, String taskId) {
    //set the date & time of the notification
    TimeOfDay? notificationTime;
    DateTime? notificationDate;

    if (newTask.dueTime != null) {
      notificationTime = Utility.reminderToTime(reminder, newTask.dueTime!);
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
        body: Utility.notificationBodyString(newTask.dueDate, newTask.dueTime),
        displayOnBackground: true,
        displayOnForeground: true,
        groupKey: taskId,
        payload: {
          'groupKey': taskId,
        },
      ),
      schedule: (notificationDate != null && notificationTime != null)
          ? NotificationCalendar(
              day: notificationDate.day,
              month: notificationDate.month,
              year: notificationDate.year,
              hour: notificationTime.hour,
              minute: notificationTime.minute,
              repeats: false,
            )
          : (notificationDate != null)
              ? NotificationCalendar(
                  day: notificationDate.day,
                  month: notificationDate.month,
                  year: notificationDate.year,
                  repeats: false,
                )
              : (notificationTime != null)
                  ? NotificationCalendar(
                      hour: notificationTime.hour,
                      minute: notificationTime.minute,
                      repeats: false,
                    )
                  : null,
      actionButtons: [
        NotificationActionButton(
          key: 'done',
          label: 'MARK AS DONE',
          autoDismissible: true,
          actionType: ActionType.SilentAction,
        ),
        NotificationActionButton(
          key: 'delay',
          label: 'SNOOZE 5 MIN',
          autoDismissible: true,
          actionType: ActionType.SilentAction,
        ),
      ],
    );
  }

  /// Use this method to create a notification when user shares a task with other users
  // so that the other users can be notified
  static void createNotificationForSharedUser(RemoteNotification message) {
    //set the date & time of the notification
    TimeOfDay? notificationTime = TimeOfDay.now();
    DateTime? notificationDate = DateTime.now();

    //create the notification
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: Random().nextInt(10),
        channelKey: 'basic_channel',
        title: message.title,
        body: message.body,
        displayOnBackground: true,
        displayOnForeground: true,
      ),
      schedule: NotificationCalendar(
        day: notificationDate.day,
        month: notificationDate.month,
        year: notificationDate.year,
        hour: notificationTime.hour,
        minute: notificationTime.minute,
        repeats: false,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'ok',
          label: 'OK',
          autoDismissible: true,
          actionType: ActionType.SilentAction,
        ),
      ],
    );
  }

  //delete all notifications for a group key
  static void deleteNotification(String groupKey) {
    AwesomeNotifications().cancelNotificationsByGroupKey(groupKey);
  }

  //Method used when user snoozze his reminder
  @pragma("vm:entry-point")
  static Future<void> _createLocalNotification(String taskId, Task task) async {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: Random().nextInt(1000),
        channelKey: 'basic_channel',
        title: "Reminder for task: ${task.title}",
        body: Utility.notificationBodyString(task.dueDate, task.dueTime),
        displayOnBackground: true,
        displayOnForeground: true,
        groupKey: taskId,
        payload: {
          'groupKey': taskId,
        },
      ),
      schedule: NotificationCalendar(
        hour: DateTime.now().hour,
        minute: DateTime.now().minute + 5,
        repeats: false,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'done',
          label: 'MARK AS DONE',
          autoDismissible: true,
          actionType: ActionType.SilentAction,
        ),
        NotificationActionButton(
          key: 'delay',
          label: 'SNOOZE 5 MIN',
          autoDismissible: true,
          actionType: ActionType.SilentAction,
        ),
      ],
    );
  }
}
