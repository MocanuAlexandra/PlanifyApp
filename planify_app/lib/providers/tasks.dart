import 'package:flutter/cupertino.dart';

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
        );
      },
    ).toList();
    notifyListeners();
  }

  void addTask(String? taskTitle, DateTime? selectedDate,
      TaskAdress? pickedAdress) async {
    final address = await LocationHelper.getPlaceAddress(
        pickedAdress!.latitude!, pickedAdress.longitude!);

    final updatedAdress = TaskAdress(
        latitude: pickedAdress.latitude,
        longitude: pickedAdress.longitude,
        address: address);

    final newTask = Task(
      title: taskTitle,
      dueDate: selectedDate,
      address: updatedAdress,
    );

    _tasks.add(newTask);
    notifyListeners();
  }
}
