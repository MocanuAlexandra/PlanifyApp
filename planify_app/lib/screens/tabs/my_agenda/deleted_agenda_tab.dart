import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../helpers/utility.dart';
import '../../../providers/task_provider.dart';
import '../../../widgets/drawer.dart';
import '../../../widgets/task/task_list_item.dart';

class DeletedAgendaTab extends StatefulWidget {
  static const routeName = '/deleted-agenda-tab';

  const DeletedAgendaTab({super.key});

  @override
  State<DeletedAgendaTab> createState() => _DeletedAgendaTabState();
}

class _DeletedAgendaTabState extends State<DeletedAgendaTab> {
  FilterOptions selectedOption = FilterOptions.deleted;

  Future<void> _fetchTasks(
      BuildContext context, FilterOptions? selectedOption) async {
    await Provider.of<TaskProvider>(context, listen: false)
        .fetchTasks(null, null, null, selectedOption);
  }

  @override
  void initState() {
    _fetchTasks(context, selectedOption);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash'),
      ),
      drawer: const MainDrawer(),
      body: displayTasks(context),
    );
  }

  FutureBuilder<void> displayTasks(BuildContext context) {
    return FutureBuilder(
      future: _fetchTasks(context, FilterOptions.deleted),
      builder: (context, snapshot) => snapshot.connectionState ==
              ConnectionState.waiting
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () => _fetchTasks(context, selectedOption),
              child: Consumer<TaskProvider>(
                builder: (context, tasks, ch) => ListView.builder(
                  itemCount: tasks.tasksList.length,
                  itemBuilder: (context, index) => TaskListItem(
                    id: tasks.tasksList[index].id,
                    title: tasks.tasksList[index].title,
                    dueDate: Utility.dateTimeToString(
                        tasks.tasksList[index].dueDate),
                    address: tasks.tasksList[index].address,
                    time:
                        Utility.timeOfDayToString(tasks.tasksList[index].time),
                    priority: Utility.priorityEnumToString(
                        tasks.tasksList[index].priority),
                    isDone: tasks.tasksList[index].isDone,
                    isDeleted: tasks.tasksList[index].isDeleted,
                    locationCategory: tasks.tasksList[index].locationCategory,
                  ),
                ),
              ),
            ),
    );
  }
}