import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planify_app/models/task_adress.dart';
import 'package:provider/provider.dart';

import '../../database/database_helper.dart';
import '../../providers/tasks.dart';
import '../../screens/task_detail_screen.dart';

class TaskListItem extends StatelessWidget {
  final String? id;
  final String? title;
  final DateTime? dueDate;
  final TaskAdress? address;
  final String? time;
  final String? priority;
  final bool? isDone;
  final bool? isDeleted;

  const TaskListItem({
    super.key,
    required this.id,
    this.title,
    this.dueDate,
    this.address,
    this.time,
    this.priority,
    this.isDone,
    this.isDeleted,
  });

  void _deleteTask(BuildContext context, String id) {
    // delete task from database
    DBHelper.deleteTask(id);

    // remove task from UI
    Provider.of<Tasks>(context, listen: false).deleteTask(id);
  }

  void _markAsDeleted(BuildContext context, String id) {
    // mark task as deleted in database
    DBHelper.markTaskAsDeleted(id);

    // remove task from UI
    Provider.of<Tasks>(context, listen: false).deleteTask(id);
  }

  void _markAsUndeleted(BuildContext context, String id) {
    // mark task as undeleted in database
    DBHelper.markTaskAsUndeleted(id);

    // remove task from UI
    Provider.of<Tasks>(context, listen: false).deleteTask(id);
  }

  void _markTaskAsDone(BuildContext context, String id) {
    // mark task as done in database
    DBHelper.markTaskAsDone(id);

    // mark task as done in UI
    Provider.of<Tasks>(context, listen: false).deleteTask(id);
  }

  Row displayPriority() {
    return Row(children: [
      Icon(_prorityIcon(priority!), color: _priorityIconColor(priority!)),
      const SizedBox(
        width: 6,
      ),
      Text(priority!)
    ]);
  }

  Row displayTime() {
    return Row(children: [
      const Icon(Icons.access_time),
      const SizedBox(
        width: 6,
      ),
      Text(time!)
    ]);
  }

  Row displayDueDate() {
    return Row(children: [
      const Icon(Icons.calendar_month),
      const SizedBox(
        width: 6,
      ),
      Text(
        DateFormat('dd/MM/yyyy').format(dueDate!),
      ),
    ]);
  }

  ListTile displayTitleAndDoneDeleteIconButtons(BuildContext context) {
    return ListTile(
      title: Text(
        title!,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      //address
      subtitle: Row(children: [
        const Icon(Icons.location_pin),
        Expanded(
          child: Text(
            address!.address!,
            softWrap: true,
            maxLines: 3,
          ),
        ),
      ]),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          !isDone! && !isDeleted! // if isDone is false, show the check button
              ? IconButton(
                  icon: const Icon(
                    Icons.check,
                    color: Colors.green,
                  ),
                  onPressed: () {
                    _markTaskAsDone(context, id!);
                  },
                )
              : isDeleted! // if isDeleted is true, show the undo button
                  ? IconButton(
                      icon: const Icon(
                        Icons.arrow_circle_left,
                        color: Colors.green,
                      ),
                      onPressed: () {
                        _markAsUndeleted(context, id!);
                      },
                    )
                  : const SizedBox(width: 0),
          !isDeleted! // if isDeleted is false, show the delete button
              ? IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _markAsDeleted(context, id!);
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  onPressed: () {
                    _deleteTask(context, id!);
                  },
                ),
        ],
      ),
    );
  }

  Future<bool?> displayAlertDialogForDelete(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Question'),
              content: const Text('Do you want to move the task in Trash?'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Yes')),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('No')),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
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
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return displayAlertDialogForDelete(context);
      },
      onDismissed: ((direction) => {
            _markAsDeleted(context, id!),
          }),
      child: InkWell(
        onTap: () {
          // Navigate to task details screen
          Navigator.of(context)
              .pushNamed(TaskDetailScreen.routeName, arguments: id);
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          color: isDeleted!
              ? const Color.fromARGB(255, 255, 219, 219)
              : isDone!
                  ? const Color.fromARGB(255, 231, 254, 225)
                  : const Color.fromARGB(255, 255, 252, 219),
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

  IconData? _prorityIcon(String priority) {
    return priority == "Important"
        ? Icons.priority_high
        : priority == "Necessary"
            ? Icons.warning
            : priority == "Casual"
                ? Icons.low_priority_sharp
                : Icons.question_mark;
  }

  Color? _priorityIconColor(String priority) {
    return priority == "Important"
        ? Colors.red
        : priority == "Necessary"
            ? Colors.orange
            : priority == "Casual"
                ? Colors.green
                : Colors.black;
  }
}
