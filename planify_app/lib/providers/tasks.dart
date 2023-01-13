import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../helpers/location_helper.dart';
import '../models/task.dart';
import '../models/task_adress.dart';

class Tasks with ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasksList {
    return [..._tasks];
  }

  Future<void> fetchAndSetTasks() async {
    final tasksData = await DBHelper.fetchTasks();

    _tasks = tasksData.map(
      (task) {
        return Task(
          id: task['id'],
          title: task['title'],
          dueDate: task['dueDate'],
          address: TaskAdress(
            latitude: task['latitude'],
            longitude: task['longitude'],
            address: task['address'],
          ),
          time: task['time'],
          priority: task['priority'],
        );
      },
    ).toList();
    notifyListeners();
  }

  void addTask(
      String? taskTitle,
      DateTime? selectedDate,
      TimeOfDay? selectedTime,
      TaskAdress? pickedAdress,
      Priority? priority) async {
    final address = await LocationHelper.getPlaceAddress(
        pickedAdress!.latitude!, pickedAdress.longitude!);

    final updatedAdress = TaskAdress(
        latitude: pickedAdress.latitude,
        longitude: pickedAdress.longitude,
        address: address);

    String time = selectedTime!.hour < 10
        ? '0${selectedTime.hour}:${selectedTime.minute}'
        : selectedTime.minute < 10
            ? '${selectedTime.hour}:0${selectedTime.minute}'
            : '${selectedTime.hour}:${selectedTime.minute}';

    // transform the priority to a string
    String priorityString = '';
    switch (priority!) {
      case Priority.casual:
        priorityString = 'Casual';
        break;
      case Priority.necessary:
        priorityString = 'Necessary';
        break;
      case Priority.important:
        priorityString = 'Important';
        break;
    }

    final newTask = Task(
      title: taskTitle,
      dueDate: selectedDate,
      address: updatedAdress,
      time: time,
      priority: priorityString,
      isDone: false,
    );

    _tasks.add(newTask);
    notifyListeners();
  }
}
