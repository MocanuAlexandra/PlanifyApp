import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planify_app/models/task_adress.dart';

class TaskListItem extends StatelessWidget {
  final String? id;
  final String? title;
  final DateTime? dueDate;
  final TaskAdress? address;

  const TaskListItem({
    super.key,
    required this.id,
    this.title,
    this.dueDate,
    this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      background: Container(
        color: Theme.of(context).errorColor,
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
        return showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('Question'),
                  content: const Text('Do you want to remove the task?'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: const Text('No')),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: const Text('Yes')),
                  ],
                ));
      },
      onDismissed: ((direction) => {}),
      child: InkWell(
        onTap: () {},
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 4,
          margin: const EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              // title
              ListTile(
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
                    IconButton(
                      icon: const Icon(
                        Icons.check,
                        color: Colors.green,
                      ),
                      onPressed: () {
                        // Mark task as done
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        // Delete task
                      },
                    ),
                  ],
                ),
              ),
              // more infos
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    //due date
                    Row(children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(
                        width: 6,
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy').format(dueDate!),
                      ),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
