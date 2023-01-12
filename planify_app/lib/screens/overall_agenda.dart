import 'package:flutter/material.dart';
import 'package:planify_app/widgets/drawer.dart';
import 'package:planify_app/widgets/tasks/tasks_list.dart';

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
      body: TaskList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
