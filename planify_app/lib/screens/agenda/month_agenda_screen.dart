import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:month_picker_dialog_2/month_picker_dialog_2.dart';

import '../../helpers/utility.dart';
import '../../providers/tasks.dart';
import '../../widgets/drawer.dart';
import '../../widgets/task/task_list_item.dart';
import '../../widgets/task/add_new_task_form.dart';

class MonthAgendaScreen extends StatefulWidget {
  static const routeName = '/month-agenda';

  const MonthAgendaScreen({super.key});

  @override
  State<MonthAgendaScreen> createState() => _MonthAgendaScreenState();
}

class _MonthAgendaScreenState extends State<MonthAgendaScreen> {
  DateTime? _selectedDate = DateTime.now();

  static FilterOptions selectedOption = FilterOptions.In_progress;

  Future<void> _fetchTasks(
      BuildContext context, FilterOptions? selectedOption) async {
    await Provider.of<Tasks>(context, listen: false)
        .fetchTasks(null, true, _selectedDate, selectedOption);
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
    selectedOption = FilterOptions.In_progress;

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
              selectedOption = selectedValue;
              _fetchTasks(context, selectedOption);
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: FilterOptions.All,
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
                value: FilterOptions.In_progress,
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
                value: FilterOptions.Done,
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
          ),
        ],
      ),
      drawer: const MainDrawer(),
      body: FutureBuilder(
        future: _fetchTasks(context, FilterOptions.In_progress),
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _fetchTasks(context, selectedOption),
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
                          isDeleted: tasks.tasksList[index].isDeleted,
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
