import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:planify_app/providers/reminders.dart';
import 'package:provider/provider.dart';

import '../../helpers/utility.dart';
import '../../helpers/notification_helper.dart';
import '../../models/task_reminder.dart';
import '../../providers/categories.dart';
import '../../models/category.dart';
import '../../widgets/helpers/check_box.dart';
import '../agenda/overall_agenda_screen.dart';
import '../../database/database_helper.dart';
import '../../models/task.dart';
import '../../models/task_address.dart';
import '../../providers/tasks.dart';
import '../../widgets/location/location_input.dart';

class AddEditTaskScreen extends StatefulWidget {
  const AddEditTaskScreen({super.key});

  static const routeName = '/add-task';

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  var _editedTask = Task(
    id: null,
    title: '',
    dueDate: null,
    address: null,
    time: null,
    priority: null,
    isDone: false,
    isDeleted: false,
    category: null,
  );
  var _initValues = {
    'title': '',
    'dueDate': null,
    'address': null,
    'time': null,
    'priority': null,
    'isDone': false,
    'isDeleted': false,
    'category': null,
  };

  var _isInit = true;
  List<String> _selectedReminders = [];

  @override
  void didChangeDependencies() async {
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
          'isDeleted': _editedTask.isDeleted,
          'category': _editedTask.category,
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
          category: _editedTask.category,
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
        TextButton.icon(
          onPressed: _presentDatePicker,
          icon: const Icon(Icons.calendar_month),
          label: const Text(
            'Choose date',
            style: TextStyle(fontSize: 15),
          ),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).primaryColor,
          ),
        ),
        //delete selected date
        IconButton(
            onPressed: () {
              setState(() {
                _editedTask = Task(
                  id: _editedTask.id,
                  title: _editedTask.title,
                  dueDate: null,
                  address: _editedTask.address,
                  time: _editedTask.time,
                  priority: _editedTask.priority,
                  isDone: _editedTask.isDone,
                  category: _editedTask.category,
                );
              });
            },
            icon: const Icon(Icons.delete))
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
        TextButton.icon(
          onPressed: _presentTimePicker,
          icon: const Icon(Icons.access_time),
          label: const Text(
            'Choose time',
            style: TextStyle(fontSize: 15),
          ),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).primaryColor,
          ),
        ),
        //delete selected time
        IconButton(
            onPressed: () {
              setState(() {
                _editedTask = Task(
                  id: _editedTask.id,
                  title: _editedTask.title,
                  dueDate: _editedTask.dueDate,
                  address: _editedTask.address,
                  time: null,
                  priority: _editedTask.priority,
                  isDone: _editedTask.isDone,
                  category: _editedTask.category,
                );
              });
            },
            icon: const Icon(Icons.delete))
      ],
    );
  }

  LocationInput locationField() {
    return LocationInput(
      previousAddress: _editedTask.address,
      onSelectPlace: _selectPlace,
    );
  }

  Row remindersField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton.icon(
          onPressed: _editedTask.time == null && _editedTask.dueDate == null
              ? () => Utility.displayInformationalDialog(
                  context, 'Please select due date or due time first!')
              : _editedTask.time == null && _editedTask.dueDate != null
                  ? () async {
                      final result = await showDialog(
                        context: context,
                        builder: (context) => _showReminderPicker(false, true),
                      );
                      if (result != null) {
                        setState(() {
                          _selectedReminders = result;
                        });
                      }
                    }
                  : _editedTask.time != null && _editedTask.dueDate == null
                      ? () async {
                          final result = await showDialog(
                            context: context,
                            builder: (context) =>
                                _showReminderPicker(true, false),
                          );
                          if (result != null) {
                            setState(() {
                              _selectedReminders = result;
                            });
                          }
                        }
                      : () async {
                          final result = await showDialog(
                            context: context,
                            builder: (context) =>
                                _showReminderPicker(true, true),
                          );
                          if (result != null) {
                            setState(() {
                              _selectedReminders = result;
                            });
                          }
                        },
          icon: const Icon(Icons.access_alarm),
          label: const Text(
            'Set reminder',
            style: TextStyle(fontSize: 15),
          ),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _showReminderPicker(
      [bool? isDueTimeSelected, bool? isDueDateSelected]) {
    return _editedTask.id != null
        ? FutureBuilder(
            future: _fetchReminders(context, _editedTask.id!),
            builder: (context, snapshot) => snapshot.connectionState ==
                    ConnectionState.waiting
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Consumer<TaskReminders>(
                    builder: (context, reminders, ch) => CheckboxList(
                          items: Utility.getReminderTypes(
                              isDueTimeSelected, isDueDateSelected),
                          selectedItems: determineAlreadySelectedReminders(
                              reminders, isDueTimeSelected, isDueDateSelected),
                        )),
          )
        : CheckboxList(
            items:
                Utility.getReminderTypes(isDueTimeSelected, isDueDateSelected),
            selectedItems: _selectedReminders);
  }

  List<String> determineAlreadySelectedReminders(TaskReminders reminders,
      bool? isDueTimeSelected, bool? isDueDateSelected) {
    List<String> reminderTypes =
        Utility.getReminderTypes(isDueTimeSelected, isDueDateSelected);
    List<TaskReminder> alreadySelectedReminders = reminders.remindersList;

    for (var reminderType in reminderTypes) {
      if (alreadySelectedReminders
          .any((element) => element.reminder == reminderType)) {
        _selectedReminders.add(reminderType);
      }
    }

    return _selectedReminders;
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
            'Necessary',
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
            category: _editedTask.category,
          );
        });
      },
      hint: const Text(
        'Select priority',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  FutureBuilder<void> categoryField(BuildContext context) {
    return FutureBuilder(
      future: _fetchCategories(context),
      builder: (context, snapshot) =>
          snapshot.connectionState == ConnectionState.waiting
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : DropdownButtonFormField<String>(
                  value: _editedTask.category,
                  onChanged: (String? value) {
                    setState(() {
                      _editedTask = Task(
                        id: _editedTask.id,
                        title: _editedTask.title,
                        dueDate: _editedTask.dueDate,
                        address: _editedTask.address,
                        time: _editedTask.time,
                        priority: _editedTask.priority,
                        isDone: _editedTask.isDone,
                        category: value,
                      );
                    });
                  },
                  items: Provider.of<Categories>(context)
                      .categoriesList
                      .map<DropdownMenuItem<String>>((Category category) {
                    return DropdownMenuItem<String>(
                      value: category.name,
                      child: Text(category.name!),
                    );
                  }).toList(),
                  hint: const Text(
                    'Select category',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
    );
  }

  //main method
  void _addEditTask() async {
    //check for validation of the form
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();

      // if we got an id, it means that we are editing a task
      if (_editedTask.id != null) {
        if (_editedTask.isDone == true) {
          //show an alert dialog to the user if the task is done
          //we ask the user if he wants to move the tasks to 'in progress' tasks
          //and we update the task in the database accordingly
          _displayDialogForDoneTask();
        } else {
          //update the task in the database
          DBHelper.updateTask(_editedTask.id!, _editedTask);

          //delete the notifications for the task
          deleteNotificationsForTask(_editedTask.id!);

          //update the notifications for the task
          addNotificationsForTask(_editedTask.id!);

          // go back to overall agenda screen
          Navigator.of(context)
              .pushReplacementNamed(OverallAgendaScreen.routeName);
        }
      }
      // if we didn't get an id, it means that we are adding a new task
      else {
        //add the task in the database
        final taskId = await DBHelper.addTask(_editedTask);

        //create a notifications for the task
        addNotificationsForTask(taskId);

        // go back to overall agenda screen
        // ignore: use_build_context_synchronously
        Navigator.of(context)
            .pushReplacementNamed(OverallAgendaScreen.routeName);
      }
    }
  }

  //auxiliary methods

  void deleteNotificationsForTask(String taskId) {
    //delete the notifications for the task from the notification center
    DBHelper.deleteNotificationsForTask(taskId);

    //delete the notifications for the task from the database
    NotificationHelper.deleteNotification(taskId);
  }

  void addNotificationsForTask(String taskId) {
    //parse the selected reminders and create a notification for each one
    if (_selectedReminders.isNotEmpty) {
      for (String reminder in _selectedReminders) {
        TaskReminder newReminder;
        //check if the user selected only due date
        if (_editedTask.dueDate != null && _editedTask.time == null) {
          newReminder = TaskReminder(
            contentId: taskId.hashCode +
                _editedTask.dueDate!.day +
                _editedTask.dueDate!.month +
                _editedTask.dueDate!.year +
                reminder.hashCode,
            reminder: reminder,
          );
        }
        //check if the user selected only time
        else if (_editedTask.dueDate == null && _editedTask.time != null) {
          newReminder = TaskReminder(
            contentId: taskId.hashCode +
                _editedTask.time!.hour +
                _editedTask.time!.minute +
                reminder.hashCode,
            reminder: reminder,
          );
          //else it means that the user selected both due date and time
        } else {
          newReminder = TaskReminder(
            contentId: taskId.hashCode +
                _editedTask.dueDate!.day +
                _editedTask.dueDate!.month +
                _editedTask.dueDate!.year +
                _editedTask.time!.hour +
                _editedTask.time!.minute +
                reminder.hashCode,
            reminder: reminder,
          );
        }

        //add the notification to database
        DBHelper.addReminder(taskId, newReminder);

        //add the notification to system
        NotificationHelper.createNotification(
            context, _editedTask, reminder, newReminder, taskId);
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      titleField(),
                      const SizedBox(height: 10),
                      dueDateField(),
                      dueTimeField(),
                      remindersField(),
                      locationField(),
                      const SizedBox(height: 10),
                      priorityField(),
                      const SizedBox(height: 10),
                      categoryField(context),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.only(top: 70),
                        child: ElevatedButton(
                            onPressed: _addEditTask,
                            style: ElevatedButton.styleFrom(
                              elevation: 5,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                            ),
                            child: const Text(
                              'Submit',
                              style: TextStyle(fontSize: 18),
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  //auxiliary functions
  Future<void> _fetchCategories(BuildContext context) async {
    await Provider.of<Categories>(context, listen: false).fetchCategories();
  }

  Future<void> _fetchReminders(BuildContext context, String taskId) async {
    await Provider.of<TaskReminders>(context, listen: false)
        .fetchReminders(taskId);
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate:
          _editedTask.dueDate != null ? _editedTask.dueDate! : DateTime.now(),
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
                  isDeleted: _editedTask.isDeleted,
                  category: _editedTask.category,
                );
              }),
            }
        });
  }

  void _presentTimePicker() {
    showTimePicker(
      context: context,
      initialTime:
          _editedTask.time != null ? _editedTask.time! : TimeOfDay.now(),
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
                  isDeleted: _editedTask.isDeleted,
                  category: _editedTask.category,
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
      address: TaskAddress(latitude: lat, longitude: lng),
      time: _editedTask.time,
      priority: _editedTask.priority,
      isDone: _editedTask.isDone,
      isDeleted: _editedTask.isDeleted,
      category: _editedTask.category,
    );
  }

  void _displayDialogForDoneTask() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Question"),
            content: const Text(
                'This task is done. Do you want to move it to "In progress" tasks?'),
            actions: <Widget>[
              TextButton(
                child: const Text("Yes"),
                onPressed: () {
                  // change the task to not done
                  _editedTask = Task(
                    id: _editedTask.id,
                    title: _editedTask.title,
                    dueDate: _editedTask.dueDate,
                    address: _editedTask.address,
                    time: _editedTask.time,
                    priority: _editedTask.priority,
                    isDone: false,
                    isDeleted: _editedTask.isDeleted,
                    category: _editedTask.category,
                  );

                  //update the task in the database
                  DBHelper.updateTask(_editedTask.id!, _editedTask);

                  // go back to overall agenda screen
                  Navigator.of(context)
                      .popAndPushNamed(OverallAgendaScreen.routeName);
                },
              ),
              TextButton(
                child: const Text("No"),
                onPressed: () {
                  // change the task to done
                  _editedTask = Task(
                    id: _editedTask.id,
                    title: _editedTask.title,
                    dueDate: _editedTask.dueDate,
                    address: _editedTask.address,
                    time: _editedTask.time,
                    priority: _editedTask.priority,
                    isDone: true,
                    isDeleted: _editedTask.isDeleted,
                    category: _editedTask.category,
                  );

                  //update the task in the database
                  DBHelper.updateTask(_editedTask.id!, _editedTask);

                  // go back to overall agenda screen
                  Navigator.of(context)
                      .popAndPushNamed(OverallAgendaScreen.routeName);
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
