import 'dart:io';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../models/task.dart';
import '../../services/task_service.dart';
import '../../widgets/other/image/user_image_picker.dart';
import '../../widgets/other/user_list_search.dart';
import '../../services/database_helper_service.dart';
import '../../helpers/utility.dart';
import '../../models/task_category.dart';
import '../../models/task.dart' as task_model;
import '../../models/task_address.dart';
import '../../models/task_reminder.dart';
import '../../providers/task_category_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/task_reminder_provider.dart';
import '../../widgets/location/location_input.dart';
import '../../widgets/other/check_box_list.dart';
import '../pages/overall_agenda_page.dart';

class AddEditTaskScreen extends StatefulWidget {
  const AddEditTaskScreen({super.key});

  static const routeName = '/add-task';

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final ScrollController _controller = ScrollController();
  final _formKey = GlobalKey<FormState>();
  var _editedTask = task_model.Task(
    id: null,
    title: '',
    dueDate: null,
    address: null,
    dueTime: null,
    priority: null,
    isDone: false,
    isDeleted: false,
    category: null,
    locationCategory: null,
    owner: null,
    imageUrl: null,
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
    'locationCategory': null,
    'owner': null,
    'imageUrl': null,
  };

  var _isInit = true;
  bool _isLoading = false;
  List<String> _selectedReminders = [];
  bool _dueTimeDueDateChanged = false;
  List<String> _selectedUserEmails = [];
  bool _sharedUsersChanged = false;
  File? _pickedImageFile;
  bool isImageDeleted = false;

  void _pickedImage(File? image, bool isDeleted) {
    _pickedImageFile = image;
    isImageDeleted = isDeleted;
  }

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      final taskId = ModalRoute.of(context)!.settings.arguments as String?;

      if (taskId != null) {
        _editedTask =
            Provider.of<TaskProvider>(context, listen: false).findById(taskId);
        _initValues = {
          'title': _editedTask.title,
          'dueDate': _editedTask.dueDate,
          'address': _editedTask.address,
          'time': _editedTask.dueTime,
          'priority': _editedTask.priority,
          'isDone': _editedTask.isDone,
          'isDeleted': _editedTask.isDeleted,
          'category': _editedTask.category,
          'locationCategory': _editedTask.locationCategory,
          'owner': _editedTask.owner,
          'imageUrl': _editedTask.imageUrl,
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
        _editedTask.title = value.toString();
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
                foregroundColor: Theme.of(context).colorScheme.secondary,
                iconColor: Theme.of(context).colorScheme.primary)),
        //delete selected date
        IconButton(
            onPressed: () async {
              setState(() {
                _editedTask.dueDate = null;
              });
              _dueTimeDueDateChanged = true;

              if (await DBHelper.checkForReminders(_editedTask.id!)) {
                Utility.displayInformationalDialog(context,
                    'The previous reminders were deleted because the due date was deleted.');
                setState(() {
                  _selectedReminders = [];
                });
              }
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
            _displayTime(_editedTask.dueTime),
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
                foregroundColor: Theme.of(context).colorScheme.secondary,
                iconColor: Theme.of(context).colorScheme.primary)),
        //delete selected time
        IconButton(
            onPressed: () async {
              setState(() {
                _editedTask.dueTime = null;
              });
              _dueTimeDueDateChanged = true;

              if (await DBHelper.checkForReminders(_editedTask.id!)) {
                Utility.displayInformationalDialog(context,
                    'The previous reminders were deleted because the due time was deleted.');
                setState(() {
                  _selectedReminders = [];
                });
              }
            },
            icon: const Icon(Icons.delete))
      ],
    );
  }

  LocationInput locationField() {
    return LocationInput(
      previousAddress: _editedTask.address,
      previousLocationCategory: _editedTask.locationCategory,
      onSelectPlace: _selectPlace,
      onSelectCategory: _selectCategory,
    );
  }

  Widget _showReminderPicker(
      [bool? isDueTimeSelected, bool? isDueDateSelected]) {
    return _editedTask.id != null && _dueTimeDueDateChanged == true
        ? CheckboxList(
            items:
                Utility.getReminderTypes(isDueTimeSelected, isDueDateSelected),
            selectedItems: _selectedReminders,
            title: 'Select reminders',
          )
        : _editedTask.id != null && _dueTimeDueDateChanged == false
            ? FutureBuilder(
                future:
                    //fetch the reminders accordingly to logged user
                    _editedTask.owner == DBHelper.currentUserId()
                        ? _fetchReminders(context, _editedTask.id!)
                        : _fetchRemindersForSharedTasks(
                            context, _editedTask.id!),
                builder: (context, snapshot) => snapshot.connectionState ==
                        ConnectionState.waiting
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Consumer<TaskReminderProvider>(
                        builder: (context, reminders, _) => CheckboxList(
                          items: Utility.getReminderTypes(
                              isDueTimeSelected, isDueDateSelected),
                          selectedItems: determineAlreadySelectedReminders(
                              reminders, isDueTimeSelected, isDueDateSelected),
                          title: 'Select reminders',
                        ),
                      ),
              )
            : CheckboxList(
                items: Utility.getReminderTypes(
                    isDueTimeSelected, isDueDateSelected),
                selectedItems: _selectedReminders,
                title: 'Select reminders',
              );
  }

  List<String> determineAlreadySelectedReminders(TaskReminderProvider reminders,
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
          _editedTask.priority = value;
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
                      _editedTask.category = value;
                    });
                  },
                  items: Provider.of<TaskCategoryProvider>(context)
                      .categoriesList
                      .map<DropdownMenuItem<String>>((TaskCategory category) {
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

  Row reminderAndShareWithField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton.icon(
            onPressed: _editedTask.dueTime == null &&
                    _editedTask.dueDate == null
                ? () => Utility.displayInformationalDialog(
                    context, 'Please select due date or due time first!')
                : _editedTask.dueTime == null && _editedTask.dueDate != null
                    ? () async {
                        final result = await showDialog(
                          context: context,
                          builder: (context) =>
                              _showReminderPicker(false, true),
                        );
                        if (result != null) {
                          setState(() {
                            _selectedReminders = result;
                          });
                        }
                      }
                    : _editedTask.dueTime != null && _editedTask.dueDate == null
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
                foregroundColor: Theme.of(context).colorScheme.secondary,
                iconColor: Theme.of(context).colorScheme.primary)),
        //only owner can share the task
        if (_editedTask.owner == DBHelper.currentUserId() ||
            _editedTask.owner == null)
          TextButton.icon(
              onPressed: _editedTask.id == null
                  // if task is not saved yet, then we don't need to check already selected users emails
                  ? () async {
                      await showDialog(
                        context: context,
                        builder: (context) => UserListSearch(
                          checkedItems: _selectedUserEmails,
                        ),
                      );
                      _sharedUsersChanged = true;
                    }
                  // if task is saved, then we need to check already selected users emails
                  : () async {
                      _selectedUserEmails =
                          await TaskService.determineAlreadySharedWithUsers(
                              _editedTask.id);
                      await showDialog(
                        context: context,
                        builder: (context) => UserListSearch(
                          checkedItems: _selectedUserEmails,
                        ),
                      );
                      _sharedUsersChanged = true;
                    },
              icon: const Icon(Icons.share),
              label: const Text(
                'Share with',
                style: TextStyle(fontSize: 15),
              ),
              style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.secondary,
                  iconColor: Theme.of(context).colorScheme.primary)),
      ],
    );
  }

  //main method
  Future<void> _addEditTask() async {
    //check for validation of the form
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    NavigatorState navigator = Navigator.of(context);

    if (isValid) {
      // save the form
      _formKey.currentState!.save();

      // if we got an id, it means that we are editing a task
      if (_editedTask.id != null) {
        if (_editedTask.isDone == true) {
          // show an alert dialog to the user if the task is done
          // we ask the user if he wants to move the tasks to 'in progress' tasks
          // and we update the task in the database accordingly
          await editDoneTask();
        } else {
          setState(() {
            _isLoading = true;
          });
          //check if user choose others to shared with, if not, add the same list of shared users
          if (!_sharedUsersChanged) {
            _selectedUserEmails =
                await TaskService.determineAlreadySharedWithUsers(
                    _editedTask.id, _editedTask.owner);
          }

          //if the task is not done, we update the task in the database normally
          await TaskService.editTask(_editedTask, _pickedImageFile,
              isImageDeleted, _selectedUserEmails, _selectedReminders);

          // go back to overall agenda screen
          navigator.popAndPushNamed(OverallAgendaPage.routeName);
        }
      }

      // if we didn't get an id, it means that we are adding a new task
      else {
        // we first verify if the task is labeled as "appointment" and doesn't have
        // a due date and due time
        if (TaskService.isAppointment(_editedTask)) {
          Utility.displayInformationalDialog(context,
              'This is an appointment! Please select due date and due time!');
        }

        //check if the task is labeled as "exam" and doesn't have
        // a due date and due time
        else if (TaskService.isExam(_editedTask)) {
          Utility.displayInformationalDialog(context,
              'This is an important test! Please select due date and due time!');
        }

        //check if the task is labeled as "meeting" and doesn't have
        // a due date and due time
        else if (TaskService.isMeeting(_editedTask)) {
          Utility.displayInformationalDialog(context,
              'This is a meeting! Please select due date and due time!');
        }

        //check if the task is labeled as "interview" and doesn't have
        // a due date and due time
        else if (TaskService.isInterview(_editedTask)) {
          Utility.displayInformationalDialog(context,
              'This is an interview! Please select due date and due time!');
        }

        // if there is no case, add the task normally
        else {
          setState(() {
            _isLoading = true;
          });
          //check if user choose others to shared with, if not, add the same list of shared users
          if (!_sharedUsersChanged) {
            _selectedUserEmails =
                await TaskService.determineAlreadySharedWithUsers(
                    _editedTask.id);
          }

          //add the task to the database
          await TaskService.addTask(_editedTask, _pickedImageFile,
              isImageDeleted, _selectedUserEmails, _selectedReminders);

          // go back to overall agenda screen
          navigator.popAndPushNamed(OverallAgendaPage.routeName);
        }
      }
    }
  }

  @override
  build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final buttonHeight = screenHeight * 0.08;

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
              child: Scrollbar(
                controller: _controller,
                thumbVisibility: true,
                thickness: 5,
                child: SingleChildScrollView(
                  controller: _controller,
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
                        UserImagePicker(
                          imagePickFn: _pickedImage,
                          previousImageUrl: _editedTask.imageUrl,
                        ),
                        const SizedBox(height: 10),
                        locationField(),
                        const SizedBox(height: 10),
                        _editedTask.owner == DBHelper.currentUserId() ||
                                _editedTask.owner == null
                            ? priorityField()
                            : const SizedBox(height: 1),
                        _editedTask.owner == DBHelper.currentUserId() ||
                                _editedTask.owner == null
                            ? const SizedBox(height: 10)
                            : const SizedBox(height: 1),
                        _editedTask.owner == DBHelper.currentUserId() ||
                                _editedTask.owner == null
                            ? categoryField(context)
                            : const SizedBox(height: 1),
                        _editedTask.owner == DBHelper.currentUserId() ||
                                _editedTask.owner == null
                            ? const SizedBox(height: 10)
                            : const SizedBox(height: 1),
                        reminderAndShareWithField(),
                        const SizedBox(height: 5),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: buttonHeight,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 15),
              child: ElevatedButton(
                  onPressed: _addEditTask,
                  style: ElevatedButton.styleFrom(
                    elevation: 5,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  child: (_isLoading)
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 1.7,
                          ))
                      : const Text(
                          'Submit',
                          style: TextStyle(fontSize: 18),
                        )),
            ),
          ),
        ],
      ),
    );
  }

  //auxiliary functions
  Future<void> _fetchCategories(BuildContext context) async {
    await Provider.of<TaskCategoryProvider>(context, listen: false)
        .fetchCategories();
  }

  Future<void> _fetchReminders(BuildContext context, String taskId) async {
    await Provider.of<TaskReminderProvider>(context, listen: false)
        .fetchReminders(taskId);
  }

  Future<void> _fetchRemindersForSharedTasks(
      BuildContext context, String taskId) async {
    await Provider.of<TaskReminderProvider>(context, listen: false)
        .fetchRemindersForSharedTask(taskId);
  }

  void _presentDatePicker() {
    DateTime currentDate = DateTime.now();

    if (_editedTask.dueDate != null &&
        _editedTask.dueDate!.isBefore(currentDate) &&
        _editedTask.dueDate!.day != currentDate.day) {
      // Display a message indicating that the previous date is before today
      Utility.displayInformationalDialog(
        context,
        'The previous due date is before today. Delete it first, then choose another one.',
      );
    } else {
      showDatePicker(
        context: context,
        initialDate: _editedTask.dueDate ?? currentDate,
        firstDate: currentDate,
        lastDate: DateTime(2100),
        initialDatePickerMode: DatePickerMode.day,
        locale: const Locale('en', 'US'),
      ).then((pickedDate) async {
        if (pickedDate != null) {
          // Check if the user selected a new date and if there are reminders
          if (pickedDate != _editedTask.dueDate &&
              _editedTask.dueDate != null &&
              await DBHelper.checkForReminders(_editedTask.id!)) {
            _dueTimeDueDateChanged = true;
            Utility.displayInformationalDialog(
              context,
              'The previous reminders were deleted because the due date was changed.',
            );
            setState(() {
              _selectedReminders = [];
            });
          }
          setState(() {
            _editedTask.dueDate = pickedDate;
          });
        }
      });
    }
  }

  void _presentTimePicker() {
    showTimePicker(
      context: context,
      initialTime:
          _editedTask.dueTime != null ? _editedTask.dueTime! : TimeOfDay.now(),
    ).then((pickedTime) async => {
          if (pickedTime != null)
            {
              //check if the user selected a new time and has reminders selected
              if (pickedTime != _editedTask.dueTime &&
                  _editedTask.dueTime != null &&
                  await DBHelper.checkForReminders(_editedTask.id!))
                {
                  _dueTimeDueDateChanged = true,
                  Utility.displayInformationalDialog(context,
                      'The previous reminders were deleted because the due time was changed.'),
                  setState(() {
                    _selectedReminders = [];
                  })
                },
              setState(() {
                _editedTask.dueTime = pickedTime;
              }),
            }
        });
  }

  void _selectPlace(double? lat, double? lng) {
    _editedTask.address = TaskAddress(latitude: lat, longitude: lng);
    _editedTask.locationCategory = null;
  }

  void _selectCategory(String? selectedLocationCategory) {
    _editedTask.locationCategory = selectedLocationCategory;
    _editedTask.address = null;
  }

  String _displayTime(TimeOfDay? selectedTime) {
    if (_editedTask.dueTime == null) {
      return 'No due time chosen';
    }
    String hour = _editedTask.dueTime!.hour < 10
        ? '0${_editedTask.dueTime!.hour}'
        : '${_editedTask.dueTime!.hour}';
    String minute = _editedTask.dueTime!.minute < 10
        ? '0${_editedTask.dueTime!.minute}'
        : '${_editedTask.dueTime!.minute}';
    String period = _editedTask.dueTime!.period == DayPeriod.am ? 'AM' : 'PM';
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

  Future<void> editDoneTask() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Question"),
            content: const Text(
              """Do you want to move the task back to "In progress"?
You have to set new reminders.""",
              softWrap: true,
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("Yes"),
                onPressed: () async {
                  // change the task to not done
                  _editedTask.isDone = false;

                  _selectedUserEmails =
                      await TaskService.determineAlreadySharedWithUsers(
                          _editedTask.id);

                  // edit the task
                  TaskService.editTask(
                    _editedTask,
                    _pickedImageFile,
                    isImageDeleted,
                    _selectedUserEmails,
                    _selectedReminders,
                  );

                  // go back to overall agenda screen
                  Navigator.of(context)
                      .popAndPushNamed(OverallAgendaPage.routeName);
                },
              ),
              TextButton(
                child: const Text("No"),
                onPressed: () async {
                  // change the task to done
                  _editedTask.isDone = true;

                  _selectedUserEmails =
                      await TaskService.determineAlreadySharedWithUsers(
                          _editedTask.id);

                  // edit the task
                  TaskService.editTask(
                    _editedTask,
                    _pickedImageFile,
                    isImageDeleted,
                    _selectedUserEmails,
                    _selectedReminders,
                  );

                  // go back to overall agenda screen
                  Navigator.of(context)
                      .popAndPushNamed(OverallAgendaPage.routeName);
                },
              ),
            ],
          );
        });
  }
}
