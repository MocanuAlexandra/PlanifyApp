import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../database/database_helper.dart';
import '../../helpers/utility.dart';
import '../../models/task.dart';
import '../../providers/task_provider.dart';
import '../../services/notification_service.dart';
import 'add_edit_task_screen.dart';

class TaskDetailsScreen extends StatefulWidget {
  const TaskDetailsScreen({super.key});

  static const String routeName = '/task-detail';

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  bool _isMapLoading = true;

  void _markAsDeleted(BuildContext context, Task task) {
    // mark task as deleted in database
    DBHelper.markTaskAsDeleted(task.id!);

    //delete all notifications for this task
    NotificationService.deleteNotification(task.id!);

    // delete all notifications for this task form the database
    DBHelper.deleteNotificationsForTask(task.id!);

    // remove task from UI
    Provider.of<TaskProvider>(context, listen: false).deleteTask(task.id!);
  }

  void _deleteTask(BuildContext context, String id) {
    // delete task from database
    DBHelper.deleteTask(id);

    // remove task from UI
    Provider.of<TaskProvider>(context, listen: false).deleteTask(id);
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

  Row displayAddressOrLocationCategory(Task loadedTask) {
    return loadedTask.address!.address! == 'No address chosen'
        ? loadedTask.locationCategory == 'No location category chosen'
            ? Row(
                children: const [
                  Icon(Icons.location_off),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text('No address or location category chosen',
                        style: TextStyle(fontSize: 16)),
                  ),
                ],
              )
            : Row(
                children: [
                  const Icon(Icons.share_location),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                        'Location category: ${loadedTask.locationCategory!}',
                        style: const TextStyle(fontSize: 16)),
                  ),
                ],
              )
        : Row(children: [
            const Icon(Icons.location_pin),
            const SizedBox(width: 10),
            Expanded(
              child: loadedTask.address!.address! == 'No address chosen'
                  ? loadedTask.locationCategory == 'No location category chosen'
                      ? const Text('No address or location category chosen',
                          style: TextStyle(fontSize: 16))
                      : Text(
                          'Location category: ${loadedTask.locationCategory!}',
                          style: const TextStyle(fontSize: 16))
                  : Text(loadedTask.address!.address!,
                      style: const TextStyle(fontSize: 16)),
            ),
          ]);
  }

  @override
  Widget build(BuildContext context) {
    final taskId = ModalRoute.of(context)!.settings.arguments as String;
    final loadedTask =
        Provider.of<TaskProvider>(context, listen: false).findById(taskId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              loadedTask.isDeleted == false
                  ?
                  // display alert dialog
                  Utility.displayQuestionDialog(
                          context, 'Do you want to move the task in Trash?')
                      .then((value) {
                      if (value!) {
                        _markAsDeleted(context, loadedTask);
                        Navigator.of(context).pop();
                      }
                    })
                  :
                  // display alert dialog
                  Utility.displayQuestionDialog(context,
                          'Do you want to permanently delete the task?')
                      .then((value) {
                      if (value!) {
                        _deleteTask(context, loadedTask.id!);
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
                  displayAddressOrLocationCategory(loadedTask),
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
