import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:planify_app/screens/pages/overall_agenda_page.dart';
import 'package:provider/provider.dart';

import '../../helpers/database_helper.dart';
import '../../helpers/utility.dart';
import '../../models/task.dart';
import '../../providers/task_provider.dart';
import '../../services/notification_service.dart';
import 'add_edit_task_screen.dart';

class TaskDetailsScreen extends StatefulWidget {
  static const String routeName = '/task-detail';

  const TaskDetailsScreen({super.key});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  bool _isMapLoading = true;

  @override
  Widget build(BuildContext context) {
    final taskId = ModalRoute.of(context)!.settings.arguments as String;
    final loadedTask =
        Provider.of<TaskProvider>(context, listen: false).findById(taskId);

    return FutureBuilder<String>(
      future: DBHelper.getEmailByUserId(loadedTask.owner!),
      builder: (context, snapshot) {
        String ownerEmail = snapshot.data ?? '';
        return Scaffold(
          appBar: AppBar(
            title: const Text('Details'),
            actions: [
              //shared task can be deleted only by the owner
              if (loadedTask.owner == DBHelper.currentUserId())
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: () {
                    // if the task is not deleted, display alert dialog
                    loadedTask.isDeleted == false
                        ?
                        // display alert dialog
                        Utility.displayQuestionDialog(context,
                                'Do you want to move the task in Trash?')
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
                      const SizedBox(height: 10),
                      //check if the owner is the current user, so that the owner is not displayed
                      if (loadedTask.owner != DBHelper.currentUserId())
                        //owner
                        displayOwner(ownerEmail),
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
      },
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
            IconButton(
                onPressed: () {
                  Utility.displayInformationalDialog(
                    context,
                    'Tap on the red marker on the map for additional actions.',
                  );
                },
                icon: const Icon(Icons.help)),
          ]);
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
        Text(Utility.timeOfDayToString(loadedTask.dueTime),
            style: const TextStyle(fontSize: 16)),
      ],
    );
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

  Row displayOwner(String ownerEmail) {
    return Row(
      children: [
        const Icon(Icons.person),
        const SizedBox(width: 10),
        Text(
          'Shared by: $ownerEmail',
          style: const TextStyle(fontSize: 16),
          softWrap: true,
          maxLines: 3,
        ),
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

  Text displayTitle(Task loadedTask) {
    return Text(
      loadedTask.title!,
      style: const TextStyle(fontSize: 20),
      softWrap: true,
      maxLines: 3,
    );
  }

  void _deleteTask(BuildContext context, String id) {
    // delete task from database
    DBHelper.deleteTask(id);

    // remove task from UI
    Provider.of<TaskProvider>(context, listen: false).deleteTask(id);
  }

  Future<void> _markAsDeleted(BuildContext context, Task task) async {
    // mark task as deleted in database
    DBHelper.markTaskAsDeleted(task.id!);

    //delete all notifications for this task
    NotificationService.deleteNotification(task.id!);

    // delete all notifications for this task form the database
    DBHelper.deleteRemindersForTask(task.id!);

    // remove sharing for this task
    Utility.removeSharingForTask(task.id!);

    // go to overall page and remove task from UI
    Navigator.of(context).pushReplacementNamed(OverallAgendaPage.routeName);
    Provider.of<TaskProvider>(context, listen: false).deleteTask(task.id!);
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

  IconData _priorityIcon(Priority? priority) {
    return Utility.priorityEnumToString(priority) == "Important"
        ? Icons.priority_high
        : Utility.priorityEnumToString(priority) == "Necessary"
            ? Icons.warning
            : Utility.priorityEnumToString(priority) == "Casual"
                ? Icons.low_priority_sharp
                : Icons.question_mark;
  }
}
