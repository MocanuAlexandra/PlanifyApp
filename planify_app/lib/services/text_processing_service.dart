import 'package:flutter/material.dart';
import '../helpers/utility.dart';

import '../models/task.dart';
import '../helpers/app_config.dart' as config;

class TextProcessingService {
  // This method processes the text that is passed to it and returns a Task object
  static Task? processText(String inputText) {
    DateTime? dueDate;
    TimeOfDay? dueTime;

    // define the regex pattern
    // this contain the action that the user wants to perform and the task details
    final regex = RegExp(
        '(${config.ACTION_PATTERN})\\s((?:\\w+\\s*)+${config.TIME_PATTERN})\$');

    // find the match
    final match = regex.firstMatch(inputText);

    if (match != null) {
      final taskDetails = match.group(2)!.split(RegExp(config.SPLIT_PATTERN));

      //get the task title
      final taskTitle = taskDetails[0].trim().capitalize();

      //check if the next string is a date
      if (taskDetails.length > 1) {
        final firstPart = taskDetails[1].trim();

        //check if the date is a valid or time and transform it to a DateTime object or TimeOfDay object
        if (Utility.isStringDate(firstPart)) {
          //if the date is valid, transform it to a DateTime object
          dueDate =
              Utility.transformStringDueDateVoiceInputToDateTime(firstPart);
        }

        // if it is not, check if it is a valid time
        else if (Utility.isStringTime(firstPart)) {
          //if the time is valid, transform it to a TimeOfDay object
          dueTime =
              Utility.transformStringDueTimeVoiceInputToTimeOfDay(firstPart);
        }

        //check if the next string is a time or date and transform it to a TimeOfDay object or DateTime object
        if (taskDetails.length > 2) {
          final secondPart = taskDetails[2].trim();

          //check if the date is a valid date
          if (Utility.isStringDate(secondPart)) {
            //if the date is valid, transform it to a DateTime object
            dueDate =
                Utility.transformStringDueDateVoiceInputToDateTime(secondPart);
          }

          // if it is not, check if it is a valid time
          else if (Utility.isStringTime(secondPart)) {
            //if the time is valid, transform it to a TimeOfDay object
            dueTime =
                Utility.transformStringDueTimeVoiceInputToTimeOfDay(secondPart);
          }
        }
      }

      //return the task object
      return Task(
        title: taskTitle,
        dueDate: dueDate,
        dueTime: dueTime,
      );
    } else {
      return null;
    }
  }
}
