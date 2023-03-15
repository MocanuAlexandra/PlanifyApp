import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../models/task.dart';
import '../../widgets/other/image/user_image_picker.dart';
import '../../widgets/other/user_list_search.dart';
import 'package:provider/provider.dart';

import '../../helpers/database_helper.dart';
import '../../helpers/utility.dart';
import '../../models/task_category.dart';
import '../../models/task.dart' as task_model;
import '../../models/task_address.dart';
import '../../models/task_reminder.dart';
import '../../providers/task_category_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/task_reminder_provider.dart';
import '../../services/notification_service.dart';
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
        _editedTask = task_model.Task(
          id: _editedTask.id,
          title: value.toString(),
          dueDate: _editedTask.dueDate,
          address: _editedTask.address,
          dueTime: _editedTask.dueTime,
          priority: _editedTask.priority,
          isDone: _editedTask.isDone,
          category: _editedTask.category,
          locationCategory: _editedTask.locationCategory,
          owner: _editedTask.owner,
          imageUrl: _editedTask.imageUrl,
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
            onPressed: () async {
              setState(() {
                _editedTask = task_model.Task(
                  id: _editedTask.id,
                  title: _editedTask.title,
                  dueDate: null,
                  address: _editedTask.address,
                  dueTime: _editedTask.dueTime,
                  priority: _editedTask.priority,
                  isDone: _editedTask.isDone,
                  category: _editedTask.category,
                  locationCategory: _editedTask.locationCategory,
                  owner: _editedTask.owner,
                  imageUrl: _editedTask.imageUrl,
                );
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
            foregroundColor: Theme.of(context).primaryColor,
          ),
        ),
        //delete selected time
        IconButton(
            onPressed: () async {
              setState(() {
                _editedTask = task_model.Task(
                  id: _editedTask.id,
                  title: _editedTask.title,
                  dueDate: _editedTask.dueDate,
                  address: _editedTask.address,
                  dueTime: null,
                  priority: _editedTask.priority,
                  isDone: _editedTask.isDone,
                  category: _editedTask.category,
                  locationCategory: _editedTask.locationCategory,
                  owner: _editedTask.owner,
                  imageUrl: _editedTask.imageUrl,
                );
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
          _editedTask = task_model.Task(
            id: _editedTask.id,
            title: _editedTask.title,
            dueDate: _editedTask.dueDate,
            address: _editedTask.address,
            dueTime: _editedTask.dueTime,
            priority: value,
            isDone: _editedTask.isDone,
            category: _editedTask.category,
            locationCategory: _editedTask.locationCategory,
            owner: _editedTask.owner,
            imageUrl: _editedTask.imageUrl,
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
                      _editedTask = task_model.Task(
                        id: _editedTask.id,
                        title: _editedTask.title,
                        dueDate: _editedTask.dueDate,
                        address: _editedTask.address,
                        dueTime: _editedTask.dueTime,
                        priority: _editedTask.priority,
                        isDone: _editedTask.isDone,
                        category: value,
                        locationCategory: _editedTask.locationCategory,
                        owner: _editedTask.owner,
                        imageUrl: _editedTask.imageUrl,
                      );
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
          onPressed: _editedTask.dueTime == null && _editedTask.dueDate == null
              ? () => Utility.displayInformationalDialog(
                  context, 'Please select due date or due time first!')
              : _editedTask.dueTime == null && _editedTask.dueDate != null
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
            foregroundColor: Theme.of(context).primaryColor,
          ),
        ),
        //only owner can share the task
        if (_editedTask.owner == DBHelper.currentUserId() ||
            _editedTask.owner == null)
          TextButton.icon(
            onPressed: _editedTask.id == null
                // if task is not saved yet, then we don't need to check already selected users emails
                ? () {
                    showDialog(
                      context: context,
                      builder: (context) => UserListSearch(
                        checkedItems: _selectedUserEmails,
                      ),
                    );
                  }
                // if task is saved, then we need to check already selected users emails
                : () async {
                    _selectedUserEmails =
                        await Utility.determineAlreadySharedWithUsers(
                            _editedTask.id);
                    showDialog(
                      context: context,
                      builder: (context) => UserListSearch(
                        checkedItems: _selectedUserEmails,
                      ),
                    );
                  },
            icon: const Icon(Icons.share),
            label: const Text(
              'Share with',
              style: TextStyle(fontSize: 15),
            ),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).primaryColor,
            ),
          ),
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
      setState(() {
        _isLoading = true; // set the loading state to true
      });

      _formKey.currentState!.save();

      // if we got an id, it means that we are editing a task
      if (_editedTask.id != null) {
        if (_editedTask.isDone == true) {
          //show an alert dialog to the user if the task is done
          //we ask the user if he wants to move the tasks to 'in progress' tasks
          //and we update the task in the database accordingly
          _displayDialogForDoneTask();
        } else {
          //check if the logged in user is the owner of the task in order to update the task accordingly
          if (_editedTask.owner == DBHelper.currentUserId() ||
              _editedTask.owner == null) {
            //update the image in the database storage and get the url
            //then set the image url in the task
            _editedTask.imageUrl = await DBHelper.updateImageForTask(
                _pickedImageFile, _editedTask.imageUrl, isImageDeleted);

            //update the task in the database
            await DBHelper.updateTask(_editedTask.id!, _editedTask);

            //delete the notifications for the task and then add the new ones
            await deleteNotificationsForTask(_editedTask.id!)
                .then((value) async => {
                      //check if the user selected a due date or time
                      if (_editedTask.dueDate != null ||
                          _editedTask.dueTime != null)
                        {
                          await addNotificationsForTask(_editedTask.id!),
                        }
                    });

            //remove sharing for task, then update it
            await Utility.removeSharingForTask(_editedTask.id!)
                .then((value) async => {
                      await shareTask(_editedTask.id!),
                    });
          } else {
            //update the image in the database storage and get the url
            //then set the image url in the task
            _editedTask.imageUrl = await DBHelper.updateImageForSharedTask(
                _pickedImageFile,
                _editedTask.owner!,
                _editedTask.imageUrl,
                isImageDeleted);

            //update the task in the database
            await DBHelper.updateSharedTask(_editedTask.id!, _editedTask);

            //delete the notifications for the task and then add the new ones
            await deleteNotificationsForSharedTask(_editedTask.id!)
                .then((value) async => {
                      //check if the user selected a due date or time
                      if (_editedTask.dueDate != null ||
                          _editedTask.dueTime != null)
                        {
                          await addNotificationsForTask(_editedTask.id!),
                        }
                    });
          }

          // go back to overall agenda screen
          navigator.popAndPushNamed(OverallAgendaPage.routeName);
        }
      }
      // if we didn't get an id, it means that we are adding a new task
      else {
        //add the image in the database storage and get the url
        //then set the image url in the task
        _editedTask.imageUrl = await DBHelper.updateImageForTask(
            _pickedImageFile, _editedTask.imageUrl, isImageDeleted);

        //add the task in the database
        String taskId = await DBHelper.addTask(_editedTask);

        //share the task with the selected users
        await shareTask(taskId);

        //check if the user selected a due date or time
        if (_editedTask.dueDate != null || _editedTask.dueTime != null) {
          //add notifications for the task
          await addNotificationsForTask(taskId);
        }

        // go back to overall agenda screen
        navigator.popAndPushNamed(OverallAgendaPage.routeName);
      }
    }
  }

  Future<void> deleteNotificationsForTask(String taskId) async {
    //delete the notifications for the task from the database
    await DBHelper.deleteRemindersForTask(taskId);

    //delete the notifications for the task from the notification center
    NotificationService.deleteNotification(taskId);
  }

  Future<void> deleteNotificationsForSharedTask(String taskId) async {
    //delete the notifications for the task from the database
    await DBHelper.deleteNotificationsForSharedTask(taskId);

    //delete the notifications for the task from the notification center
    NotificationService.deleteNotification(taskId);
  }

  Future<void> shareTask(String taskId) async {
    //add the users to the task
    if (_selectedUserEmails.isNotEmpty) {
      for (var email in _selectedUserEmails) {
        //first we add to task a list containing the id of users to whom we shared the task
        await DBHelper.addShareWithUser(taskId, email);

        // then we add to each user to whom we shared the task, a collection named 'sharedTask'
        // in which we add a document containing the owner of task and taskId
        await DBHelper.addSharedTaskToUser(taskId, email);
      }
    } else {
      //if the _selectedUsersEmails is empty, we add an empty list 'sharedWith' in the task
      await DBHelper.addShareWithUser(taskId, 'no users');
    }
  }

  Future<void> addNotificationsForTask(String taskId) async {
    //parse the selected reminders and create a notification for each one
    if (_selectedReminders.isNotEmpty) {
      for (String reminder in _selectedReminders) {
        TaskReminder newReminder;
        //check if the user selected only due date
        if (_editedTask.dueDate != null && _editedTask.dueTime == null) {
          newReminder = TaskReminder(
            contentId: taskId.hashCode +
                _editedTask.dueDate!.day +
                _editedTask.dueDate!.month +
                _editedTask.dueDate!.year +
                reminder.hashCode,
            reminder: reminder,
          );
          //add the notification to database
          await DBHelper.addReminderForTask(taskId, newReminder);
        }
        //check if the user selected only time
        else if (_editedTask.dueDate == null && _editedTask.dueTime != null) {
          newReminder = TaskReminder(
            contentId: taskId.hashCode +
                _editedTask.dueTime!.hour +
                _editedTask.dueTime!.minute +
                reminder.hashCode,
            reminder: reminder,
          );
          //add the notification to database according to the logged in user
          if (_editedTask.owner == DBHelper.currentUserId() ||
              _editedTask.owner == null) {
            await DBHelper.addReminderForTask(taskId, newReminder);
          } else {
            await DBHelper.addReminderForSharedTask(taskId, newReminder);
          }
          //else it means that the user selected both due date and time
        } else {
          newReminder = TaskReminder(
            contentId: taskId.hashCode +
                _editedTask.dueDate!.day +
                _editedTask.dueDate!.month +
                _editedTask.dueDate!.year +
                _editedTask.dueTime!.hour +
                _editedTask.dueTime!.minute +
                reminder.hashCode,
            reminder: reminder,
          );
          //add the notification to database according to the logged in user
          if (_editedTask.owner == DBHelper.currentUserId() ||
              _editedTask.owner == null) {
            await DBHelper.addReminderForTask(taskId, newReminder);
          } else {
            await DBHelper.addReminderForSharedTask(taskId, newReminder);
          }
        }

        //add the notification to notification center
        NotificationService.createNotificationForTask(
            _editedTask, reminder, newReminder, taskId);
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
                      UserImagePicker(
                        imagePickFn: _pickedImage,
                        previousImageUrl: _editedTask.imageUrl,
                      ),
                      const SizedBox(height: 3),
                      locationField(),
                      const SizedBox(height: 10),
                      priorityField(),
                      const SizedBox(height: 10),
                      categoryField(context),
                      const SizedBox(height: 10),
                      reminderAndShareWithField(),
                      const SizedBox(height: 5),
                    ],
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
    showDatePicker(
      context: context,
      initialDate:
          _editedTask.dueDate != null ? _editedTask.dueDate! : DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.day,
      locale: const Locale('en', 'US'),
    ).then((pickedDate) async => {
          if (pickedDate != null)
            {
              //check if the user selected a new date and if there are reminders
              if (pickedDate != _editedTask.dueDate &&
                  _editedTask.dueDate != null &&
                  await DBHelper.checkForReminders(_editedTask.id!))
                {
                  _dueTimeDueDateChanged = true,
                  Utility.displayInformationalDialog(context,
                      'The previous reminders were deleted because the due date was changed.'),
                  setState(() {
                    _selectedReminders = [];
                  })
                },
              setState(() {
                _editedTask = task_model.Task(
                  id: _editedTask.id,
                  title: _editedTask.title,
                  dueDate: pickedDate,
                  address: _editedTask.address,
                  dueTime: _editedTask.dueTime,
                  priority: _editedTask.priority,
                  isDone: _editedTask.isDone,
                  isDeleted: _editedTask.isDeleted,
                  category: _editedTask.category,
                  locationCategory: _editedTask.locationCategory,
                  owner: _editedTask.owner,
                  imageUrl: _editedTask.imageUrl,
                );
              }),
            }
        });
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
                _editedTask = task_model.Task(
                  id: _editedTask.id,
                  title: _editedTask.title,
                  dueDate: _editedTask.dueDate,
                  address: _editedTask.address,
                  dueTime: pickedTime,
                  priority: _editedTask.priority,
                  isDone: _editedTask.isDone,
                  isDeleted: _editedTask.isDeleted,
                  category: _editedTask.category,
                  locationCategory: _editedTask.locationCategory,
                  owner: _editedTask.owner,
                  imageUrl: _editedTask.imageUrl,
                );
              }),
            }
        });
  }

  void _selectPlace(double? lat, double? lng) {
    _editedTask = task_model.Task(
      id: _editedTask.id,
      title: _editedTask.title,
      dueDate: _editedTask.dueDate,
      address: TaskAddress(latitude: lat, longitude: lng),
      dueTime: _editedTask.dueTime,
      priority: _editedTask.priority,
      isDone: _editedTask.isDone,
      isDeleted: _editedTask.isDeleted,
      category: _editedTask.category,
      locationCategory: null,
      owner: _editedTask.owner,
      imageUrl: _editedTask.imageUrl,
    );
  }

  void _selectCategory(String? selectedLocationCategory) {
    _editedTask = task_model.Task(
      id: _editedTask.id,
      title: _editedTask.title,
      dueDate: _editedTask.dueDate,
      address: null,
      dueTime: _editedTask.dueTime,
      priority: _editedTask.priority,
      isDone: _editedTask.isDone,
      isDeleted: _editedTask.isDeleted,
      category: _editedTask.category,
      locationCategory: selectedLocationCategory,
      owner: _editedTask.owner,
      imageUrl: _editedTask.imageUrl,
    );
  }

  void _displayDialogForDoneTask() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Question"),
            content: const Text(
              """This task is done. Do you want to move it to "In progress" tasks?
You have to set new reminders if you want to be notified about this task.""",
              softWrap: true,
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("Yes"),
                onPressed: () {
                  // change the task to not done
                  _editedTask = task_model.Task(
                    id: _editedTask.id,
                    title: _editedTask.title,
                    dueDate: _editedTask.dueDate,
                    address: _editedTask.address,
                    dueTime: _editedTask.dueTime,
                    priority: _editedTask.priority,
                    isDone: false,
                    isDeleted: _editedTask.isDeleted,
                    category: _editedTask.category,
                    locationCategory: _editedTask.locationCategory,
                    owner: _editedTask.owner,
                    imageUrl: _editedTask.imageUrl,
                  );

                  // check if the logged in user is the owner of the task
                  if (_editedTask.owner == DBHelper.currentUserId() ||
                      _editedTask.owner == null) {
                    //update the task in the database
                    DBHelper.updateTask(_editedTask.id!, _editedTask);
                  } else {
                    DBHelper.updateSharedTask(_editedTask.id!, _editedTask);
                  }

                  // go back to overall agenda screen
                  Navigator.of(context)
                      .popAndPushNamed(OverallAgendaPage.routeName);
                },
              ),
              TextButton(
                child: const Text("No"),
                onPressed: () {
                  // change the task to done
                  _editedTask = task_model.Task(
                    id: _editedTask.id,
                    title: _editedTask.title,
                    dueDate: _editedTask.dueDate,
                    address: _editedTask.address,
                    dueTime: _editedTask.dueTime,
                    priority: _editedTask.priority,
                    isDone: true,
                    isDeleted: _editedTask.isDeleted,
                    category: _editedTask.category,
                    locationCategory: _editedTask.locationCategory,
                    owner: _editedTask.owner,
                    imageUrl: _editedTask.imageUrl,
                  );

                  // check if the logged in user is the owner of the task
                  if (_editedTask.owner == DBHelper.currentUserId() ||
                      _editedTask.owner == null) {
                    //update the task in the database
                    DBHelper.updateTask(_editedTask.id!, _editedTask);
                  } else {
                    DBHelper.updateSharedTask(_editedTask.id!, _editedTask);
                  }

                  // go back to overall agenda screen
                  Navigator.of(context)
                      .popAndPushNamed(OverallAgendaPage.routeName);
                },
              ),
            ],
          );
        });
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
}
