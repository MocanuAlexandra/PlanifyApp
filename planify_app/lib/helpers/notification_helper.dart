import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:planify_app/helpers/utility.dart';

import '../screens/agenda/overall_agenda_screen.dart';
import '../models/task.dart';

class NotificationHelper {
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
        return NotificationHelper.onActionReceivedMethod(
            context, receivedAction);
      },
      onDismissActionReceivedMethod: (ReceivedAction receivedAction) {
        return NotificationHelper.onDismissActionReceivedMethod(
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
      BuildContext context, ReceivedAction receivedAction) async {
    // Navigate into pages, avoiding to open the notification details page over another details page already opened
    Navigator.of(context).pushNamed(OverallAgendaScreen.routeName);
  }

  static void addNotification(Task newTask) {
    //set the notification time to 10 minutes before the task time
    TimeOfDay notificationTime = Utility.tenMinutesBefore(newTask.time!);

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: newTask.title.hashCode + newTask.time!.hour + newTask.time!.minute,
        channelKey: 'basic_channel',
        title: "Reminder for task: ${newTask.title}",
        body: "Due time: ${newTask.time!.hour}:${newTask.time!.minute}",
        payload: {'id': newTask.id},
        displayOnBackground: true,
        displayOnForeground: true,
        category: NotificationCategory.Event,
      ),
      schedule: NotificationCalendar(
        hour: notificationTime.hour,
        minute: notificationTime.minute,
        second: 0,
        millisecond: 0,
        repeats: false,
      ),
    );
  }

  static void deleteNotification(Task task) {
    AwesomeNotifications().cancelSchedule(
        task.title.hashCode + task.time!.hour + task.time!.minute);
  }

  static void deleteNotificationWithMoreArguments(
      String title, TimeOfDay? time) {
    AwesomeNotifications()
        .cancelSchedule(title.hashCode + time!.hour + time.minute);
  }

  static void createNotificationWithMoreArguments(
      String title, TimeOfDay? time) {
    TimeOfDay notificationTime = Utility.tenMinutesBefore(time!);

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: title.hashCode + notificationTime.hour + notificationTime.minute,
        channelKey: 'basic_channel',
        title: "Reminder for task: $title",
        body: "Due time: ${notificationTime.hour}:${notificationTime.minute}",
        displayOnBackground: true,
        displayOnForeground: true,
        category: NotificationCategory.Event,
      ),
      schedule: NotificationCalendar(
        hour: notificationTime.hour,
        minute: notificationTime.minute,
        second: 0,
        millisecond: 0,
        repeats: false,
      ),
    );
  }
}
