import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/tasks.dart';
import '../../widgets/drawer.dart';
import '../../widgets/task/task_list_item.dart';
import '../../widgets/task/add_new_task_form.dart';

class TodayAgendaScreen extends StatelessWidget {
  static const routeName = '/today-agenda';

  const TodayAgendaScreen({super.key});

  Future<void> _refreshTasks(BuildContext context) async {
    await Provider.of<Tasks>(context, listen: false).fetchTasksDueToday();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
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
                          time: tasks.tasksList[index].time,
                          priority: tasks.tasksList[index].priority,
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