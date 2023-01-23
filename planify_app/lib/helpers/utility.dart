import 'package:flutter/material.dart';

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
}
