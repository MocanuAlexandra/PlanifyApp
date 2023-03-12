import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';
import 'database_helper.dart';

// Utility class
class Utility {
  static String priorityEnumToString(Priority? priority) {
    String priorityString = '';
    switch (priority) {
      case Priority.casual:
        priorityString = 'Casual';
        break;
      case Priority.necessary:
        priorityString = 'Necessary';
        break;
      case Priority.important:
        priorityString = 'Important';
        break;
      case Priority.unknown:
        priorityString = 'Unknown';
        break;
      case null:
        priorityString = 'Unknown';
    }
    return priorityString;
  }

  static String timeOfDayToString(TimeOfDay? selectedTime) {
    String time = "--:--";
    if (selectedTime != null) {
      //create a new time with the selected time
      time = selectedTime.hour < 10
          ? selectedTime.minute < 10
              ? '0${selectedTime.hour}:0${selectedTime.minute}'
              : '0${selectedTime.hour}:${selectedTime.minute}'
          : selectedTime.minute < 10
              ? '${selectedTime.hour}:0${selectedTime.minute}'
              : '${selectedTime.hour}:${selectedTime.minute}';
    }
    return time;
  }

  static Priority? stringToPriorityEnum(String? priority) {
    Priority? priorityEnum;
    switch (priority) {
      case 'Casual':
        priorityEnum = Priority.casual;
        break;
      case 'Necessary':
        priorityEnum = Priority.necessary;
        break;
      case 'Important':
        priorityEnum = Priority.important;
        break;
      case null:
        priorityEnum = null;
    }
    return priorityEnum;
  }

  static TimeOfDay? stringToTimeOfDay(String? time) {
    TimeOfDay? timeOfDay;

    if (time != null && time != '--:--') {
      //split the time string to get the hour and minute
      final timeSplit = time.split(':');
      //create a new time with the selected time
      timeOfDay = TimeOfDay(
          hour: int.parse(timeSplit[0]), minute: int.parse(timeSplit[1]));
    } else {
      timeOfDay = null;
    }
    return timeOfDay;
  }

  static DateTime? stringToDateTime(String? date) {
    DateTime? dateTime;
    if (date != null && date != '--/--/----') {
      dateTime = DateTime.parse(date);
    } else {
      dateTime = null;
    }
    return dateTime;
  }

  static dateTimeToString(DateTime? dueDate) {
    String date = '--/--/----';
    if (dueDate != null) {
      date = DateFormat('dd/MM/yyyy').format(dueDate);
    }
    return date;
  }

  static Future<bool?> displayQuestionDialog(
      BuildContext context, String text) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Question'),
              content: Text(text),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Yes')),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('No')),
              ],
            ));
  }

  static Future<bool?> displayInformationalDialog(
      BuildContext context, String text) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Information'),
              content: Text(
                text,
                softWrap: true,
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Ok')),
              ],
            ));
  }

  static List<String> getReminderTypes(
      bool? isDueTimeSelected, bool? isDueDateSelected) {
    //if the user selected only due time
    if (isDueDateSelected == false && isDueTimeSelected == true) {
      return [
        '5 minutes before',
        '10 minutes before',
        '15 minutes before',
        '30 minutes before',
        '1 hour before',
        '2 hours before',
      ];
      // if the user selected only due date
    } else if (isDueDateSelected == true && isDueTimeSelected == false) {
      return [
        '1 day before',
        '2 days before',
        '1 week before',
        '2 weeks before',
        '1 month before',
        '2 months before',
        '3 months before',
        '6 months before',
        '1 year before',
      ];
    }
    // if the suer selected both
    return [
      '5 minutes before',
      '10 minutes before',
      '15 minutes before',
      '30 minutes before',
      '1 hour before',
      '2 hours before',
      '1 day before',
      '2 days before',
      '1 week before',
      '2 weeks before',
      '1 month before',
      '2 months before',
      '3 months before',
      '6 months before',
      '1 year before',
    ];
  }

  static TimeOfDay? reminderToTime(String reminderType, TimeOfDay dueTime) {
    TimeOfDay? time;
    switch (reminderType) {
      case '5 minutes before':
        time = TimeOfDay(
            hour: dueTime.hour,
            minute: dueTime.minute - 5 < 0
                ? 60 + dueTime.minute - 5
                : dueTime.minute - 5);
        break;
      case '10 minutes before':
        time = TimeOfDay(
            hour: dueTime.hour,
            minute: dueTime.minute - 10 < 0
                ? 60 + dueTime.minute - 10
                : dueTime.minute - 10);
        break;
      case '15 minutes before':
        time = TimeOfDay(
            hour: dueTime.hour,
            minute: dueTime.minute - 15 < 0
                ? 60 + dueTime.minute - 15
                : dueTime.minute - 15);
        break;
      case '30 minutes before':
        time = TimeOfDay(
            hour: dueTime.hour,
            minute: dueTime.minute - 30 < 0
                ? 60 + dueTime.minute - 30
                : dueTime.minute - 30);
        break;
      case '1 hour before':
        time = TimeOfDay(
            hour:
                dueTime.hour - 1 < 0 ? 24 + dueTime.hour - 1 : dueTime.hour - 1,
            minute: dueTime.minute);
        break;
      case '2 hours before':
        time = TimeOfDay(
            hour:
                dueTime.hour - 2 < 0 ? 24 + dueTime.hour - 2 : dueTime.hour - 2,
            minute: dueTime.minute);
        break;
    }
    return time;
  }

  static DateTime? reminderToDate(String reminderType, DateTime dueDate) {
    DateTime? date;
    switch (reminderType) {
      case '1 day before':
        date = dueDate.subtract(const Duration(days: 1));
        break;
      case '2 days before':
        date = dueDate.subtract(const Duration(days: 2));
        break;
      case '1 week before':
        date = dueDate.subtract(const Duration(days: 7));
        break;
      case '2 weeks before':
        date = dueDate.subtract(const Duration(days: 14));
        break;
      case '1 month before':
        date = dueDate.subtract(const Duration(days: 30));
        break;
      case '2 months before':
        date = dueDate.subtract(const Duration(days: 60));
        break;
      case '3 months before':
        date = dueDate.subtract(const Duration(days: 90));
        break;
      case '6 months before':
        date = dueDate.subtract(const Duration(days: 180));
        break;
      case '1 year before':
        date = dueDate.subtract(const Duration(days: 365));
        break;
    }
    return date;
  }

  static String notificationBodyString(DateTime? dueDate, TimeOfDay? dueTime) {
    //if the user selected only due time
    if (dueDate == null && dueTime != null) {
      return dueTime.hour < 10
          ? dueTime.minute < 10
              ? '''Due time: 0${dueTime.hour}:0${dueTime.minute}'''
              : '''Due time: 0${dueTime.hour}:${dueTime.minute}'''
          : dueTime.minute < 10
              ? '''Due time: ${dueTime.hour}:0${dueTime.minute}'''
              : '''Due time: ${dueTime.hour}:${dueTime.minute}''';
    } //of the user selected only due date
    else if (dueDate != null && dueTime == null) {
      return '''Due date:  ${DateFormat('dd/MM/yyyy').format(dueDate)}''';
    } //of the user selected both
    else if (dueDate != null && dueTime != null) {
      return dueTime.hour < 10
          ? dueTime.minute < 10
              ? '''Due date: ${DateFormat('dd/MM/yyyy').format(dueDate)}
              Due time: 0${dueTime.hour}:0${dueTime.minute}'''
              : '''Due date: ${DateFormat('dd/MM/yyyy').format(dueDate)}
              Due time: 0${dueTime.hour}:${dueTime.minute}'''
          : dueTime.minute < 10
              ? '''Due date: ${DateFormat('dd/MM/yyyy').format(dueDate)}
              Due time: ${dueTime.hour}:0${dueTime.minute}'''
              : '''Due date: ${DateFormat('dd/MM/yyyy').format(dueDate)}
              Due time: ${dueTime.hour}:${dueTime.minute}''';
    }
    return '';
  }

  static void sortTaskListByDueTime(List<dynamic> taskList) {
    taskList.sort((task1, task2) {
      int dueTimeInMinutes1 = _getDueTimeInMinutes(task1);
      int dueTimeInMinutes2 = _getDueTimeInMinutes(task2);
      return dueTimeInMinutes1.compareTo(dueTimeInMinutes2);
    });
  }

  static int _getDueTimeInMinutes(Task task) {
    //check if the task has a due time
    String dueTimeString = Utility.timeOfDayToString(task.dueTime);
    if (dueTimeString == '--:--') {
      return 1440; // 24 hours in minutes
    }

    List<String> parts = dueTimeString.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
    return hour * 60 + minute;
  }

  //function that checks already selected users emails from database and returns a list of them
  static Future<List<String>> determineAlreadySharedWithUsers(
      String? taskId) async {
    List<String> alreadySelectedUserEmails = [];
    if (taskId != null) {
      await DBHelper.getSharedWithUsers(taskId).then((userTasks) => {
            for (final user in userTasks)
              {
                alreadySelectedUserEmails.add(user.email!),
              }
          });
    }
    return alreadySelectedUserEmails;
  }

  //auxiliary methods
  static Future<void> removeSharingForTask(String taskId) async {
    //delete the task from the users' shared tasks
    var sharedWithUsers = await Utility.determineAlreadySharedWithUsers(taskId);
    if (sharedWithUsers.isNotEmpty) {
      for (var email in sharedWithUsers) {
        await DBHelper.deleteSharedTaskFromUser(taskId, email);
      }
    }

    //delete the users for the task from the database
    await DBHelper.deleteSharedWithUsers(taskId);
  }

  static DateTime timeOfDayToDateTime(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    return DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
  }

  static badStringFormatToDateTime(String s) {
    List<String> parts = s.split('/');
    int day = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    int year = int.parse(parts[2]);
    return DateTime(year, month, day);
  }

  static badStringFormatToTimeOfDay(String s) {
    List<String> parts = s.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }
}
