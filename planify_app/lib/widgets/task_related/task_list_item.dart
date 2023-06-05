import 'package:flutter/material.dart';
import '../../services/task_service.dart';
import 'package:provider/provider.dart';

import '../../services/database_helper_service.dart';
import '../../helpers/utility.dart';
import '../../models/task_address.dart';
import '../../providers/task_provider.dart';
import '../../screens/task_related/task_details_screen.dart';
import '../../services/notifications/local_notification_service.dart';

class TaskListItem extends StatefulWidget {
  final String? id;
  final String? title;
  final String? dueDate;
  final TaskAddress? address;
  final String? time;
  final String? priority;
  final bool? isDone;
  final bool? isDeleted;
  final String? locationCategory;
  final String? owner;
  final String? imageUrl;
  final String? category;

  const TaskListItem(
      {super.key,
      required this.id,
      this.title,
      this.dueDate,
      this.address,
      this.time,
      this.priority,
      this.isDone,
      this.isDeleted,
      this.locationCategory,
      this.owner,
      this.imageUrl,
      this.category});

  @override
  State<TaskListItem> createState() => _TaskListItemState();
}

class _TaskListItemState extends State<TaskListItem> {
  bool dueDatePassed = false;
  bool dueTimePassed = false;
  int? categoryIconCode;

  Future<void> _deleteTask(
      BuildContext context, String id, String? imageUrl) async {
    // delete task from database
    await DBHelper.deleteTask(id);

    //check if the task has an image
    if (imageUrl != null) {
      //delete the image from the storage
      await DBHelper.deleteImage(imageUrl);
    }

    // remove task from UI
    Provider.of<TaskProvider>(context, listen: false).removeTaskFromScreen(id);
  }

  void _markAsDeleted(BuildContext context, String id) {
    // mark task as deleted in database
    DBHelper.markTaskAsDeleted(id);

    //delete all notifications for this task from notification center
    LocalNotificationService.deleteNotification(id);

    // delete all notifications for this task form the database
    DBHelper.deleteRemindersForTask(id);

    // remove sharing for this task
    TaskService.removeSharingForTask(id);

    // remove task from UI
    Provider.of<TaskProvider>(context, listen: false).removeTaskFromScreen(id);
  }

  void _markAsUndeleted(BuildContext context, String id) {
    // mark task as undeleted in database
    DBHelper.markTaskAsUndeleted(id);

    // remove task from UI
    Provider.of<TaskProvider>(context, listen: false).removeTaskFromScreen(id);
  }

  void _markTaskAsDone(BuildContext context, String id) {
    // mark task as done in database
    DBHelper.markTaskAsDone(id);

    //delete all notifications for this task from notification center
    LocalNotificationService.deleteNotification(id);

    // delete all notifications for this task form the database
    DBHelper.deleteRemindersForTask(id);

    // mark task as done in UI
    Provider.of<TaskProvider>(context, listen: false).removeTaskFromScreen(id);
  }

  void _markSharedTaskAsDone(BuildContext context, String id, String owner) {
    // mark task as done in database
    DBHelper.markSharedTaskAsDone(id, owner);

    //delete all notifications for this task from notification center
    LocalNotificationService.deleteNotification(id);

    //delete all notifications for this task form the database
    DBHelper.deleteReminderssForSharedTask(id);

    // mark task as done in UI
    Provider.of<TaskProvider>(context, listen: false).removeTaskFromScreen(id);
  }

  Row displayPriority() {
    return Row(children: [
      Icon(_priorityIcon(widget.priority!),
          color: _priorityIconColor(widget.priority!)),
      const SizedBox(
        width: 6,
      ),
      Text(widget.priority!,
          style: widget.isDone!
              ? const TextStyle(
                  color: Color.fromARGB(255, 146, 145, 145),
                  fontWeight: FontWeight.bold,
                )
              : null)
    ]);
  }

  Row displayTime() {
    // if the due time is not null
    if (widget.time != '--:--') {
      TimeOfDay dueTime = Utility.badStringFormatToTimeOfDay(widget.time!);

      // check if the due date is not null
      if (widget.dueDate != '--/--/----') {
        DateTime dueDate = Utility.badStringFormatToDateTime(widget.dueDate!);

        // check if the due date/time has passed
        if (Utility.isPastDue(dueDate, dueTime)) {
          dueTimePassed = true;
        }

        return Row(children: [
          Icon(Icons.access_time,
              color: dueTimePassed
                  ? widget.isDone!
                      ? const Color.fromARGB(255, 146, 145, 145)
                      : const Color.fromARGB(255, 217, 61, 50)
                  : Colors.black),
          const SizedBox(
            width: 6,
          ),
          Text(widget.time!,
              style: dueTimePassed
                  ? TextStyle(
                      color: widget.isDone!
                          ? const Color.fromARGB(255, 146, 145, 145)
                          : const Color.fromARGB(255, 217, 61, 50),
                      fontWeight: FontWeight.bold,
                    )
                  : null)
        ]);
        //if the due date is null, check only if the due time has passed
        // keep the due date as DateTime.now()
      } else {
        //check if the due time has passed
        if (Utility.isPastDue(DateTime.now(), dueTime)) {
          dueTimePassed = true;
        }

        return Row(children: [
          Icon(Icons.access_time,
              color: dueTimePassed
                  ? widget.isDone!
                      ? const Color.fromARGB(255, 146, 145, 145)
                      : const Color.fromARGB(255, 217, 61, 50)
                  : Colors.black),
          const SizedBox(
            width: 6,
          ),
          Text(widget.time!,
              style: dueTimePassed
                  ? TextStyle(
                      color: widget.isDone!
                          ? const Color.fromARGB(255, 146, 145, 145)
                          : const Color.fromARGB(255, 217, 61, 50),
                      fontWeight: FontWeight.bold,
                    )
                  : null)
        ]);
      }

      //if the time is null
    } else {
      return Row(children: [
        Icon(
          Icons.access_time,
          color: widget.isDone!
              ? const Color.fromARGB(255, 146, 145, 145)
              : Colors.black,
        ),
        const SizedBox(
          width: 6,
        ),
        Text(widget.time!),
      ]);
    }
  }

  Row displayDueDate() {
    //check if the dueDate is not null
    if (widget.dueDate != '--/--/----') {
      DateTime dueDate = Utility.badStringFormatToDateTime(widget.dueDate!);

      //check if dueTime is not null
      if (widget.time != '--:--') {
        TimeOfDay dueTime = Utility.badStringFormatToTimeOfDay(widget.time!);

        //check if the due date has passed
        if (Utility.isPastDue(dueDate, dueTime)) {
          dueDatePassed = true;
        }

        return Row(children: [
          Icon(Icons.calendar_month,
              color: dueDatePassed
                  ? widget.isDone!
                      ? const Color.fromARGB(255, 146, 145, 145)
                      : const Color.fromARGB(255, 217, 61, 50)
                  : Colors.black),
          const SizedBox(
            width: 6,
          ),
          Text(widget.dueDate!,
              style: dueDatePassed
                  ? TextStyle(
                      color: widget.isDone!
                          ? const Color.fromARGB(255, 146, 145, 145)
                          : const Color.fromARGB(255, 217, 61, 50),
                      fontWeight: FontWeight.bold,
                    )
                  : null)
        ]);
      } else {
        //check if the due date has passed
        if (DateTime.now().isAfter(dueDate)) {
          dueDatePassed = true;
        }

        return Row(children: [
          Icon(Icons.calendar_month,
              color: dueDatePassed
                  ? widget.isDone!
                      ? const Color.fromARGB(255, 146, 145, 145)
                      : const Color.fromARGB(255, 217, 61, 50)
                  : Colors.black),
          const SizedBox(
            width: 6,
          ),
          Text(widget.dueDate!,
              style: dueDatePassed
                  ? TextStyle(
                      color: widget.isDone!
                          ? const Color.fromARGB(255, 146, 145, 145)
                          : const Color.fromARGB(255, 217, 61, 50),
                      fontWeight: FontWeight.bold,
                    )
                  : null)
        ]);
      }
    }

    return Row(children: [
      Icon(
        Icons.calendar_month,
        color: widget.isDone!
            ? const Color.fromARGB(255, 146, 145, 145)
            : Colors.black,
      ),
      const SizedBox(
        width: 6,
      ),
      Text(widget.dueDate!),
    ]);
  }

  ListTile displayTitleAndDoneDeleteIconButtons(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          widget.owner == DBHelper.currentUserId()
              ? FutureBuilder<void>(
                  future: getCategoryIcon(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 25,
                        width: 25,
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      for (int index = 0;
                          index < Utility.iconList.length;
                          index++) {
                        if (categoryIconCode ==
                            Utility.iconList[index].codePoint) {
                          return Icon(
                            Utility.iconList[index],
                            color: widget.isDone!
                                ? Colors.grey
                                : Theme.of(context).colorScheme.primary,
                          );
                        }
                      }
                    }
                    return const SizedBox();
                  },
                )
              : SizedBox(
                  width: 25,
                  child: Icon(
                    Icons.people,
                    color: widget.isDone!
                        ? Colors.grey
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
          const SizedBox(
            width: 6,
          ),
          Text(
            widget.title!,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: widget.isDone!
                  ? const Color.fromARGB(255, 130, 129, 129)
                  : Colors.black,
            ),
          ),
        ],
      ),
      //address or location category
      subtitle: widget.address!.address! == 'No address chosen'
          ? widget.locationCategory == 'No location category chosen'
              ? Row(children: const [
                  Icon(Icons.location_off_sharp),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'No address or location category chosen',
                      softWrap: true,
                      maxLines: 3,
                    ),
                  ),
                ])
              : Row(children: [
                  const Icon(Icons.share_location_sharp),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Location category: ${widget.locationCategory!}',
                      softWrap: true,
                      maxLines: 3,
                    ),
                  ),
                ])
          : Row(children: [
              const Icon(Icons.location_pin),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.address!.address!,
                  softWrap: true,
                  maxLines: 3,
                ),
              ),
            ]),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          !widget.isDone! &&
                  !widget
                      .isDeleted! // if isDone is false, show the check button
              ? IconButton(
                  icon: const Icon(
                    Icons.check,
                    color: Colors.green,
                  ),
                  onPressed: () {
                    widget.owner == DBHelper.currentUserId()
                        ? _markTaskAsDone(context, widget.id!)
                        : _markSharedTaskAsDone(
                            context, widget.id!, widget.owner!);
                  },
                )
              : widget.isDeleted! // if isDeleted is true, show the undo button
                  ? IconButton(
                      icon: const Icon(
                        Icons.arrow_circle_left,
                        color: Colors.green,
                      ),
                      onPressed: () {
                        // display alert dialog
                        Utility.displayQuestionDialog(context,
                                'Do you want to move the task back from Trash? You will have to set back the reminders and the persons you shared the task with.')
                            .then((value) {
                          if (value!) {
                            _markAsUndeleted(context, widget.id!);
                          }
                        });
                      },
                    )
                  : const SizedBox(width: 0),
          if (widget.owner == DBHelper.currentUserId())
            !widget.isDeleted! // if isDeleted is false, show the delete button
                ? IconButton(
                    icon: Icon(Icons.delete,
                        color: widget.isDone!
                            ? const Color.fromARGB(255, 202, 185, 185)
                            : const Color.fromARGB(255, 217, 61, 50)),
                    onPressed: () {
                      // display alert dialog
                      Utility.displayQuestionDialog(
                              context, 'Do you want to move the task in Trash?')
                          .then((value) {
                        if (value!) {
                          _markAsDeleted(context, widget.id!);
                        }
                      });
                    },
                  )
                : IconButton(
                    icon: Icon(Icons.delete_forever,
                        color: widget.isDone!
                            ? const Color.fromARGB(255, 202, 185, 185)
                            : const Color.fromARGB(255, 217, 61, 50)),
                    onPressed: () {
                      // display alert dialog
                      Utility.displayQuestionDialog(context,
                              'Do you want to permanently delete the task?')
                          .then((value) {
                        if (value!) {
                          _deleteTask(context, widget.id!, widget.imageUrl);
                        }
                      });
                    },
                  ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(widget.id),
      background: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.symmetric(
          horizontal: 15.0,
          vertical: 4.0,
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 40.0,
        ),
      ),
      direction: widget.isDeleted!
          ? DismissDirection.none
          : widget.owner == DBHelper.currentUserId()
              ? DismissDirection.endToStart
              : DismissDirection.none,
      confirmDismiss: (direction) {
        return Utility.displayQuestionDialog(
            context, 'Do you want to move the task in Trash?');
      },
      onDismissed: ((direction) => {
            _markAsDeleted(context, widget.id!),
          }),
      child: InkWell(
        onTap: () {
          // Navigate to task details screen
          Navigator.of(context)
              .pushNamed(TaskDetailsScreen.routeName, arguments: widget.id);
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          color: widget.priority == 'Important' && widget.isDone == false
              ? const Color.fromARGB(255, 255, 230, 230)
              : widget.priority == 'Casual' && widget.isDone == false
                  ? const Color.fromARGB(255, 236, 255, 232)
                  : widget.priority == 'Necessary' && widget.isDone == false
                      ? const Color.fromARGB(255, 254, 237, 221)
                      : widget.isDone == false
                          ? const Color.fromARGB(255, 255, 253, 230)
                          : const Color.fromARGB(255, 244, 243, 243),
          elevation: 4,
          margin: const EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              displayTitleAndDoneDeleteIconButtons(context),
              // more infos
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    displayDueDate(),
                    displayTime(),
                    displayPriority(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData? _priorityIcon(String priority) {
    return priority == "Important"
        ? Icons.priority_high
        : priority == "Necessary"
            ? Icons.warning
            : priority == "Casual"
                ? Icons.low_priority_sharp
                : Icons.question_mark;
  }

  Color? _priorityIconColor(String priority) {
    return priority == "Important" && !widget.isDone!
        ? const Color.fromARGB(255, 217, 61, 50)
        : priority == "Necessary" && !widget.isDone!
            ? Colors.orange
            : priority == "Casual" && !widget.isDone!
                ? Colors.green
                :
                // if the task is done, the priority icon color is grey
                widget.isDone!
                    ? const Color.fromARGB(255, 146, 145, 145)
                    : Colors.black;
  }

  Future<void> getCategoryIcon() async {
    await DBHelper.getCategoryIcon(widget.category!)
        .then((value) => categoryIconCode = value);
  }
}
