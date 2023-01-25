import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/task.dart';
import '../models/task_adress.dart';

class Tasks with ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasksList {
    return [..._tasks];
  }

  Future<void> fetchAndSetOverAllAllTasks() async {
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
    notifyListeners();
  }

  Future<void> fetchAndSetOverAllInProgressTasks() async {
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

    //filter just task that are not done
    _tasks = _tasks.where((task) => task.isDone == false).toList();
    notifyListeners();
  }

  Future<void> fetchAndSetOverAllDoneTasks() async {
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

    //filter just task that are not done
    _tasks = _tasks.where((task) => task.isDone == true).toList();
    notifyListeners();
  }

  Future<void> fetchAndSetAllTasksDueToday() async {
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

    //filter task that are due today
    _tasks = _tasks
        .where((task) => task.dueDate!.day == DateTime.now().day)
        .toList();
    notifyListeners();
  }

  Future<void> fetchAndSetInProgressTasksDueToday() async {
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

    //filter task that are due today
    _tasks = _tasks
        .where((task) =>
            task.isDone == false && task.dueDate!.day == DateTime.now().day)
        .toList();
    notifyListeners();
  }

  Future<void> fetchAndSetDoneTasksDueToday() async {
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

    //filter task that are due today
    _tasks = _tasks
        .where((task) =>
            task.isDone == true && task.dueDate!.day == DateTime.now().day)
        .toList();
    notifyListeners();
  }

  Future<void> fetchAndSetAllTasksDueMonth(DateTime selectedDate) async {
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

    //filter task that are due the selected month
    _tasks = _tasks
        .where((task) =>
            task.dueDate!.month == selectedDate.month &&
            task.dueDate!.year == selectedDate.year)
        .toList();
    notifyListeners();
  }

  Future<void> fetchAndSetInProgressTasksDueMonth(DateTime selectedDate) async {
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

    //filter task that are due the selected month
    _tasks = _tasks
        .where((task) =>
            task.isDone == false &&
            task.dueDate!.month == selectedDate.month &&
            task.dueDate!.year == selectedDate.year)
        .toList();
    notifyListeners();
  }

  Future<void> fetchAndSetDoneTasksDueMonth(DateTime selectedDate) async {
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

    //filter task that are due the selected month
    _tasks = _tasks
        .where((task) =>
            task.isDone == true &&
            task.dueDate!.month == selectedDate.month &&
            task.dueDate!.year == selectedDate.year)
        .toList();
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
