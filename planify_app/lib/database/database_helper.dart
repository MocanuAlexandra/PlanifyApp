import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
  static void addTask(
      String? taskTitle,
      DateTime? selectedDate,
      TimeOfDay? selectedTime,
      TaskAdress? pickedAdress,
      Priority? priority) async {
    if (taskTitle == null || selectedDate == null) {
      return;
    }

    //get the connected user
    final user = FirebaseAuth.instance.currentUser;

    var updatedLocation = const TaskAdress(
        latitude: 0, longitude: 0, address: 'No address chosen');
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

    //add the task in the tasks collection of the connected user
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('tasks')
        .add({
      'title': taskTitle,
      'dueDate': selectedDate.toIso8601String(),
      'time': Utility.timeOfDayToString(selectedTime),
      'latitude': updatedLocation.latitude,
      'longitude': updatedLocation.longitude,
      'address': updatedLocation.address,
      'priority': Utility.priorityEnumToString(priority),
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

  static void updateTask(String s, String? taskTitle, DateTime selectedDate,
      TimeOfDay? selectedTime, TaskAdress? pickedAdress, Priority? priority) {
    final user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('tasks')
        .doc(s)
        .update({
      'title': taskTitle,
      'dueDate': selectedDate.toIso8601String(),
      'time':Utility.timeOfDayToString(selectedTime),
      'latitude': pickedAdress!.latitude,
      'longitude': pickedAdress.longitude,
      'address': pickedAdress.address,
      'priority': Utility.priorityEnumToString(priority),
    });
  }
}
