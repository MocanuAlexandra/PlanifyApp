import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../database/database_helper.dart';
import '../../models/task_adress.dart';
import '../../providers/tasks.dart';
import '../../widgets/location/location_input.dart';

class AddNewTaskScreen extends StatefulWidget {
  const AddNewTaskScreen({super.key});

  static const routeName = '/add-task';

  @override
  State<AddNewTaskScreen> createState() => _AddNewTaskScreenState();
}

class _AddNewTaskScreenState extends State<AddNewTaskScreen> {
  String _taskTitle = '';
  DateTime? _selectedDate;
  TaskAdress? _pickedAdress;

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    ).then((pickedDate) => {
          if (pickedDate != null)
            {
              setState(() => _selectedDate = pickedDate),
            }
        });
  }

  void _selectPlace(double lat, double lng) {
    _pickedAdress = TaskAdress(latitude: lat, longitude: lng);
  }

  void _addTask() {
    FocusScope.of(context).unfocus();

    //add the task in the database
    DBHelper.addTask(_taskTitle, _selectedDate, _pickedAdress);

    //add the task in the UI
    Provider.of<Tasks>(context, listen: false).addTask(
      _taskTitle,
      _selectedDate,
      _pickedAdress,
    );

    // close the screen
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add a new task'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    // ignore: prefer_const_literals_to_create_immutables
                    children: [
                      //title field
                      TextField(
                        decoration: const InputDecoration(labelText: 'Title'),
                        onChanged: (value) {
                          _taskTitle = value;
                        },
                      ),
                      const SizedBox(height: 10),
                      //due date
                      Row(
                        // ignore: prefer_const_literals_to_create_immutables
                        children: [
                          Expanded(
                            child: Text(
                              _selectedDate == null
                                  ? 'No due date chosen'
                                  : 'Due date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                            ),
                          ),
                          const Icon(Icons.calendar_month),
                          TextButton(
                            onPressed: _presentDatePicker,
                            child: const Text(
                              'Choose date',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      //adress
                      const SizedBox(height: 10),
                      LocationInput(
                        onSelectPlace: _selectPlace,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ElevatedButton.icon(
                onPressed: _addTask,
                icon: const Icon(Icons.add),
                label: const Text('Add Task'),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                )),
          ],
        ));
  }
}
