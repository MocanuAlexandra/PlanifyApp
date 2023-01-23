import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../database/database_helper.dart';
import '../helpers/utility.dart';
import '../providers/tasks.dart';
import '../widgets/task/add_new_task_form.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key});

  static const String routeName = '/task-detail';

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  void _deleteTask(BuildContext context, String id) {
    // delete task from database
    DBHelper.deleteTask(id);

    // delete task from UI
    Provider.of<Tasks>(context, listen: false).deleteTask(id);
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
              _deleteTask(context, loadedTask.id!);
              Navigator.of(context).pop();
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
                  //title field
                  Text(
                    loadedTask.title!,
                    style: const TextStyle(fontSize: 20),
                    softWrap: true,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  //due date field
                  Row(
                    children: [
                      const Icon(Icons.calendar_month),
                      const SizedBox(width: 10),
                      Text(DateFormat('dd/MM/yyyy').format(loadedTask.dueDate!),
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  //due time field
                  Row(
                    children: [
                      const Icon(Icons.access_time),
                      const SizedBox(width: 10),
                      Text(Utility.timeOfDayToString(loadedTask.time),
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  //priority field
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                          Utility.priorityEnumToString(loadedTask.priority) ==
                                  "Important"
                              ? Icons.priority_high
                              : Utility.priorityEnumToString(
                                          loadedTask.priority) ==
                                      "Necessary"
                                  ? Icons.warning
                                  : Utility.priorityEnumToString(
                                              loadedTask.priority) ==
                                          "Casual"
                                      ? Icons.low_priority_sharp
                                      : Icons.question_mark,
                          color: Utility.priorityEnumToString(
                                      loadedTask.priority) ==
                                  "Important"
                              ? Colors.red
                              : Utility.priorityEnumToString(
                                          loadedTask.priority) ==
                                      "Necessary"
                                  ? Colors.orange
                                  : Utility.priorityEnumToString(
                                              loadedTask.priority) ==
                                          "Casual"
                                      ? Colors.green
                                      : Colors.black),
                      const SizedBox(width: 10),
                      Text(Utility.priorityEnumToString(loadedTask.priority),
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  //adress field
                  const SizedBox(height: 10),
                  Row(children: [
                    const Icon(Icons.location_pin),
                    Expanded(
                      child: Text(
                        loadedTask.address!.address!,
                        softWrap: true,
                        maxLines: 3,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  //show map
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: loadedTask.address!.latitude == 0 &&
                            loadedTask.address!.longitude == 0
                        ? const SizedBox(height: 10)
                        : GoogleMap(
                            initialCameraPosition: CameraPosition(
                                target: LatLng(loadedTask.address!.latitude!,
                                    loadedTask.address!.longitude!),
                                zoom: 15.0),
                            markers: {
                              Marker(
                                markerId:
                                    MarkerId(loadedTask.address!.address!),
                                position: LatLng(loadedTask.address!.latitude!,
                                    loadedTask.address!.longitude!),
                                infoWindow: InfoWindow(
                                    title: loadedTask.title!,
                                    snippet: loadedTask.address!.address!),
                              )
                            },
                          ),
                  ),
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
          // Navigator.of(context)
          //     .pushNamed(AddNewTaskForm.routeName, arguments: taskId);
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}
