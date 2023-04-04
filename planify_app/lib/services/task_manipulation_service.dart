import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';
import 'database_helper_service.dart';

class TaskManipulationService {
  static Timer? timer;

  static void turnOnAutoEmptyingTrash(
      int? intervalOfEmptyingTrash, BuildContext context) {
    timer =
        Timer.periodic(Duration(minutes: intervalOfEmptyingTrash!), (timer) {
      emptyTrash(context, intervalOfEmptyingTrash);
    });
  }

  static void turnOffAutoEmptyingTrash() {
    timer!.cancel();
  }

  static emptyTrash(BuildContext context, int? intervalOfEmptyingTrash) {
    //remove the images for the tasks
    DBHelper.deleteAllImages();

    //delete tasks from DB
    DBHelper.deleteAllTasks();

    // remove task from UI
    Provider.of<TaskProvider>(context, listen: false).deleteAllTasks();
  }
}
