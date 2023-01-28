import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/task.dart';
import '../models/task_adress.dart';

enum FilterOptions {
  All,
  In_progress,
  Done,
}

class Tasks with ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasksList {
    return [..._tasks];
  }

  Future<void> fetchTasks(
      [bool? today,
      bool? month,
      DateTime? selectedDate,
      FilterOptions? selectedOption]) async {
    final tasksData = await DBHelper.fetchTasks();

    _tasks = tasksData.map(
      (task) {
        return Task(
          id: task['id'],
          title: task['title'],
          dueDate: DateTime.parse(task['dueDate']),
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

    //check if the user wants to fetch today agenda
    if (today != null) {
      _tasks = _tasks
          .where((task) => task.dueDate!.day == DateTime.now().day)
          .toList();
      //check if the user wants to fetch a certain month agenda
    } else if (month != null) {
      _tasks = _tasks
          .where((task) =>
              task.dueDate!.month == selectedDate!.month &&
              task.dueDate!.year == selectedDate.year)
          .toList();
    }

    //check for filters
    switch (selectedOption) {
      case FilterOptions.All:
        _tasks = _tasks
            .where((task) => task.isDone == false || task.isDone == true)
            .toList();
        break;
      case FilterOptions.In_progress:
        _tasks = _tasks.where((task) => task.isDone == false).toList();
        break;
      case FilterOptions.Done:
        _tasks = _tasks.where((task) => task.isDone == true).toList();
        break;
      default:
        _tasks = _tasks
            .where((task) => task.isDone == false || task.isDone == true)
            .toList();
        break;
    }

    //in the end notify listeners in order to update the UI
    notifyListeners();
  }

  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }

  Task findById(String id) {
    return _tasks.firstWhere((task) => task.id == id);
  }
}
