import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/task_service.dart';
import 'package:provider/provider.dart';

import '../../services/database_helper_service.dart';
import '../../helpers/utility.dart';
import '../../models/task.dart';
import '../../providers/task_provider.dart';
import '../../services/local_notification_service.dart';
import '../../widgets/other/image/image_preview.dart';
import '../pages/overall_agenda_page.dart';
import 'add_edit_task_screen.dart';

class TaskDetailsScreen extends StatefulWidget {
  static const String routeName = '/task-detail';

  const TaskDetailsScreen({super.key});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  bool dueDatePassed = false;
  bool dueTimePassed = false;
  bool _isMapLoading = true;
  int? categoryIconCode;
  Task loadedTask = Task();

  @override
  Widget build(BuildContext context) {
    final taskId = ModalRoute.of(context)!.settings.arguments as String;
    //can't use function from DBHelper cause build shouldn't be async
    loadedTask =
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
                              _deleteTask(context, loadedTask);
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //due date
                              displayDueDate(loadedTask),
                              const SizedBox(height: 10),
                              //due time
                              displayDueTime(loadedTask),
                              //priority
                              const SizedBox(height: 10),
                              displayPriority(loadedTask),
                            ],
                          ),
                          const SizedBox(height: 150),
                          Container(
                            child: displayImage(loadedTask),
                          ),
                        ],
                      ),
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

  ImagePreview displayImage(Task loadedTask) {
    //check if the task has an image
    return loadedTask.imageUrl == null
        ? const ImagePreview(
            imageUrl: 'assets/images/noimage.jpg',
            isUrl: false,
            isDefaultImage: true)
        : ImagePreview(
            imageUrl: loadedTask.imageUrl!, isUrl: true, isDefaultImage: false);
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
        FutureBuilder<void>(
          future: getCategoryIcon(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 25,
                width: 25,
                child: Center(child: CircularProgressIndicator()),
              );
            } else {
              for (int index = 0; index < Utility.iconList.length; index++) {
                if (categoryIconCode == Utility.iconList[index].codePoint) {
                  return Icon(
                    Utility.iconList[index],
                    color: Theme.of(context).colorScheme.primary,
                  );
                }
              }
            }
            return const SizedBox();
          },
        ),
        const SizedBox(width: 10),
        Text(loadedTask.category!, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Row displayDueDate(Task loadedTask) {
    var date = Utility.dateTimeToString(loadedTask.dueDate);

    //check if the dueDate is not null
    if (date != '--/--/----') {
      DateTime dueDate = Utility.badStringFormatToDateTime(date);

      var time = Utility.timeOfDayToString(loadedTask.dueTime);
      //check if dueTime is not null
      if (time != '--:--') {
        TimeOfDay dueTime = Utility.badStringFormatToTimeOfDay(time);

        //check if the due date has passed
        if (dueDate.isBefore(DateTime.now()) &&
            dueTime.hour <= DateTime.now().hour &&
            dueTime.minute <= DateTime.now().minute) {
          dueDatePassed = true;
        }

        return Row(children: [
          Icon(Icons.calendar_month,
              color: dueDatePassed
                  ? const Color.fromARGB(255, 217, 61, 50)
                  : Colors.black),
          const SizedBox(
            width: 10,
          ),
          Text(date,
              style: dueDatePassed
                  ? const TextStyle(
                      color: Color.fromARGB(255, 217, 61, 50),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    )
                  : const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ))
        ]);
      } else {
        //check if the due date has passed
        if (dueDate.isBefore(DateTime.now())) {
          dueDatePassed = true;
        }

        return Row(children: [
          Icon(Icons.calendar_month,
              color: dueDatePassed
                  ? const Color.fromARGB(255, 217, 61, 50)
                  : Colors.black),
          const SizedBox(
            width: 10,
          ),
          Text(
            date,
            style: dueDatePassed
                ? const TextStyle(
                    color: Color.fromARGB(255, 217, 61, 50),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  )
                : const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
          )
        ]);
      }
    }

    return Row(children: [
      const Icon(
        Icons.calendar_month,
        color: Colors.black,
      ),
      const SizedBox(
        width: 10,
      ),
      Text(
        date,
        style: !dueDatePassed
            ? const TextStyle(
                color: Colors.black,
                fontSize: 16,
              )
            : null,
      ),
    ]);
  }

  Row displayDueTime(Task loadedTask) {
    var time = Utility.timeOfDayToString(loadedTask.dueTime);

    if (time != '--:--') {
      TimeOfDay dueTime = Utility.badStringFormatToTimeOfDay(time);

      // check if the due time has passed
      if (dueTime.hour <= DateTime.now().hour &&
          dueTime.minute <= DateTime.now().minute &&
          dueDatePassed) {
        dueTimePassed = true;
      }

      return Row(children: [
        Icon(Icons.access_time,
            color: dueTimePassed
                ? const Color.fromARGB(255, 217, 61, 50)
                : Colors.black),
        const SizedBox(
          width: 10,
        ),
        Text(
          time,
          style: dueTimePassed
              ? const TextStyle(
                  color: Color.fromARGB(255, 217, 61, 50),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                )
              : const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
        )
      ]);
    }

    return Row(children: [
      const Icon(
        Icons.access_time,
        color: Colors.black,
      ),
      const SizedBox(
        width: 10,
      ),
      Text(
        time,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
      ),
    ]);
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
        SizedBox(
          width: 300,
          child: Text(
            'Shared by: $ownerEmail',
            style: const TextStyle(fontSize: 16),
            softWrap: true,
            maxLines: 3,
          ),
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
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      softWrap: true,
      maxLines: 3,
    );
  }

  Future<void> _deleteTask(BuildContext context, Task loaded) async {
    // delete task from database
    await DBHelper.deleteTask(loaded.id!);

    //check if the task has an image
    if (loaded.imageUrl != null) {
      //delete the image from the storage
      await DBHelper.deleteImage(loaded.imageUrl!);
    }

    // remove task from UI
    Provider.of<TaskProvider>(context, listen: false)
        .removeTaskFromScreen(loaded.id!);
  }

  void _markAsDeleted(BuildContext context, Task task) {
    // mark task as deleted in database
    DBHelper.markTaskAsDeleted(task.id!);

    //delete all notifications for this task
    LocalNotificationService.deleteNotification(task.id!);

    // delete all notifications for this task form the database
    DBHelper.deleteRemindersForTask(task.id!);

    // remove sharing for this task
    TaskService.removeSharingForTask(task.id!);

    // go to overall page and remove task from UI
    Navigator.of(context).pushReplacementNamed(OverallAgendaPage.routeName);
    Provider.of<TaskProvider>(context, listen: false)
        .removeTaskFromScreen(task.id!);
  }

  Color _priorityColor(Priority? priority) {
    return Utility.priorityEnumToString(priority) == "Important"
        ? const Color.fromARGB(255, 217, 61, 50)
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

  Future<void> getCategoryIcon() async {
    await DBHelper.getCategoryIcon(loadedTask.category!)
        .then((value) => categoryIconCode = value);
  }
}
