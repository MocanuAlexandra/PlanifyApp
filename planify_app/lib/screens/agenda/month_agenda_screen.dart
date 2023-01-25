import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:month_picker_dialog_2/month_picker_dialog_2.dart';

import '../../helpers/utility.dart';
import '../../providers/tasks.dart';
import '../../widgets/drawer.dart';
import '../../widgets/task/task_list_item.dart';
import '../../widgets/task/add_new_task_form.dart';

enum FilterOptions {
  All,
  In_progress,
  Done,
}

class MonthAgendaScreen extends StatefulWidget {
  static const routeName = '/month-agenda';

  const MonthAgendaScreen({super.key});

  @override
  State<MonthAgendaScreen> createState() => _MonthAgendaScreenState();
}

class _MonthAgendaScreenState extends State<MonthAgendaScreen> {
  DateTime? _selectedDate = DateTime.now();

  Future<void> _refreshAllTasks(BuildContext context) async {
    await Provider.of<Tasks>(context, listen: false)
        .fetchAndSetAllTasksDueMonth(_selectedDate!);
  }

  Future<void> _refreshInProgressTasks(BuildContext context) async {
    await Provider.of<Tasks>(context, listen: false)
        .fetchAndSetInProgressTasksDueMonth(_selectedDate!);
  }

  Future<void> _refreshDoneTasks(BuildContext context) async {
    await Provider.of<Tasks>(context, listen: false)
        .fetchAndSetDoneTasksDueMonth(_selectedDate!);
  }

  void _presentMonthPicker() async {
    final DateTime? picked = await showMonthPicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
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
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            onSelected: (FilterOptions selectedValue) {
              selectedValue == FilterOptions.Done
                  ? _refreshDoneTasks(context)
                  : selectedValue == FilterOptions.In_progress
                      ? _refreshInProgressTasks(context)
                      : _refreshAllTasks(context);
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: FilterOptions.All,
                child: Row(
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    const Icon(
                      Icons.all_inbox,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 8),
                    const Text('All'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: FilterOptions.In_progress,
                child: Row(
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    const Icon(
                      Icons.work,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 8),
                    const Text('In progress'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: FilterOptions.Done,
                child: Row(
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    const Icon(
                      Icons.done,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 8),
                    const Text('Done'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: const MainDrawer(),
      body: FutureBuilder(
        future: _refreshAllTasks(context),
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () =>
                        //TODO check what filter option is selected before the refresh
                        _refreshAllTasks(context),
                    child: Consumer<Tasks>(
                      builder: (context, tasks, ch) => ListView.builder(
                        itemCount: tasks.tasksList.length,
                        itemBuilder: (context, index) => TaskListItem(
                          id: tasks.tasksList[index].id,
                          title: tasks.tasksList[index].title,
                          dueDate: tasks.tasksList[index].dueDate,
                          address: tasks.tasksList[index].address,
                          time: Utility.timeOfDayToString(
                              tasks.tasksList[index].time),
                          priority: Utility.priorityEnumToString(
                              tasks.tasksList[index].priority),
                          isDone: tasks.tasksList[index].isDone,
                        ),
                      ),
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AddEditTaskForm.routeName);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
