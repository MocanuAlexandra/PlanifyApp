import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../models/task.dart';
import '../models/task_reminder.dart';
import 'database_helper_service.dart';
import 'notifications/local_notification_service.dart';
import 'notifications/remote_notification_service.dart';

class TaskService {
  static Timer? timer;

  //********************* TASK MANIPULATION **********************/
  //main function for edit a task
  static Future<void> editTask(
      Task editedTask,
      File? pickedImageFile,
      bool isImageDeleted,
      List<String> selectedUserEmails,
      List<String> selectedReminders) async {
    //check if the logged in user is the owner of the task in order to update the task accordingly
    if (editedTask.owner == DBHelper.currentUserId() ||
        editedTask.owner == null) {
      //update the image in the database storage and get the url
      //then set the image url in the task
      editedTask.imageUrl = await DBHelper.updateImageForTask(
          pickedImageFile, editedTask.imageUrl, isImageDeleted);

      //update the task in the database
      await DBHelper.updateTask(editedTask.id!, editedTask);

      //add notifications to the selected users
      List<String> tokens = await DBHelper.getDeviceTokens(selectedUserEmails);
      for (String token in tokens) {
        await RemoteNotificationService.sendNotificationAboutEditTaskToUsers(
            token, editedTask.title!);
      }

      //delete the notifications for the task and then add the new ones
      await deleteNotificationsForTask(editedTask.id!).then((value) async => {
            //check if the user selected a due date or time
            if (editedTask.dueDate != null || editedTask.dueTime != null)
              {
                await addRemindersForTask(
                    editedTask.id!, selectedReminders, editedTask),
              }
          });

      //remove sharing for task, then update it
      await removeSharingForTask(editedTask.id!).then((value) async => {
            await shareTask(editedTask.id!, selectedUserEmails),
          });
    } else {
      //update the image in the database storage and get the url
      //then set the image url in the task
      editedTask.imageUrl = await DBHelper.updateImageForSharedTask(
          pickedImageFile,
          editedTask.owner!,
          editedTask.imageUrl,
          isImageDeleted);

      //update the task in the database
      await DBHelper.updateSharedTask(editedTask.id!, editedTask);

      //delete the notifications for the task and then add the new ones
      await deleteNotificationsForSharedTask(editedTask.id!)
          .then((value) async => {
                //check if the user selected a due date or time
                if (editedTask.dueDate != null || editedTask.dueTime != null)
                  {
                    await addRemindersForTask(
                        editedTask.id!, selectedReminders, editedTask),
                  }
              });
    }
  }

  //main function for add a task
  static Future<void> addTask(
      Task editedTask,
      File? pickedImageFile,
      bool isImageDeleted,
      List<String> selectedUserEmails,
      List<String> selectedReminders) async {
    //add the image in the database storage and get the url
    //then set the image url in the task
    editedTask.imageUrl = await DBHelper.updateImageForTask(
        pickedImageFile, editedTask.imageUrl, isImageDeleted);

    //add the task in the database
    String taskId = await DBHelper.addTask(editedTask);

    //share the task with the selected users
    await shareTask(taskId, selectedUserEmails);

    //add notifications to the selected users
    List<String> tokens = await DBHelper.getDeviceTokens(selectedUserEmails);
    for (String token in tokens) {
      await RemoteNotificationService.sendNotificationAboutNewTaskToUsers(
          token, editedTask.title!);
    }

    //check if the user selected a due date or time
    if (editedTask.dueDate != null || editedTask.dueTime != null) {
      //add notifications for the task
      await addRemindersForTask(taskId, selectedReminders, editedTask);
    }
  }

  //////////////////////////////////////////////////////////////////////////

  //******************** TRASH MANIPULATION********************/
  // turn on the auto emptying trash
  static Future<void> turnOnAutoEmptyingTrash(
      int? intervalOfEmptyingTrash, BuildContext context) async {
    print("turned on self emptying trash");
    // Check if there is any trash at the moment
    if (await DBHelper.checkIfDeletedTasksExist()) {
      print("first check for emptying trash");
      emptyTrash();
    }

    // Schedule periodic emptying of trash
    timer = Timer.periodic(Duration(minutes: intervalOfEmptyingTrash!),
        (timer) async {
      if (await DBHelper.checkIfDeletedTasksExist()) {
        print("interval check for emptying trash");
        emptyTrash();
      }
    });
  }

  // turn off the auto emptying trash
  static void turnOffAutoEmptyingTrash() {
    print("turned off self emptying trash");
    if (timer != null) {
      timer!.cancel();
    }
  }

  //main function for emptying trash
  static emptyTrash() {
    print("emptying trash..");
    //remove the images for the tasks
    DBHelper.deleteAllImages();

    //delete tasks from DB
    DBHelper.deleteAllTasks();
  }
  //////////////////////////////////////////////////////////////////////

  //*********************** AUX FUNCTIONS **********************/

  //delete the notifications for the task
  static Future<void> deleteNotificationsForTask(String taskId) async {
    //delete the notifications for the task from the database
    await DBHelper.deleteRemindersForTask(taskId);

    //delete the notifications for the task from the notification center
    LocalNotificationService.deleteNotification(taskId);
  }

  //delete the notifications for the shared task
  static Future<void> deleteNotificationsForSharedTask(String taskId) async {
    //delete the notifications for the task from the database
    await DBHelper.deleteReminderssForSharedTask(taskId);

    //delete the notifications for the task from the notification center
    LocalNotificationService.deleteNotification(taskId);
  }

  //add the users to whom we shared the task
  static Future<void> shareTask(
      String taskId, List<String> selectedUserEmails) async {
    //add the users to the task
    if (selectedUserEmails.isNotEmpty) {
      for (var email in selectedUserEmails) {
        //first we add to task a list containing the id of users to whom we shared the task
        await DBHelper.addShareWithUser(taskId, email);

        // then we add to each user to whom we shared the task, a collection named 'sharedTask'
        // in which we add a document containing the owner of task and taskId
        await DBHelper.addSharedTaskToUser(taskId, email);
      }
    } else {
      //if the _selectedUsersEmails is empty, we add an empty list 'sharedWith' in the task
      await DBHelper.addShareWithUser(taskId, 'no users');
    }
  }

  //add the notifications for the task
  static Future<void> addRemindersForTask(
      String taskId, List<String> selectedReminders, Task editedTask) async {
    //parse the selected reminders and create a notification for each one
    if (selectedReminders.isNotEmpty) {
      for (String reminder in selectedReminders) {
        TaskReminder newReminder;
        //check if the user selected only due date
        if (editedTask.dueDate != null && editedTask.dueTime == null) {
          newReminder = TaskReminder(
            contentId: taskId.hashCode +
                editedTask.dueDate!.day +
                editedTask.dueDate!.month +
                editedTask.dueDate!.year +
                reminder.hashCode,
            reminder: reminder,
          );
          //add the notification to database
          await DBHelper.addReminderForTask(taskId, newReminder);
        }
        //check if the user selected only time
        else if (editedTask.dueDate == null && editedTask.dueTime != null) {
          newReminder = TaskReminder(
            contentId: taskId.hashCode +
                editedTask.dueTime!.hour +
                editedTask.dueTime!.minute +
                reminder.hashCode,
            reminder: reminder,
          );
          //add the notification to database according to the logged in user
          if (editedTask.owner == DBHelper.currentUserId() ||
              editedTask.owner == null) {
            await DBHelper.addReminderForTask(taskId, newReminder);
          } else {
            await DBHelper.addReminderForSharedTask(taskId, newReminder);
          }
          //else it means that the user selected both due date and time
        } else {
          newReminder = TaskReminder(
            contentId: taskId.hashCode +
                editedTask.dueDate!.day +
                editedTask.dueDate!.month +
                editedTask.dueDate!.year +
                editedTask.dueTime!.hour +
                editedTask.dueTime!.minute +
                reminder.hashCode,
            reminder: reminder,
          );
          //add the notification to database according to the logged in user
          if (editedTask.owner == DBHelper.currentUserId() ||
              editedTask.owner == null) {
            await DBHelper.addReminderForTask(taskId, newReminder);
          } else {
            await DBHelper.addReminderForSharedTask(taskId, newReminder);
          }
        }

        //add the notification to notification center
        LocalNotificationService.createNotificationForTask(
            editedTask, reminder, newReminder, taskId);
      }
    }
  }

  //function that checks already selected users emails from database and returns a list of them
  static Future<List<String>> determineAlreadySharedWithUsers(String? taskId,
      [String? ownerId]) async {
    List<String> alreadySelectedUserEmails = [];
    if (taskId != null) {
      await DBHelper.getSharedWithUsers(taskId, ownerId).then((userTasks) => {
            for (final user in userTasks)
              {
                alreadySelectedUserEmails.add(user.email!),
              }
          });
    }
    return alreadySelectedUserEmails;
  }

  //function that removes the task from the users' shared tasks
  static Future<void> removeSharingForTask(String taskId) async {
    //delete the task from the users' shared tasks
    var sharedWithUsers = await determineAlreadySharedWithUsers(taskId);
    if (sharedWithUsers.isNotEmpty) {
      for (var email in sharedWithUsers) {
        await DBHelper.deleteSharedTaskFromUser(taskId, email);
      }
    }

    //delete the users for the task from the database
    await DBHelper.deleteSharedWithUsers(taskId);
  }

////////////////////////////////////////////////////////////////////////////////////

//********************* Determine nature of task ************************************//
  //function that check if the task that we are trying to add is an appointment
  // so has "appointment" word in title
  static bool isAppointment(Task task) {
    if ((task.title!.toLowerCase().contains('appointment') ||
            task.title!.toLowerCase().contains('doctor') ||
            task.title!.toLowerCase().contains('dentist')) &&
        (((task.dueDate == null && task.dueTime == null)) ||
            (task.dueDate != null && task.dueTime == null) ||
            (task.dueDate == null && task.dueTime != null))) {
      return true;
    } else {
      return false;
    }
  }

  //same for test/exam
  static bool isExam(Task task) {
    if ((task.title!.toLowerCase().contains('exam') ||
            task.title!.toLowerCase().contains('examen') ||
            task.title!.toLowerCase().contains('test')) &&
        (((task.dueDate == null && task.dueTime == null)) ||
            (task.dueDate != null && task.dueTime == null) ||
            (task.dueDate == null && task.dueTime != null))) {
      return true;
    } else {
      return false;
    }
  }

  //same for meeting
  static bool isMeeting(Task task) {
    if ((task.title!.toLowerCase().contains('meeting') ||
            task.title!.toLowerCase().contains('reunion') ||
            task.title!.toLowerCase().contains('meet')) &&
        (((task.dueDate == null && task.dueTime == null)) ||
            (task.dueDate != null && task.dueTime == null) ||
            (task.dueDate == null && task.dueTime != null))) {
      return true;
    } else {
      return false;
    }
  }

  //same for interview
  static bool isInterview(Task task) {
    if ((task.title!.toLowerCase().contains('interview')) &&
        (((task.dueDate == null && task.dueTime == null)) ||
            (task.dueDate != null && task.dueTime == null) ||
            (task.dueDate == null && task.dueTime != null))) {
      return true;
    } else {
      return false;
    }
  }
  ////////////////////////////////////////////////////////////////////
}
