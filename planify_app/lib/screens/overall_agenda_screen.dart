import 'package:flutter/material.dart';
import 'package:planify_app/widgets/drawer.dart';

import '../models/task.dart';
import '../widgets/tasks/task_list_item.dart';

enum FilterOptions {
  All,
  In_progress,
  Done,
}

class OverallAgendaScreen extends StatelessWidget {
  static const routeName = '/overall-agenda';

  const OverallAgendaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Task> tasks = [
      Task(
          id: '1',
          title: 'Task 1',
          dueDate: DateTime.now(),
          isDone: false,
          priority: Priority.Important),
      Task(
          id: '2',
          title: 'Task 2',
          dueDate: DateTime.now(),
          isDone: false,
          priority: Priority.Low),
      Task(
          id: '3',
          title: 'Task 3',
          dueDate: DateTime.now(),
          isDone: false,
          priority: Priority.Medium),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Overall Agenda'),
        actions: [
          PopupMenuButton(
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
            icon: const Icon(Icons.more_vert),
            onSelected: (FilterOptions selectedValue) {},
          ),
        ],
      ),
      drawer: const MainDrawer(),
      body: ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            return TaskListItem(
              id: tasks[index].id,
              title: tasks[index].title,
              dueDate: tasks[index].dueDate,
              isDone: tasks[index].isDone,
              priority: tasks[index].priority,
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/add-task');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
