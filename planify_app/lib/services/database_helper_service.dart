import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../models/task.dart' as task_model;
import '../models/task_address.dart';
import '../models/task_category.dart';
import '../models/task_reminder.dart';
import '../models/user.dart';
import 'location_helper_service.dart';
import '../helpers/utility.dart';

class DBHelper {
  // ********** FETCHING FUNCTIONS **********
  // function for fetching categories from the database from the connected user
  static Future<List<Map<String, dynamic>>> fetchTaskCategories() async {
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
        'iconCode': category['iconCode'],
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
        'owner': task['owner'],
        'imageUrl': task['imageUrl'],
      };
    }).toList();

    return tasksList;
  }

  // function that return a task after getting its id
  static Future<task_model.Task> getTaskById(String taskId) async {
    final user = FirebaseAuth.instance.currentUser;

    //get the task from the connected user
    final task = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('tasks')
        .doc(taskId)
        .get();

    return task_model.Task(
      id: task.id,
      title: task['title'],
      dueDate: Utility.stringToDateTime(task['dueDate']),
      address: TaskAddress(
        latitude: task['latitude'],
        longitude: task['longitude'],
        address: task['address'],
      ),
      dueTime: Utility.stringToTimeOfDay(task['time']),
      priority: Utility.stringToPriorityEnum(task['priority']),
      isDone: task['isDone'],
      isDeleted: task['isDeleted'],
      category: task['category'],
      locationCategory: task['locationCategory'],
      owner: task['owner'],
      imageUrl: task['imageUrl'],
    );
  }

  //function for fetching the task as list
  static Future<List<task_model.Task>> getListOfTasks() async {
    final user = FirebaseAuth.instance.currentUser;

    //get the shared tasks
    final tasksData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('tasks')
        .get();

    List<task_model.Task> tasks = [];

    //loop through the tasks
    for (var task in tasksData.docs) {
      tasks.add(task_model.Task(
        id: task.id,
        title: task['title'],
        dueDate: Utility.stringToDateTime(task['dueDate']),
        address: TaskAddress(
          latitude: task['latitude'],
          longitude: task['longitude'],
          address: task['address'],
        ),
        dueTime: Utility.stringToTimeOfDay(task['time']),
        priority: Utility.stringToPriorityEnum(task['priority']),
        isDone: task['isDone'],
        isDeleted: task['isDeleted'],
        category: task['category'],
        locationCategory: task['locationCategory'],
        owner: task['owner'],
        imageUrl: task['imageUrl'],
      ));
    }
    return tasks;
  }

  // function for fetching the reminders if logged user is the owner of the task
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

    //check if there is no reminders
    if (reminders.docs.isEmpty) {
      return [];
    }

    //convert the reminders to a list of maps
    final remindersList = reminders.docs.map((reminder) {
      return {
        'id': reminder.id,
        'contentId': reminder['contentId'],
        'reminder': reminder['reminder'],
      };
    }).toList();

    return remindersList;
  }

  // function for fetching the reminders if logged user is not the owner of the task
  static Future<List<Map<String, dynamic>>> fetchRemindersForSharedTask(
      String taskId) async {
    final user = FirebaseAuth.instance.currentUser;

    //get shared tasks and check if the taskId is equal to the one passed as argument
    //then get the reminders for that task and delete them
    final sharedTask = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('sharedTasks')
        .where('taskId', isEqualTo: taskId)
        .get();

    //get the reminders for sharedTask
    if (sharedTask.docs.isNotEmpty) {
      final sharedTaskId = sharedTask.docs[0].id;
      final reminders = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('sharedTasks')
          .doc(sharedTaskId)
          .collection('reminders')
          .get();

      //check if there is no reminders
      if (reminders.docs.isEmpty) {
        return [];
      }

      //convert the reminders to a list of maps
      final remindersList = reminders.docs.map((reminder) {
        return {
          'id': reminder.id,
          'contentId': reminder['contentId'],
          'reminder': reminder['reminder'],
        };
      }).toList();

      return remindersList;
    }

    return [];
  }

  // function for fetching the users from the database
  static Future<List<Map<String, dynamic>>> fetchUsers() async {
    //get the users from the database
    final users = await FirebaseFirestore.instance.collection('users').get();

    //check if there is no users
    if (users.docs.isEmpty) {
      return [];
    }

    //convert the users to a list of maps
    final usersList = users.docs.map((user) {
      return {
        'id': user.id,
        'email': user['email'],
      };
    }).toList();

    return usersList;
  }

  //function that walks through the shared task of user and retrieve the tasks based on
  //the owner id and task id
  static Future<List<task_model.Task>> fetchSharedTasks() async {
    final user = FirebaseAuth.instance.currentUser;

    //get the shared tasks
    final sharedTasks = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('sharedTasks')
        .get();

    List<task_model.Task> tasks = [];
    //loop through the shared tasks and get the tasks from the owner
    for (var sharedTask in sharedTasks.docs) {
      final task = await FirebaseFirestore.instance
          .collection('users')
          .doc(sharedTask['ownerId'])
          .collection('tasks')
          .doc(sharedTask['taskId'])
          .get();
      tasks.add(task_model.Task(
        id: task.id,
        title: task['title'],
        dueDate: Utility.stringToDateTime(task['dueDate']),
        address: TaskAddress(
          latitude: task['latitude'],
          longitude: task['longitude'],
          address: task['address'],
        ),
        dueTime: Utility.stringToTimeOfDay(task['time']),
        priority: Utility.stringToPriorityEnum(task['priority']),
        isDone: task['isDone'],
        isDeleted: task['isDeleted'],
        category: task['category'],
        locationCategory: task['locationCategory'],
        owner: task['owner'],
        imageUrl: task['imageUrl'],
      ));
    }
    return tasks;
  }

  static Future<int> getCategoryIcon(String categoryName) async {
    final user = FirebaseAuth.instance.currentUser;

    //get the categories from the connected user
    final categories = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('categories')
        .get();

    //get the category that matches the category name
    final category = categories.docs
        .where((element) => element['name'] == categoryName)
        .toList();

    //return the icon number
    return category.first['iconCode'];
  }

  //get done tasks from month
  static Future<List<task_model.Task>> getDoneTasksForMonth(
      DateTime selectedMonth) {
    final user = FirebaseAuth.instance.currentUser;

    //get the tasks from the connected user
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('tasks')
        .where('isDone', isEqualTo: true)
        .where('isDeleted', isEqualTo: false)
        .get()
        .then((snapshot) {
      List<task_model.Task> tasks = [];
      for (DocumentSnapshot ds in snapshot.docs) {
        final task = task_model.Task(
          id: ds.id,
          title: ds['title'],
          dueDate: Utility.stringToDateTime(ds['dueDate']),
          address: TaskAddress(
            latitude: ds['latitude'],
            longitude: ds['longitude'],
            address: ds['address'],
          ),
          dueTime: Utility.stringToTimeOfDay(ds['time']),
          priority: Utility.stringToPriorityEnum(ds['priority']),
          isDone: ds['isDone'],
          isDeleted: ds['isDeleted'],
          category: ds['category'],
          locationCategory: ds['locationCategory'],
          owner: ds['owner'],
          imageUrl: ds['imageUrl'],
        );

        //check only tasks that have a dueDate
        if (task.dueDate != null) {
          //check if the task is done and if the month of the task is equal to the selected month
          if (task.isDone &&
              task.dueDate!.month == selectedMonth.month &&
              task.dueDate!.year == selectedMonth.year) {
            tasks.add(task);
          }
        }
      }

      return tasks;
    });
  }

  //get tasks for month
  static Future<List<task_model.Task>> getTasksForMonth(
      DateTime selectedMonth) {
    final user = FirebaseAuth.instance.currentUser;

    //get the tasks from the connected user
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('tasks')
        .where('isDeleted', isEqualTo: false)
        .get()
        .then((snapshot) {
      List<task_model.Task> tasks = [];
      for (DocumentSnapshot ds in snapshot.docs) {
        final task = task_model.Task(
          id: ds.id,
          title: ds['title'],
          dueDate: Utility.stringToDateTime(ds['dueDate']),
          address: TaskAddress(
            latitude: ds['latitude'],
            longitude: ds['longitude'],
            address: ds['address'],
          ),
          dueTime: Utility.stringToTimeOfDay(ds['time']),
          priority: Utility.stringToPriorityEnum(ds['priority']),
          isDone: ds['isDone'],
          isDeleted: ds['isDeleted'],
          category: ds['category'],
          locationCategory: ds['locationCategory'],
          owner: ds['owner'],
          imageUrl: ds['imageUrl'],
        );

        //check only tasks that have a dueDate
        if (task.dueDate != null) {
          //check if the month of the task is equal to the selected month
          if (task.dueDate!.month == selectedMonth.month &&
              task.dueDate!.year == selectedMonth.year) {
            tasks.add(task);
          }
        }
      }

      return tasks;
    });
  }

  ///////////////////////////////////////////////////////////////////////////////
  // ********** TASK CRUD FUNCTIONS **********
  // function for adding tasks to the database
  static Future<String> addTask(task_model.Task newTask) async {
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
    String updatedCategory = 'Uncategorized';
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
      'time': Utility.timeOfDayToString(newTask.dueTime),
      'latitude': updatedLocation.latitude,
      'longitude': updatedLocation.longitude,
      'address': updatedLocation.address,
      'priority': Utility.priorityEnumToString(newTask.priority),
      'isDone': false,
      'isDeleted': false,
      'category': updatedCategory,
      'locationCategory': updatedLocationCategory,
      'owner': user.uid,
      'imageUrl': newTask.imageUrl,
    });

    return doc.id;
  }

  // function for deleting tasks in the database
  static Future<void> deleteTask(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('tasks')
        .doc(id)
        .delete();
  }

  // function for deleting all tasks marked as deleted in the database
  static void deleteAllTasks() {
    final user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('tasks')
        .where('isDeleted', isEqualTo: true)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
  }

  // function for updating tasks in the database
  static Future<void> updateTask(
      String editedTaskId, task_model.Task editedTask) async {
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
      'time': Utility.timeOfDayToString(editedTask.dueTime),
      'latitude': updatedLocation.latitude,
      'longitude': updatedLocation.longitude,
      'address': updatedLocation.address,
      'priority': Utility.priorityEnumToString(editedTask.priority),
      'isDone': editedTask.isDone,
      'isDeleted': editedTask.isDeleted,
      'category': editedTask.category,
      'locationCategory': updatedLocationCategory,
      'owner': editedTask.owner,
      'imageUrl': editedTask.imageUrl,
    });
  }

  // sharer can update the task
  static Future<void> updateSharedTask(
      String editedTaskId, task_model.Task editedTask) async {
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

    FirebaseFirestore.instance
        .collection('users')
        .doc(editedTask.owner)
        .collection('tasks')
        .doc(editedTaskId)
        .update({
      'title': editedTask.title,
      'dueDate': updatedDueDate,
      'time': Utility.timeOfDayToString(editedTask.dueTime),
      'latitude': updatedLocation.latitude,
      'longitude': updatedLocation.longitude,
      'address': updatedLocation.address,
      'priority': Utility.priorityEnumToString(editedTask.priority),
      'isDone': editedTask.isDone,
      'isDeleted': editedTask.isDeleted,
      'category': editedTask.category,
      'locationCategory': updatedLocationCategory,
      'owner': editedTask.owner,
      'imageUrl': editedTask.imageUrl,
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

  // function for marking a shared task as done in the database
  static void markSharedTaskAsDone(String id, String owner) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(owner)
        .collection('tasks')
        .doc(id)
        .update({'isDone': true});
  }

  ///////////////////////////////////////////////////////////////////////
  // ********** TASK CATEGORY CRUD FUNCTIONS **********
  //function for updating a task category
  static void updateTaskCategory(String id, TaskCategory editedCategory) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('categories')
        .doc(id)
        .update(
            {'name': editedCategory.name, 'iconCode': editedCategory.iconCode});
  }

  // function for adding a task category
  static void addTaskCategory(TaskCategory editedCategory) async {
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
      'iconCode': editedCategory.iconCode,
    });
  }

  // function for deleting a task category
  static void deleteTaskCategory(String categoryId) {
    final user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('categories')
        .doc(categoryId)
        .delete();
  }

  //check if the category is used in any task
  static Future<bool> isTaskCategoryUsed(String categoryId) async {
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
        .where('isDeleted', isEqualTo: false)
        .get();
    return tasks.docs.isNotEmpty;
  }

  /////////////////////////////////////////////////////////////////////
  // ********** SHARED TASKS **********
  // function that adds a user to the sharedWith array of a task
  static Future<void> addShareWithUser(String taskId, String email) async {
    // get the current user
    final user = FirebaseAuth.instance.currentUser;

    if (email == 'no users') {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('tasks')
          .doc(taskId)
          .update({'sharedWith': []});
      return;
    }

    // get the user that will be added to the task
    await getUserByEmail(email).then((userSharedWith) async {
      // add the user to the task in an array named sharedWith
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('tasks')
          .doc(taskId)
          .update({
        'sharedWith': FieldValue.arrayUnion([userSharedWith.id])
      });
    });
  }

  // function that returns the users that a task is shared with
  static Future<List<AppUser>> getSharedWithUsers(String taskId) async {
    final user = FirebaseAuth.instance.currentUser;
    final task = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('tasks')
        .doc(taskId)
        .get();

    final sharedWithUsersIds = task['sharedWith'];

    //get the users from the ids
    List<AppUser> sharedWithUsers = [];
    for (var userId in sharedWithUsersIds) {
      final user = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      sharedWithUsers.add(AppUser(
        id: user.id,
        email: user['email'],
      ));
    }
    return sharedWithUsers;
  }

  // function that deletes a user from the sharedWith array of a task
  static Future<void> deleteSharedWithUsers(String taskId) async {
    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('tasks')
        .doc(taskId)
        .update({'sharedWith': []});
  }

  //function that adds a shared task to a user
  static Future<void> addSharedTaskToUser(String taskId, String email) async {
    final owner = FirebaseAuth.instance.currentUser;

    //get the user by email
    await getUserByEmail(email).then((userSharedWith) async {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userSharedWith.id)
          .collection('sharedTasks')
          .add({
        'ownerId': owner!.uid,
        'taskId': taskId,
      });
    });
  }

  //function that deletes a shared task from a user
  static Future<void> deleteSharedTaskFromUser(
      String taskId, String email) async {
    final owner = FirebaseAuth.instance.currentUser;

    await getUserByEmail(email).then((user) async {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .collection('sharedTasks')
          .where('taskId', isEqualTo: taskId)
          .where('ownerId', isEqualTo: owner!.uid)
          .get()
          .then((value) {
        for (var doc in value.docs) {
          doc.reference.delete();
        }
      });
    });
  }

  /////////////////////////////////////////////////////////////////////
  //*********** REMINDERS **********
  //function that adds a new notification for a certain task
  static Future<void> addReminderForTask(
      String taskId, TaskReminder reminder) async {
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

  // function that deletes all the reminders for a certain task
  static Future<void> deleteRemindersForTask(String taskId) async {
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

  //check if a task has reminders
  static Future<bool> checkForReminders(String taskId) async {
    final user = FirebaseAuth.instance.currentUser;

    final reminders = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('tasks')
        .doc(taskId)
        .collection('reminders')
        .get();

    if (reminders.docs.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  // function that deletes the reminders for a task from a sharer
  static Future<void> deleteReminderssForSharedTask(String taskId) async {
    final user = FirebaseAuth.instance.currentUser;

    //get shared tasks and check if the taskId is equal to the one passed as argument
    //then get the reminders for that task and delete them
    final sharedTask = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('sharedTasks')
        .where('taskId', isEqualTo: taskId)
        .get();

    //get the reminders for sharedTask
    if (sharedTask.docs.isNotEmpty) {
      final sharedTaskId = sharedTask.docs[0].id;
      final reminders = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('sharedTasks')
          .doc(sharedTaskId)
          .collection('reminders')
          .get();

      //  delete the reminders
      if (reminders.docs.isNotEmpty) {
        for (var reminder in reminders.docs) {
          reminder.reference.delete();
        }
      }
    }
  }

  // function that adds a reminder for a shared task from a sharer
  static Future<void> addReminderForSharedTask(
      String taskId, TaskReminder newReminder) async {
    final user = FirebaseAuth.instance.currentUser;

    final sharedTask = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('sharedTasks')
        .where('taskId', isEqualTo: taskId)
        .get();

    if (sharedTask.docs.isNotEmpty) {
      final sharedTaskId = sharedTask.docs[0].id;

      //add the reminder
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('sharedTasks')
          .doc(sharedTaskId)
          .collection('reminders')
          .add({
        'contentId': newReminder.contentId,
        'reminder': newReminder.reminder,
      });
    }
  }

  ////////////////////////////////////////////////////////////////////////
  //*********** AUX FUNCTIONS **********
  //function that checks if there are deleted tasks
  static Future<bool> checkForDeletedTasks() async {
    final user = FirebaseAuth.instance.currentUser;

    final deletedTasks = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('tasks')
        .where('isDeleted', isEqualTo: true)
        .get();

    if (deletedTasks.docs.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  // get the logged in userId
  static String currentUserId() {
    return FirebaseAuth.instance.currentUser!.uid;
  }

  // return the user by email
  static Future<AppUser> getUserByEmail(String email) async {
    final user = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    return AppUser(
      id: user.docs.first.id,
      email: user.docs.first['email'],
    );
  }

  // return the user email by id
  static Future<String> getEmailByUserId(String userId) async {
    final user =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    return user['email'];
  }

////////////////////////////////////////////////////////////////////////
  //*********** IMAGE FUNCTIONS **********
  static Future<String> uploadImage(File? pickedImageFile) async {
    var uuid = const Uuid();
    var returnedUrl = '';

    final ref = FirebaseStorage.instance
        .ref()
        .child('users_tasks_images')
        .child(DBHelper.currentUserId())
        .child(uuid.v4());

    await ref.putFile(pickedImageFile!).whenComplete(
        () => ref.getDownloadURL().then((value) => returnedUrl = value));

    return returnedUrl;
  }

  static Future<String> uploadSharedImage(
      File? pickedImageFile, String owner) async {
    var uuid = const Uuid();
    var returnedUrl = '';

    final ref = FirebaseStorage.instance
        .ref()
        .child('users_tasks_images')
        .child(owner)
        .child(uuid.v4());

    await ref.putFile(pickedImageFile!).whenComplete(
        () => ref.getDownloadURL().then((value) => returnedUrl = value));

    return returnedUrl;
  }

  // function that deletes the image from the storage
  static Future<void> deleteImage(String imageUrl) async {
    final ref = FirebaseStorage.instance.refFromURL(imageUrl);

    //check if the image exists
    ref.getDownloadURL().then((url) {
      ref.delete();
    }).catchError((error) {
      //do nothing
    });
  }

  //function that updates the image for a task
  static Future<String?> updateImageForTask(
      File? pickedImageFile, String? previousImageUrl, bool deleted) async {
    String? imageUrl;
    if (pickedImageFile != null) {
      //check if the previous image was set and delete it
      if (previousImageUrl != null) {
        //delete the old image from the storage
        await DBHelper.deleteImage(previousImageUrl);
      }
      //upload the new image to the storage and return the url
      imageUrl = await DBHelper.uploadImage(pickedImageFile);
    } else {
      //if user didn't pick a new image
      //check if the user wants to delete the image
      if (previousImageUrl != null && deleted == false) {
        imageUrl = previousImageUrl;
      } else {
        if (previousImageUrl != null && deleted == true) {
          await DBHelper.deleteImage(previousImageUrl);
          imageUrl = null;
        }
      }
    }
    return imageUrl;
  }

  //function that updates the image for a shared task
  static Future<String?> updateImageForSharedTask(File? pickedImageFile,
      String ownerId, String? previousImageUrl, bool isDeleted) async {
    String? imageUrl;
    if (pickedImageFile != null) {
      //check if the previous image was set and delete it
      if (previousImageUrl != null) {
        //delete the old image from the storage
        await DBHelper.deleteImage(previousImageUrl);
      }
      //upload the new image to the storage and return the url
      imageUrl = await DBHelper.uploadSharedImage(pickedImageFile, ownerId);
    } else {
      //if user didn't pick a new image
      //check if the user wants to delete the image
      if (previousImageUrl != null && isDeleted == false) {
        imageUrl = previousImageUrl;
      } else {
        if (previousImageUrl != null && isDeleted == true) {
          await DBHelper.deleteImage(previousImageUrl);
          imageUrl = null;
        }
      }
    }
    return imageUrl;
  }

  //function for checking in the storage which tasks are marked as deleted and delete the images for them
  static void deleteAllImages() async {
    final user = FirebaseAuth.instance.currentUser;
    final tasks = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('tasks')
        .where('isDeleted', isEqualTo: true)
        .get();

    for (var task in tasks.docs) {
      if (task['imageUrl'] != null) {
        final ref = FirebaseStorage.instance.refFromURL(task['imageUrl']);

        //check if the image exists
        ref.getDownloadURL().then((url) {
          ref.delete();
        }).catchError((error) {
          //do nothing
        });
      }
    }
  }

  ///////////////////////////////////////////////////////////////////////////
}
