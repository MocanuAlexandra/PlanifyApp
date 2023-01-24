import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

import '../../screens/agenda/overall_agenda_screen.dart';
import '../../database/database_helper.dart';
import '../../models/task.dart';
import '../../models/task_adress.dart';
import '../../providers/tasks.dart';
import '../location/location_input.dart';

class AddEditTaskForm extends StatefulWidget {
  const AddEditTaskForm({super.key});

  static const routeName = '/add-task';

  @override
  State<AddEditTaskForm> createState() => _AddEditTaskFormState();
}

class _AddEditTaskFormState extends State<AddEditTaskForm> {
  final _formKey = GlobalKey<FormState>();
  var _editedTask = Task(
    id: null,
    title: '',
    dueDate: null,
    address: null,
    time: null,
    priority: null,
    isDone: false,
  );
  var _initValues = {
    'title': '',
    'dueDate': null,
    'address': null,
    'time': null,
    'priority': null,
    'isDone': false,
  };

  var _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final taskId = ModalRoute.of(context)!.settings.arguments as String?;

      if (taskId != null) {
        _editedTask =
            Provider.of<Tasks>(context, listen: false).findById(taskId);
        _initValues = {
          'title': _editedTask.title,
          'dueDate': _editedTask.dueDate,
          'address': _editedTask.address,
          'time': _editedTask.time,
          'priority': _editedTask.priority,
          'isDone': _editedTask.isDone,
        };
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  //all the fields
  FormBuilderTextField titleField() {
    return FormBuilderTextField(
      name: 'title',
      initialValue: _initValues['title'].toString(),
      decoration: const InputDecoration(
        labelText: 'Title',
        labelStyle: TextStyle(
          fontSize: 16,
        ),
      ),
      validator: FormBuilderValidators.required(errorText: 'Required'),
      onSaved: (value) {
        _editedTask = Task(
          id: _editedTask.id,
          title: value.toString(),
          dueDate: _editedTask.dueDate,
          address: _editedTask.address,
          time: _editedTask.time,
          priority: _editedTask.priority,
          isDone: _editedTask.isDone,
        );
      },
    );
  }

  Row dueDateField() {
    return Row(
      children: [
        Expanded(
          child: Text(
            _displayDate(_editedTask.dueDate),
            style: const TextStyle(fontSize: 16),
          ),
        ),
        const Icon(Icons.calendar_month),
        TextButton(
          onPressed: _presentDatePicker,
          child: const Text(
            'Choose date',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  Row dueTimeField() {
    return Row(
      children: [
        Expanded(
          child: Text(
            _displayTime(_editedTask.time),
            style: const TextStyle(fontSize: 16),
          ),
        ),
        const Icon(Icons.access_time),
        TextButton(
          onPressed: _presentTimePicker,
          child: const Text(
            'Choose time',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  LocationInput locationField() {
    return LocationInput(
      previousAdress: _editedTask.address,
      onSelectPlace: _selectPlace,
    );
  }

  DropdownButtonFormField<Priority> priorityField() {
    return DropdownButtonFormField<Priority>(
      icon: const Icon(Icons.arrow_drop_down),
      value: _editedTask.priority,
      items: const [
        DropdownMenuItem(
          value: Priority.casual,
          child: Text(
            'Casual',
            style: TextStyle(fontSize: 16),
          ),
        ),
        DropdownMenuItem(
          value: Priority.necessary,
          child: Text(
            'Neccessary',
            style: TextStyle(fontSize: 16),
          ),
        ),
        DropdownMenuItem(
          value: Priority.important,
          child: Text(
            'Important',
            style: TextStyle(fontSize: 16),
          ),
        ),
        DropdownMenuItem(
          value: Priority.unknown,
          child: Text(
            'Unknown',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _editedTask = Task(
            id: _editedTask.id,
            title: _editedTask.title,
            dueDate: _editedTask.dueDate,
            address: _editedTask.address,
            time: _editedTask.time,
            priority: value,
            isDone: _editedTask.isDone,
          );
        });
      },
      hint: const Text(
        'Select priority',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  //main method
  void _addEditTask() {
    //check for validation of the form
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();

      // if we got an id, it means that we are editing a task
      if (_editedTask.id != null) {
        //update the task in the database
        DBHelper.updateTask(_editedTask.id!, _editedTask);

        // go back to overall agenda screen
        Navigator.of(context).popAndPushNamed(OverallAgendaScreen.routeName);
      }
      // if we didn't get an id, it means that we are adding a new task
      else {
        if (_editedTask.dueDate == null) {
          //show an alert dialog to the user if the due date is not selected
          _displayDialogForNotPickDate();
        } else {
          //add the task in the database
          DBHelper.addTask(_editedTask);

          // close the screen
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: _editedTask.id == null
              ? const Text('Add new task')
              : const Text('Edit task'),
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
                        titleField(),
                        const SizedBox(height: 10),
                        dueDateField(),
                        dueTimeField(),
                        locationField(),
                        const SizedBox(height: 10),
                        priorityField(),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            //submit button
            ElevatedButton(
                onPressed: _addEditTask,
                style: ElevatedButton.styleFrom(
                  elevation: 5,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(fontSize: 18),
                )),
          ],
        ));
  }

  //auxiliary functions
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
              setState(() {
                _editedTask = Task(
                  id: _editedTask.id,
                  title: _editedTask.title,
                  dueDate: pickedDate,
                  address: _editedTask.address,
                  time: _editedTask.time,
                  priority: _editedTask.priority,
                  isDone: _editedTask.isDone,
                );
              }),
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
              setState(() {
                _editedTask = Task(
                  id: _editedTask.id,
                  title: _editedTask.title,
                  dueDate: _editedTask.dueDate,
                  address: _editedTask.address,
                  time: pickedTime,
                  priority: _editedTask.priority,
                  isDone: _editedTask.isDone,
                );
              }),
            }
        });
  }

  void _selectPlace(double? lat, double? lng) {
    _editedTask = Task(
      id: _editedTask.id,
      title: _editedTask.title,
      dueDate: _editedTask.dueDate,
      address: TaskAdress(latitude: lat, longitude: lng),
      time: _editedTask.time,
      priority: _editedTask.priority,
      isDone: _editedTask.isDone,
    );
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
    if (_editedTask.time == null) {
      return 'No due time chosen';
    }
    String hour = _editedTask.time!.hour < 10
        ? '0${_editedTask.time!.hour}'
        : '${_editedTask.time!.hour}';
    String minute = _editedTask.time!.minute < 10
        ? '0${_editedTask.time!.minute}'
        : '${_editedTask.time!.minute}';
    String period = _editedTask.time!.period == DayPeriod.am ? 'AM' : 'PM';
    return 'Due time: $hour:$minute $period';
  }

  String _displayDate(DateTime? selectedDate) {
    if (_editedTask.dueDate == null) {
      return 'No due date chosen';
    }
    String day = _editedTask.dueDate!.day < 10
        ? '0${_editedTask.dueDate!.day}'
        : '${_editedTask.dueDate!.day}';
    String month = _editedTask.dueDate!.month < 10
        ? '0${_editedTask.dueDate!.month}'
        : '${_editedTask.dueDate!.month}';
    String year = '${_editedTask.dueDate!.year}';
    return 'Due date: $day/$month/$year';
  }
}
