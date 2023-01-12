import 'package:flutter/material.dart';
import 'package:planify_app/widgets/tasks/task_item.dart';

import '../../models/task.dart';

class TaskList extends StatelessWidget {
  //TODO remove this 
  final List<Task> tasks = [
    Task(id: '1',title: 'Task 1', dueDate: DateTime.now(), isDone: false,priority : Priority.Important),
    Task(id: '2',title: 'Task 2', dueDate: DateTime.now(), isDone: false, priority: Priority.Low),
    Task(id: '3',title: 'Task 3', dueDate: DateTime.now(), isDone: false, priority: Priority.Medium),
  ];

  TaskList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return TaskItem(
          id: tasks[index].id,
          title: tasks[index].title,
          dueDate: tasks[index].dueDate,
          isDone: tasks[index].isDone,
          priority: tasks[index].priority,
        );
      },
    );
  }
}
