import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

import '../../database/database_helper.dart';
import '../../models/task.dart';
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
  final _formKey = GlobalKey<FormState>();
  String? _taskTitle;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  TaskAdress? _pickedAdress;
  Priority? _priority;

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.day,
      locale: const Locale('en', 'US'),
    ).then((pickedDate) => {
          if (pickedDate != null)
            {
              setState(() => _selectedDate = pickedDate),
            }
        });
  }

  void _presentTimePicker() {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ).then((pickedTime) => {
          if (pickedTime != null)
            {
              setState(() => _selectedTime = pickedTime),
            }
        });
  }

  void _selectPlace(double lat, double lng) {
    _pickedAdress = TaskAdress(latitude: lat, longitude: lng);
  }

  void _displayDialogForNotPickDate() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Notification"),
            content: const Text('Please select a due date'),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  String _displayTime(TimeOfDay? selectedTime) {
    if (_selectedTime == null) {
      return 'No due time chosen';
    }
    String hour = _selectedTime!.hour < 10
        ? '0${_selectedTime!.hour}'
        : '${_selectedTime!.hour}';
    String minute = _selectedTime!.minute < 10
        ? '0${_selectedTime!.minute}'
        : '${_selectedTime!.minute}';
    String period = _selectedTime!.period == DayPeriod.am ? 'AM' : 'PM';
    return 'Due time: $hour:$minute $period';
  }

  String _displayDate(DateTime? selectedDate) {
    if (_selectedDate == null) {
      return 'No due date chosen';
    }
    String day = _selectedDate!.day < 10
        ? '0${_selectedDate!.day}'
        : '${_selectedDate!.day}';
    String month = _selectedDate!.month < 10
        ? '0${_selectedDate!.month}'
        : '${_selectedDate!.month}';
    String year = '${_selectedDate!.year}';
    return 'Due date: $day/$month/$year';
  }

  void _addTask() {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();

      //check if the user picked a due date
      if (_selectedDate == null) {
        //show an alert dialog to the user if the due date is not selected
        _displayDialogForNotPickDate();
      } else {
        //add the task in the database
        DBHelper.addTask(
            _taskTitle, _selectedDate, _selectedTime, _pickedAdress, _priority);

        //add the task in the UI
        Provider.of<Tasks>(context, listen: false).addTask(
          _taskTitle,
          _selectedDate,
          _selectedTime,
          _pickedAdress,
          _priority,
        );

        // close the screen
        Navigator.of(context).pop();
      }
    }
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
            Form(
              key: _formKey,
              child: Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        //title field
                        FormBuilderTextField(
                          name: 'title',
                          decoration: const InputDecoration(labelText: 'Title'),
                          validator: FormBuilderValidators.required(
                              errorText: 'Required'),
                          onSaved: (value) {
                            _taskTitle = value;
                          },
                        ),
                        const SizedBox(height: 10),
                        //due date field
                        Row(
                          children: [
                            Expanded(
                              child: Text(_displayDate(_selectedDate)),
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
                        //due time field
                        Row(
                          children: [
                            Expanded(
                              child: Text(_displayTime(_selectedTime)),
                            ),
                            const Icon(Icons.access_time),
                            TextButton(
                              onPressed: _presentTimePicker,
                              child: const Text(
                                'Choose time',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        //adress field
                        const SizedBox(height: 10),
                        LocationInput(
                          onSelectPlace: _selectPlace,
                        ),
                        const SizedBox(height: 10),
                        //priority field
                        DropdownButtonFormField<Priority>(
                          icon: const Icon(Icons.arrow_drop_down),
                          value: _priority,
                          items: const [
                            DropdownMenuItem(
                              value: Priority.casual,
                              child: Text('Casual'),
                            ),
                            DropdownMenuItem(
                              value: Priority.necessary,
                              child: Text('Neccessary'),
                            ),
                            DropdownMenuItem(
                              value: Priority.important,
                              child: Text('Important'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _priority = value;
                            });
                          },
                          hint: const Text('Select priority'),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ElevatedButton.icon(
                onPressed: _addTask,
                icon: const Icon(Icons.add_circle_outline),
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
