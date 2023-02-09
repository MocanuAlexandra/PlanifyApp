import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:planify_app/helpers/notification_helper.dart';
import 'package:provider/provider.dart';

import '../../database/database_helper.dart';
import '../../helpers/utility.dart';
import '../../providers/tasks.dart';
import '../../models/task.dart';
import 'add_edit_task_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key});

  static const String routeName = '/task-detail';

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  bool _isMapLoading = true;

  void _markAsDeleted(BuildContext context, Task task) {
    // mark task as deleted in database
    DBHelper.markTaskAsDeleted(task.id!);

    //delete all notifications for this task
    NotificationHelper.deleteNotification(task.id!);

    // delete all notifications for this task form the database
    DBHelper.deleteNotificationsForTask(task.id!);

    // remove task from UI
    Provider.of<Tasks>(context, listen: false).deleteTask(task.id!);
  }

  //auxiliary methods
  Container displayMap(Task loadedTask) {
    return Container(
      height: 200,
      width: double.infinity,
      alignment: Alignment.center,
      child: loadedTask.address!.latitude == 0 &&
              loadedTask.address!.longitude == 0
          ? const SizedBox(height: 10)
          : Stack(children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                    target: LatLng(loadedTask.address!.latitude!,
                        loadedTask.address!.longitude!),
                    zoom: 15.0),
                onMapCreated: (GoogleMapController controller) {
                  setState(() {
                    _isMapLoading = false;
                  });
                },
                markers: {
                  Marker(
                    markerId: MarkerId(loadedTask.address!.address!),
                    position: LatLng(loadedTask.address!.latitude!,
                        loadedTask.address!.longitude!),
                    infoWindow: InfoWindow(
                        title: loadedTask.title!,
                        snippet: loadedTask.address!.address!),
                  )
                },
              ),
              if (_isMapLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ]),
    );
  }

  Text displayTitle(Task loadedTask) {
    return Text(
      loadedTask.title!,
      style: const TextStyle(fontSize: 20),
      softWrap: true,
      maxLines: 3,
    );
  }

  Row displayCategory(Task loadedTask) {
    return Row(
      children: [
        const Icon(Icons.category),
        const SizedBox(width: 10),
        Text(loadedTask.category!, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Row displayDueDate(Task loadedTask) {
    return Row(
      children: [
        const Icon(Icons.calendar_month),
        const SizedBox(width: 10),
        Text(Utility.dateTimeToString(loadedTask.dueDate),
            style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Row displayDueTime(Task loadedTask) {
    return Row(
      children: [
        const Icon(Icons.access_time),
        const SizedBox(width: 10),
        Text(Utility.timeOfDayToString(loadedTask.time),
            style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Row displayPriority(Task loadedTask) {
    return Row(
      children: [
        Icon(_priorityIcon(loadedTask.priority),
            color: _priorityColor(loadedTask.priority)),
        const SizedBox(width: 10),
        Text(Utility.priorityEnumToString(loadedTask.priority),
            style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Row displayAddress(Task loadedTask) {
    return Row(children: [
      const Icon(Icons.location_pin),
      Expanded(
        child: Text(
          loadedTask.address!.address!,
          softWrap: true,
          maxLines: 3,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final taskId = ModalRoute.of(context)!.settings.arguments as String;
    final loadedTask =
        Provider.of<Tasks>(context, listen: false).findById(taskId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              // display alert dialog
              Utility.displayAlertDialog(
                      context, 'Do you want to move the task in Trash?')
                  .then((value) {
                if (value!) {
                  _markAsDeleted(context, loadedTask);
                  Navigator.of(context).pop();
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(children: [
                  //title
                  displayTitle(loadedTask),
                  const SizedBox(height: 20),
                  //due date
                  displayDueDate(loadedTask),
                  const SizedBox(height: 10),
                  //due time
                  displayDueTime(loadedTask),
                  //priority
                  const SizedBox(height: 10),
                  displayPriority(loadedTask),
                  const SizedBox(height: 10),
                  displayCategory(loadedTask),
                  //address
                  const SizedBox(height: 10),
                  displayAddress(loadedTask),
                  const SizedBox(height: 10),
                  //show map
                  displayMap(loadedTask),
                  const SizedBox(height: 10),
                ]),
              ),
            ),
          ),
        ],
      ),
      //edit button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .pushNamed(AddEditTaskScreen.routeName, arguments: taskId);
        },
        child: const Icon(Icons.edit),
      ),
    );
  }

  IconData _priorityIcon(Priority? priority) {
    return Utility.priorityEnumToString(priority) == "Important"
        ? Icons.priority_high
        : Utility.priorityEnumToString(priority) == "Necessary"
            ? Icons.warning
            : Utility.priorityEnumToString(priority) == "Casual"
                ? Icons.low_priority_sharp
                : Icons.question_mark;
  }

  Color _priorityColor(Priority? priority) {
    return Utility.priorityEnumToString(priority) == "Important"
        ? Colors.red
        : Utility.priorityEnumToString(priority) == "Necessary"
            ? Colors.orange
            : Utility.priorityEnumToString(priority) == "Casual"
                ? Colors.green
                : Colors.black;
  }
}
