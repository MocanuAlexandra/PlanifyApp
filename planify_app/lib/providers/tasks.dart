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

  Future<void> fetchAndSetAllTasks() async {
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
          isDone: task['isDone'],
        );
      },
    ).toList();
    notifyListeners();
  }

  Future<void> fetchAndSetTasksInProgress() async {
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
          isDone: task['isDone'],
        );
      },
    ).toList();

    //filter just task that are not done
    _tasks = _tasks.where((task) => task.isDone == false).toList();
    notifyListeners();
  }

  void addTask(
      String? taskTitle,
      DateTime? selectedDate,
      TimeOfDay? selectedTime,
      TaskAdress? pickedAdress,
      Priority? priority) async {
        
    var updatedLocation =
        const TaskAdress(latitude: 0, longitude: 0, address: 'No address');
    //check if the user picked an adress
    if (pickedAdress != null) {
      // get the address of the picked location
      final address = await LocationHelper.getPlaceAddress(
          pickedAdress.latitude!, pickedAdress.longitude!);
      // create a new task adress with the address
      updatedLocation = TaskAdress(
          latitude: pickedAdress.latitude,
          longitude: pickedAdress.longitude,
          address: address);
    }

    String time = '--:--';
    if (selectedTime != null) {
      time = selectedTime.hour < 10
          ? '0${selectedTime.hour}:${selectedTime.minute}'
          : selectedTime.minute < 10
              ? '${selectedTime.hour}:0${selectedTime.minute}'
              : '${selectedTime.hour}:${selectedTime.minute}';
    }

    // transform the priority to a string
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

    final newTask = Task(
      title: taskTitle,
      dueDate: selectedDate,
      address: updatedLocation,
      time: time,
      priority: priorityString,
      isDone: false,
    );

    _tasks.add(newTask);
    notifyListeners();
  }
}
