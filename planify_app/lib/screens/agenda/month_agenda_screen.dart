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

  Future<void> _refreshTasks(BuildContext context) async {
    await Provider.of<Tasks>(context, listen: false)
        .fetchTasksDueMonth(_selectedDate!);
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
        ],
      ),
      drawer: const MainDrawer(),
      body: FutureBuilder(
        future: _refreshTasks(context),
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshTasks(context),
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
                        ),
                      ),
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AddNewTaskForm.routeName);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
