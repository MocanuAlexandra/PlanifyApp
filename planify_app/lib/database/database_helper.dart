import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../helpers/location_helper.dart';
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
        'dueDate': DateTime.parse(task['dueDate']),
        'address': task['address'],
        'latitude': task['latitude'],
        'longitude': task['longitude'],
        'time': task['time'],
        'priority': task['priority'],
        'isDone': task['isDone'],
      };
    }).toList();

    return tasksList;
  }

  // function for adding tasks to the database
  static void addTask(String? taskTitle, DateTime? selectedDate,
      TimeOfDay? selectedTime, TaskAdress? pickedAdress, Priority? priority ) async {
    if (taskTitle == null ||
        selectedDate == null ||
        pickedAdress == null ||
        selectedTime == null ||
        priority == null) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    // get the address of the picked location
    final address = await LocationHelper.getPlaceAddress(
        pickedAdress.latitude!, pickedAdress.longitude!);
    // create a new task adress with the address
    final updatedLocation = TaskAdress(
        latitude: pickedAdress.latitude,
        longitude: pickedAdress.longitude,
        address: address);

    //create a new time with the selected time
    String time = selectedTime.hour < 10
        ? '0${selectedTime.hour}:${selectedTime.minute}'
        : selectedTime.minute < 10
            ? '${selectedTime.hour}:0${selectedTime.minute}'
            : '${selectedTime.hour}:${selectedTime.minute}';

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

  }

    //add the task in the tasks collection of the connected user
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('tasks')
        .add({
      'title': taskTitle,
      'dueDate': selectedDate.toIso8601String(),
      'time': time,
      'latitude': updatedLocation.latitude,
      'longitude': updatedLocation.longitude,
      'address': updatedLocation.address,
      'priority': priorityString,
      'isDone': false,
    });
  }
}
