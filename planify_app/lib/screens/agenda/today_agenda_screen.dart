import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helpers/utility.dart';
import '../../providers/tasks.dart';
import '../../widgets/drawer.dart';
import '../../widgets/task/task_list_item.dart';
import '../../widgets/task/add_new_task_form.dart';

class TodayAgendaScreen extends StatelessWidget {
  static const routeName = '/today-agenda';

  static FilterOptions selectedOption = FilterOptions.In_progress;

  const TodayAgendaScreen({super.key});

  Future<void> _fetchTasks(
      BuildContext context, FilterOptions? selectedOption) async {
    await Provider.of<Tasks>(context, listen: false)
        .fetchTasks(true, null, null, selectedOption);
  }

  @override
  Widget build(BuildContext context) {
    selectedOption = FilterOptions.In_progress;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        actions: [
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
