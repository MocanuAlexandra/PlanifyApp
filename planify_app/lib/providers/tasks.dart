import 'package:flutter/material.dart';
import 'package:planify_app/helpers/utility.dart';
import '../database/database_helper.dart';
import '../models/task.dart';
import '../models/task_adress.dart';

enum FilterOptions {
  All,
  In_progress,
  Done,
  Deleted,
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
          dueDate: Utility.stringToDateTime(task['dueDate']),
          address: TaskAdress(
            latitude: task['latitude'],
            longitude: task['longitude'],
            address: task['address'],
          ),
          time: task['time'],
          priority: task['priority'],
          isDone: task['isDone'],
          isDeleted: task['isDeleted'],
        );
      },
    ).toList();

    //check if the user wants to fetch today agenda
    if (today != null) {
      _tasks = _tasks
          .where((task) =>
              task.dueDate != null && task.dueDate!.day == DateTime.now().day)
          .toList();
      //check if the user wants to fetch a certain month agenda
    } else if (month != null) {
      //check if task has a due date

      _tasks = _tasks
          .where((task) =>
              task.dueDate != null &&
              task.dueDate!.month == selectedDate!.month &&
              task.dueDate!.year == selectedDate.year)
          .toList();
    }

    //check for filters
    switch (selectedOption) {
      case FilterOptions.All:
        _tasks = _tasks
            .where((task) =>
                (task.isDone == false || task.isDone == true) &&
                task.isDeleted == false)
            .toList();
        break;
      case FilterOptions.In_progress:
        _tasks = _tasks
            .where((task) => task.isDone == false && task.isDeleted == false)
            .toList();
        break;
      case FilterOptions.Done:
        _tasks = _tasks
            .where((task) => task.isDone == true && task.isDeleted == false)
            .toList();
        break;
      case FilterOptions.Deleted:
        _tasks = _tasks.where((task) => task.isDeleted == true).toList();
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
