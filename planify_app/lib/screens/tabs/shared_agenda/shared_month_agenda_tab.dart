import 'package:flutter/material.dart';
import 'package:month_picker_dialog_2/month_picker_dialog_2.dart';
import 'package:provider/provider.dart';

import '../../../helpers/utility.dart';
import '../../../providers/task_provider.dart';
import '../../../widgets/drawer.dart';
import '../../../widgets/task/task_list_item.dart';

class SharedMonthAgendaTab extends StatefulWidget {
  static const routeName = '/-shared-month-agenda-tab';

  const SharedMonthAgendaTab({super.key});

  @override
  State<SharedMonthAgendaTab> createState() => _SharedMonthAgendaTabState();
}

class _SharedMonthAgendaTabState extends State<SharedMonthAgendaTab> {
  bool _focusMode = false;
  FilterOptions selectedOption = FilterOptions.inProgress;
  DateTime? _selectedDate = DateTime.now();

  Future<void> _fetchTasks(BuildContext context, FilterOptions? selectedOption,
      bool? focusMode) async {
    await Provider.of<TaskProvider>(context, listen: false)
        .fetchSharedTasks(null, true, _selectedDate, selectedOption, focusMode);
  }

  void _presentMonthPicker() async {
    final DateTime? picked = await showMonthPicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void initState() {
    _fetchTasks(context, selectedOption, _focusMode);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Month'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _presentMonthPicker,
          ),
          displayFilters(context),
        ],
      ),
      drawer: const MainDrawer(),
      body: Column(
        children: [
          changeFocusMode(context),
          displayTasks(context),
        ],
      ),
    );
  }

  PopupMenuButton<FilterOptions> displayFilters(BuildContext context) {
    return PopupMenuButton(
      icon: const Icon(Icons.more_vert),
      onSelected: (FilterOptions selectedValue) {
        setState(() {
          selectedOption = selectedValue;
        });
        _fetchTasks(context, selectedOption, _focusMode);
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: FilterOptions.all,
          child: Row(
            children: const [
              Icon(
                Icons.all_inbox,
                color: Colors.black,
              ),
              SizedBox(width: 8),
              Text('All'),
            ],
          ),
        ),
        PopupMenuItem(
          value: FilterOptions.inProgress,
          child: Row(
            children: const [
              Icon(
                Icons.work,
                color: Colors.black,
              ),
              SizedBox(width: 8),
              Text('In progress'),
            ],
          ),
        ),
        PopupMenuItem(
          value: FilterOptions.done,
          child: Row(
            children: const [
              Icon(
                Icons.done,
                color: Colors.black,
              ),
              SizedBox(width: 8),
              Text('Done'),
            ],
          ),
        ),
      ],
    );
  }

  Expanded displayTasks(BuildContext context) {
    return Expanded(
      child: FutureBuilder(
        future: _fetchTasks(context, selectedOption, _focusMode),
        builder: (context, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: () =>
                    _fetchTasks(context, selectedOption, _focusMode),
                child: Consumer<TaskProvider>(
                  builder: (context, tasks, ch) => ListView.builder(
                    itemCount: tasks.tasksList.length,
                    itemBuilder: (context, index) => TaskListItem(
                      id: tasks.tasksList[index].id,
                      title: tasks.tasksList[index].title,
                      dueDate: Utility.dateTimeToString(
                          tasks.tasksList[index].dueDate),
                      address: tasks.tasksList[index].address,
                      time: Utility.timeOfDayToString(
                          tasks.tasksList[index].time),
                      priority: Utility.priorityEnumToString(
                          tasks.tasksList[index].priority),
                      isDone: tasks.tasksList[index].isDone,
                      isDeleted: tasks.tasksList[index].isDeleted,
                      locationCategory: tasks.tasksList[index].locationCategory,
                      owner: tasks.tasksList[index].owner,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Row changeFocusMode(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text(
          'Focus Mode',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        Switch.adaptive(
          activeColor: Theme.of(context).colorScheme.secondary,
          value: _focusMode,
          onChanged: (bool value) {
            setState(() {
              _focusMode = value;
            });
          },
        ),
      ],
    );
  }
}
