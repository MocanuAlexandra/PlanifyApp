import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:planify_app/models/location_category.dart';

import '../helpers/location_helper.dart';
import '../helpers/utility.dart';
import '../models/task_reminder.dart';
import '../models/task.dart';
import '../models/task_address.dart';

class DBHelper {
  // function for fetching categories from the database from the connected user
  static Future<List<Map<String, dynamic>>> fetchCategories() async {
    final user = FirebaseAuth.instance.currentUser;

    //get the categories from the connected user
    final categories = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('categories')
        .get();

    //check if there is no categories
    if (categories.docs.isEmpty) {
      return [];
    }

    //convert the categories to a list of maps
    final categoriesList = categories.docs.map((category) {
      return {
        'id': category.id,
        'name': category['name'],
      };
    }).toList();

    return categoriesList;
  }

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
        'isDeleted': task['isDeleted'],
        'category': task['category'],
        'locationCategory': task['locationCategory'],
      };
    }).toList();

    return tasksList;
  }

  static Future<List<Map<String, dynamic>>> fetchReminders(
      String taskId) async {
    final user = FirebaseAuth.instance.currentUser;

    //get the categories from the connected user
    final reminders = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('tasks')
        .doc(taskId)
        .collection('reminders')
        .get();

    //check if there is no categories
    if (reminders.docs.isEmpty) {
      return [];
    }

    //convert the categories to a list of maps
    final remindersList = reminders.docs.map((reminder) {
      return {
        'id': reminder.id,
        'contentId': reminder['contentId'],
        'reminder': reminder['reminder'],
      };
    }).toList();

    return remindersList;
  }

  // function for adding tasks to the database
  static Future<String> addTask(Task newTask) async {
    if (newTask.title == null) {
      return '';
    }

    //get the connected user
    final user = FirebaseAuth.instance.currentUser;

    var updatedLocation = const TaskAddress(
        latitude: 0, longitude: 0, address: 'No address chosen');
    //check if the user picked an address
    if (newTask.address != null) {
      // get the address of the picked location
      final address = await LocationHelper.getPlaceAddress(
          newTask.address!.latitude!, newTask.address!.longitude!);
      // create a new task address with the address
      updatedLocation = TaskAddress(
          latitude: newTask.address!.latitude,
          longitude: newTask.address!.longitude,
          address: address);
    }

    //check if the user picked a due date
    String updatedDueDate = '--/--/----';
    if (newTask.dueDate != null) {
      updatedDueDate = newTask.dueDate!.toIso8601String();
    }

    //check if user picked a category
    String updatedCategory = 'No category';
    if (newTask.category != null) {
      updatedCategory = newTask.category!;
    }

    //check fi user selected a location category
    String updatedLocationCategory = 'No location category chosen';
    if (newTask.locationCategory != null) {
      updatedLocationCategory = newTask.locationCategory!;
    }

    //add the task in the tasks collection of the connected user
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('tasks')
        .add({
      'title': newTask.title,
      'dueDate': updatedDueDate,
      'time': Utility.timeOfDayToString(newTask.time),
      'latitude': updatedLocation.latitude,
      'longitude': updatedLocation.longitude,
      'address': updatedLocation.address,
      'priority': Utility.priorityEnumToString(newTask.priority),
      'isDone': false,
      'isDeleted': false,
      'category': updatedCategory,
      'locationCategory': updatedLocationCategory,
    });

    return doc.id;
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
  static Future<void> updateTask(String editedTaskId, Task editedTask) async {
    final user = FirebaseAuth.instance.currentUser;

    var updatedLocation = const TaskAddress(
        latitude: 0.0, longitude: 0.0, address: 'No address chosen');
    //check if the user picked an address
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
      // create a new task address with the address
      updatedLocation = TaskAddress(
          latitude: editedTask.address!.latitude,
          longitude: editedTask.address!.longitude,
          address: address);
    }

    String updatedDueDate = '--/--/----';
    if (editedTask.dueDate != null) {
      updatedDueDate = editedTask.dueDate!.toIso8601String();
    }

    String updatedLocationCategory = 'No location category chosen';
    if (editedTask.locationCategory != null) {
      updatedLocationCategory = editedTask.locationCategory!;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('tasks')
        .doc(editedTaskId)
        .update({
      'title': editedTask.title,
      'dueDate': updatedDueDate,
      'time': Utility.timeOfDayToString(editedTask.time),
      'latitude': updatedLocation.latitude,
      'longitude': updatedLocation.longitude,
      'address': updatedLocation.address,
      'priority': Utility.priorityEnumToString(editedTask.priority),
      'isDone': editedTask.isDone,
      'isDeleted': editedTask.isDeleted,
      'category': editedTask.category,
      'locationCategory': updatedLocationCategory,
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

  // function for marking a task as deleted
  static void markTaskAsDeleted(String id) {
    final user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('tasks')
        .doc(id)
        .update({'isDeleted': true});
  }

  // function for marking a task as undeleted
  static void markTaskAsUndeleted(String id) {
    final user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('tasks')
        .doc(id)
        .update({'isDeleted': false});
  }

  static void updateCategory(String id, LocationCategory editedCategory) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('categories')
        .doc(id)
        .update({'name': editedCategory.name});
  }

  static void addCategory(LocationCategory editedCategory) async {
    if (editedCategory.name == null) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('categories')
        .add({
      'name': editedCategory.name,
    });
  }

  static void deleteCategory(String categoryId) {
    final user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('categories')
        .doc(categoryId)
        .delete();
  }

  //check if the category is used in any task
  static Future<bool> isCategoryUsed(String categoryId) async {
    final user = FirebaseAuth.instance.currentUser;
    final category = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('categories')
        .doc(categoryId)
        .get();
    final tasks = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .where('category', isEqualTo: category['name'])
        .get();
    return tasks.docs.isNotEmpty;
  }

  //function that adds a new notification for a certain task
  static Future<void> addReminder(String taskId, TaskReminder reminder) async {
    final user = FirebaseAuth.instance.currentUser;
    //add the notification to the database
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('tasks')
        .doc(taskId)
        .collection('reminders')
        .add({
      'contentId': reminder.contentId,
      'reminder': reminder.reminder,
    });
  }

  static Future<void> deleteNotificationsForTask(String taskId) async {
    final user = FirebaseAuth.instance.currentUser;
    final reminders = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('tasks')
        .doc(taskId)
        .collection('reminders')
        .get();
    if (reminders.docs.isNotEmpty) {
      for (var reminder in reminders.docs) {
        reminder.reference.delete();
      }
    }
  }
}
