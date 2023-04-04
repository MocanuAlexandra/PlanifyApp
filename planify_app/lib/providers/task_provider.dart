import 'package:flutter/material.dart';

import '../services/database_helper_service.dart';
import '../helpers/utility.dart';
import '../models/task.dart';
import '../models/task_address.dart';

enum FilterOptions {
  all,
  inProgress,
  done,
  deleted,
  focusMode,
}

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasksList {
    return [..._tasks];
  }

  Future<void> fetchTasks(
      [bool? today,
      bool? month,
      DateTime? selectedDate,
      FilterOptions? selectedOption,
      String? category]) async {
    final tasksData = await DBHelper.fetchTasks();

    _tasks = tasksData.map(
      (task) {
        return Task(
          id: task['id'],
          title: task['title'],
          dueDate: Utility.stringToDateTime(task['dueDate']),
          address: TaskAddress(
            latitude: task['latitude'],
            longitude: task['longitude'],
            address: task['address'],
          ),
          dueTime: task['time'],
          priority: task['priority'],
          isDone: task['isDone'],
          isDeleted: task['isDeleted'],
          category: task['category'],
          locationCategory: task['locationCategory'],
          owner: task['owner'],
          imageUrl: task['imageUrl'],
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
      _tasks = _tasks
          .where((task) =>
              task.dueDate != null &&
              task.dueDate!.month == selectedDate!.month &&
              task.dueDate!.year == selectedDate.year)
          .toList();
    }

    //check if the user selected a category
    if (category != null) {
      _tasks = _tasks.where((task) => task.category == category).toList();
    }

    //check for filters
    switch (selectedOption) {
      case FilterOptions.all:
        {
          _tasks = _tasks
              .where((task) =>
                  (task.isDone == false || task.isDone == true) &&
                  task.isDeleted == false)
              .toList();
        }
        break;
      case FilterOptions.inProgress:
        {
          _tasks = _tasks
              .where((task) => task.isDone == false && task.isDeleted == false)
              .toList();
        }
        break;
      case FilterOptions.done:
        {
          _tasks = _tasks
              .where((task) => task.isDone == true && task.isDeleted == false)
              .toList();
        }
        break;
      case FilterOptions.deleted:
        _tasks = _tasks.where((task) => task.isDeleted == true).toList();
        break;
      case FilterOptions.focusMode:
        _tasks = _tasks
            .where((task) =>
                task.isDone == false &&
                task.isDeleted == false &&
                task.priority == Priority.important)
            .toList();
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

  Future<void> fetchSharedTasks(
      [bool? today,
      bool? month,
      DateTime? selectedDate,
      FilterOptions? selectedOption,
      String? category]) async {
    final tasksData = await DBHelper.fetchSharedTasks();

    _tasks = tasksData;

    //check if the user wants to fetch today agenda
    if (today != null) {
      _tasks = _tasks
          .where((task) =>
              task.dueDate != null && task.dueDate!.day == DateTime.now().day)
          .toList();
      //check if the user wants to fetch a certain month agenda
    } else if (month != null) {
      _tasks = _tasks
          .where((task) =>
              task.dueDate != null &&
              task.dueDate!.month == selectedDate!.month &&
              task.dueDate!.year == selectedDate.year)
          .toList();
    }

    //check if the user selected a category
    if (category != null) {
      _tasks = _tasks.where((task) => task.category == category).toList();
    }

    //check for filters
    switch (selectedOption) {
      case FilterOptions.all:
        {
          _tasks = _tasks
              .where((task) =>
                  (task.isDone == false || task.isDone == true) &&
                  task.isDeleted == false)
              .toList();
        }
        break;
      case FilterOptions.inProgress:
        {
          _tasks = _tasks
              .where((task) => task.isDone == false && task.isDeleted == false)
              .toList();
        }
        break;
      case FilterOptions.done:
        {
          _tasks = _tasks
              .where((task) => task.isDone == true && task.isDeleted == false)
              .toList();
        }
        break;
      case FilterOptions.deleted:
        _tasks = _tasks.where((task) => task.isDeleted == true).toList();
        break;
      case FilterOptions.focusMode:
        _tasks = _tasks
            .where((task) =>
                task.isDone == false &&
                task.isDeleted == false &&
                task.priority == Priority.important)
            .toList();
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

  void deleteAllTasks() {
    _tasks.clear();
    notifyListeners();
  }

  Task findById(String id) {
    return _tasks.firstWhere((task) => task.id == id);
  }
}
