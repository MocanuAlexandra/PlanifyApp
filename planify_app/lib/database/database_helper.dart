import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../helpers/location_helper.dart';
import '../helpers/utility.dart';
import '../models/task.dart';
import '../models/task_adress.dart';

class DBHelper {
  // function for fetching tasks from the database from the connected user
  static Future<List<Map<String, dynamic>>> fetchTasks() async {
    final user = FirebaseAuth.instance.currentUser;

    //get the tasks from the connected user
    final tasks = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('tasks')
        .get();

    //check if there is no tasks
    if (tasks.docs.isEmpty) {
      return [];
    }

    //convert the tasks to a list of maps
    final tasksList = tasks.docs.map((task) {
      return {
        'id': task.id,
        'title': task['title'],
        'dueDate': task['dueDate'],
        'address': task['address'],
        'latitude': task['latitude'],
        'longitude': task['longitude'],
        'time': Utility.stringToTimeOfDay(task['time']),
        'priority': Utility.stringToPriorityEnum(task['priority']),
        'isDone': task['isDone'],
      };
    }).toList();

    return tasksList;
  }

  // function for adding tasks to the database
  static void addTask(Task newTask) async {
    if (newTask.title == null || newTask.dueDate == null) {
      return;
    }

    //get the connected user
    final user = FirebaseAuth.instance.currentUser;

    var updatedLocation = const TaskAdress(
        latitude: 0, longitude: 0, address: 'No address chosen');
    //check if the user picked an adress
    if (newTask.address != null) {
      // get the address of the picked location
      final address = await LocationHelper.getPlaceAddress(
          newTask.address!.latitude!, newTask.address!.longitude!);
      // create a new task adress with the address
      updatedLocation = TaskAdress(
          latitude: newTask.address!.latitude,
          longitude: newTask.address!.longitude,
          address: address);
    }

    //add the task in the tasks collection of the connected user
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('tasks')
        .add({
      'title': newTask.title,
      'dueDate': newTask.dueDate!.toIso8601String(),
      'time': Utility.timeOfDayToString(newTask.time),
      'latitude': updatedLocation.latitude,
      'longitude': updatedLocation.longitude,
      'address': updatedLocation.address,
      'priority': Utility.priorityEnumToString(newTask.priority),
      'isDone': false,
    });
  }

  // function for deleting tasks in the database
  static void deleteTask(String id) {
    final user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('tasks')
        .doc(id)
        .delete();
  }

  // function for updating tasks in the database
  static void updateTask(String editedTaskId, Task editedTask) async {
    final user = FirebaseAuth.instance.currentUser;

    var updatedLocation = const TaskAdress(
        latitude: 0.0, longitude: 0.0, address: 'No address chosen');
    //check if the user picked an adress
    if ((editedTask.address != null &&
                editedTask.address!.latitude != null &&
                editedTask.address!.longitude !=
                    null) // if the user picked an address, so the values are not default ones
            &&
            (editedTask.address!.latitude != 0.0 &&
                editedTask.address!.longitude != 0.0 &&
                editedTask.address!.address !=
                    'No address chosen') // if the user previously deleted the address, so the task has default address
        ) {
      // get the address of the picked location
      final address = await LocationHelper.getPlaceAddress(
          editedTask.address!.latitude!, editedTask.address!.longitude!);
      // create a new task adress with the address
      updatedLocation = TaskAdress(
          latitude: editedTask.address!.latitude,
          longitude: editedTask.address!.longitude,
          address: address);
    }

    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('tasks')
        .doc(editedTaskId)
        .update({
      'title': editedTask.title,
      'dueDate': editedTask.dueDate!.toIso8601String(),
      'time': Utility.timeOfDayToString(editedTask.time),
      'latitude': updatedLocation.latitude,
      'longitude': updatedLocation.longitude,
      'address': updatedLocation.address,
      'priority': Utility.priorityEnumToString(editedTask.priority),
      'isDone': editedTask.isDone,
    });
  }

  // function for marking a task as done in the database
  static void markTaskAsDone(String id) {
    final user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('tasks')
        .doc(id)
        .update({'isDone': true});
  }
}
