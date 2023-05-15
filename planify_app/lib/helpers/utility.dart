import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';
import '../helpers/app_config.dart' as config;
import '../services/database_helper_service.dart';

// Utility class used to store static methods that are used in multiple classes
class Utility {
  //***************** String manipulation ********************
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

  static String dateTimeToString(DateTime? dueDate) {
    String date = '--/--/----';
    if (dueDate != null) {
      date = DateFormat('dd/MM/yyyy').format(dueDate);
    }
    return date;
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

  static DateTime badStringFormatToDateTime(String s) {
    List<String> parts = s.split('/');
    int day = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    int year = int.parse(parts[2]);
    return DateTime(year, month, day);
  }

  static TimeOfDay badStringFormatToTimeOfDay(String s) {
    List<String> parts = s.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

  static DateTime? transformStringDueDateVoiceInputToDateTime(String dueDate) {
    //split by space to get the month, day and eventually year
    List<String> parts = dueDate.split(' ');

    //check if the date has a year
    if (parts.length == 3) {
      //get the month
      String month = parts[0];
      //get the day
      String day = parts[1];
      //get the year
      String year = parts[2];

      //get the month number
      int monthNumber = _getMonthNumber(month);
      //add a 0 to the month if it is less than 10
      if (monthNumber < 10) {
        month = '0$monthNumber';
      } else {
        month = '$monthNumber';
      }

      //remove the st, nd, rd, th from the day
      day = day.substring(0, day.length - 2);

      //check for the date validity
      if (_isValidDate(monthNumber, int.parse(day)) == false) {
        //if the date is not valid, return null
        return null;
      }

      //add a 0 to the day if it is less than 10
      if (int.parse(day) < 10) {
        day = '0$day';
      }

      //date in the format dd/mm/yyyy
      String stringDate = '$day/$month/$year';

      //transform the string to a date
      DateTime date = badStringFormatToDateTime(stringDate);
      return date;
    } else {
      //get the month
      String month = parts[0];
      //get the day
      String day = parts[1];

      //get the month number
      int monthNumber = _getMonthNumber(month);
      //add a 0 to the month if it is less than 10
      if (monthNumber < 10) {
        month = '0$monthNumber';
      } else {
        month = '$monthNumber';
      }

      //check if the day has a st, nd, rd, th
      if (day.contains('st') ||
          day.contains('nd') ||
          day.contains('rd') ||
          day.contains('th')) {
        //remove the st, nd, rd, th from the day
        day = day.substring(0, day.length - 2);
      }

      //check for the date validity
      if (_isValidDate(monthNumber, int.parse(day)) == false) {
        //if the date is not valid, return null
        return null;
      }

      //add a 0 to the day if it is less than 10
      if (int.parse(day) < 10) {
        day = '0$day';
      }

      // date in the format dd/mm/yyyy
      // put the current year
      String year = DateTime.now().year.toString();
      String stringDate = '$day/$month/$year';

      //transform the string to a date
      DateTime date = badStringFormatToDateTime(stringDate);
      return date;
    }
  }

  static TimeOfDay transformStringDueTimeVoiceInputToTimeOfDay(String time) {
    TimeOfDay timeOfDay = TimeOfDay.now();
    bool isPm = false;

    //if the time contains  or P.M. p.m. or PM or pm
    //add a flag to know that it is a PM time
    if (time.contains('P.M.') ||
        time.contains('p.m.') ||
        time.contains('PM') ||
        time.contains('pm')) {
      isPm = true;
    }

    //then remove the P.M. p.m. PM pm or A.M. a.m. AM am from the time
    time = time.replaceAll('P.M.', '');
    time = time.replaceAll('p.m.', '');
    time = time.replaceAll('PM', '');
    time = time.replaceAll('pm', '');
    time = time.replaceAll('A.M.', '');
    time = time.replaceAll('a.m.', '');
    time = time.replaceAll('AM', '');
    time = time.replaceAll('am', '');

    //split by space to get the hour and eventually minutes
    List<String> parts = time.split(':');

    //check if the time has minutes
    if (parts.length == 2) {
      //get the hour
      String hour = parts[0];
      //get the minutes
      String minutes = parts[1];

      //check if the hour is less than 10
      if (int.parse(hour) < 10) {
        //add a 0 to the hour
        hour = '0$hour';
      }

      //check if the minutes is less than 10
      if (int.parse(minutes) < 10) {
        //add a 0 to the minutes
        minutes = '0$minutes';
      }

      //check if the time is PM
      if (isPm == true && int.parse(hour) != 12) {
        //add 12 to the hour
        hour = (int.parse(hour) + 12).toString();
      }

      //time in the format hh:mm
      String stringTime = '$hour:$minutes';

      //transform the string to a time
      timeOfDay = badStringFormatToTimeOfDay(stringTime);
    }

    //check if the time has no minutes
    if (parts.length == 1) {
      //get the hour
      String hour = parts[0];

      //check if the hour is less than 10
      if (int.parse(hour) < 10) {
        //add a 0 to the hour
        hour = '0$hour';
      }

      //check if the time is PM
      if (isPm == true && int.parse(hour) != 12) {
        //add 12 to the hour
        hour = (int.parse(hour) + 12).toString();
      }

      //time in the format hh:mm
      String stringTime = '$hour:00';

      //transform the string to a time
      timeOfDay = badStringFormatToTimeOfDay(stringTime);
    }

    return timeOfDay;
  }

///////////////////////////////////////////////////////////////////
//******************** Dialogs ********************
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

///////////////////////////////////////////////////////
  ///******************** Reminders ********************
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
////////////////////////////////////////////////////////////////////////////////////

  //**************** Auxiliary methods for tasks ****************

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

  static Future<bool> existsTaskWithLocationCategpoySelected() async {
    bool existTasksWithLocationCategprySelected = false;
    final tasks = await DBHelper.getListOfTasks();

    for (final task in tasks) {
      if (task.locationCategory != 'No location category chosen') {
        existTasksWithLocationCategprySelected = true;
        break;
      }
    }
    return existTasksWithLocationCategprySelected;
  }

  ///////////////////////////////////////////////////////////////
  //**************** Auxiliary methods for date/time ****************

  static bool isPastDue(DateTime dueDate, TimeOfDay dueTime) {
    final now = DateTime.now();
    final dueDateTime = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
      dueTime.hour,
      dueTime.minute,
    );
    return now.isAfter(dueDateTime);
  }

  static bool _isValidDate(int month, int day) {
    if (day < 1) {
      return false;
    }

    final daysInMonth = DateTime(DateTime.now().year, month, 0).day;

    if (day > daysInMonth) {
      return false;
    }

    return true;
  }

  static int _getMonthNumber(String month) {
    switch (month) {
      case 'January':
        return 01;
      case 'February':
        return 02;
      case 'March':
        return 03;
      case 'April':
        return 04;
      case 'May':
        return 05;
      case 'June':
        return 06;
      case 'July':
        return 07;
      case 'August':
        return 08;
      case 'September':
        return 09;
      case 'October':
        return 10;
      case 'November':
        return 11;
      case 'December':
        return 12;
      case 'january':
        return 01;
      case 'february':
        return 02;
      case 'march':
        return 03;
      case 'april':
        return 04;
      case 'may':
        return 05;
      case 'june':
        return 06;
      case 'july':
        return 07;
      case 'august':
        return 08;
      case 'september':
        return 09;
      case 'october':
        return 10;
      case 'november':
        return 11;
      case 'december':
        return 12;
      default:
        return 0;
    }
  }

  static bool isStringDate(String date) {
    final regexPattern = RegExp('(${config.DATE_PATTERN})');

    return regexPattern.hasMatch(date);
  }

  static bool isStringTime(String time) {
    final regexPattern = RegExp('(${config.TIME_PATTERN})');

    return regexPattern.hasMatch(time);
  }

  //////////////////////////////////////////////////////////////
  //**************** Constants ****************
  static final List<IconData> iconList = [
    Icons.category,
    Icons.home,
    Icons.settings,
    Icons.star,
    Icons.favorite,
    Icons.shopping_cart,
    Icons.work,
    Icons.school,
    Icons.directions_car,
    Icons.local_airport,
    Icons.beach_access,
    Icons.book,
    Icons.camera_alt,
    Icons.fastfood,
    Icons.local_laundry_service,
    Icons.local_post_office,
    Icons.music_note,
    Icons.movie,
    Icons.spa,
    Icons.pets,
    Icons.snowboarding,
    Icons.fitness_center,
    Icons.local_play,
    Icons.ac_unit,
    Icons.weekend,
    Icons.local_mall,
    Icons.sports_tennis,
    Icons.theater_comedy,
    Icons.local_florist,
    Icons.local_bar,
  ];

  static final List<String> locationCategories = [
    "accounting",
    "airport",
    "amusement_park",
    "aquarium",
    "art_gallery",
    "atm",
    "bakery",
    "bank",
    "bar",
    "beauty_salon",
    "book_store",
    "cafe",
    "car_repair",
    "car_wash",
    "church",
    "city_hall",
    "clothing_store",
    "dentist",
    "doctor",
    "electrician",
    "electronics_store",
    "fire_station",
    "florist",
    "food",
    "furniture_store",
    "gas_station",
    "gym",
    "hair_care",
    "hardware_store",
    "hospital",
    "jewelry_store",
    "laundry",
    "library",
    "liquor_store",
    "meal_delivery",
    "meal_takeaway",
    "movie_theater",
    "museum",
    "park",
    "parking",
    "pet_store",
    "pharmacy",
    "physiotherapist",
    "plumber",
    "police",
    "post_office",
    "restaurant",
    "school",
    "shoe_store",
    "shopping_mall",
    "spa",
    "store",
    "subway_station",
    "supermarket",
    "taxi_stand",
    "train_station",
    "travel_agency",
    "university",
    "veterinary_care",
    "zoo"
  ];

  ////////////////////////////////////////////////////////////////////
}
