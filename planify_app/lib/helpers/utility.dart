import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';

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

  static Future<bool?> displayAlertDialog(BuildContext context, String text) {
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
              content: Text(text),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Ok')),
              ],
            ));
  }

  static TimeOfDay tenMinutesBefore(TimeOfDay originalTime) {
    int hour = originalTime.hour;
    int minute = originalTime.minute - 10;

    if (minute < 0) {
      hour--;
      minute += 60;
    }

    if (hour < 0) {
      hour += 24;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }
}
