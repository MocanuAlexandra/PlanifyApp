import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helpers/utility.dart';
import '../../providers/tasks.dart';
import '../../widgets/drawer.dart';
import '../../widgets/task/task_list_item.dart';
import '../../widgets/task/add_new_task_form.dart';

class OverallAgendaScreen extends StatefulWidget {
  static const routeName = '/overall-agenda';

  const OverallAgendaScreen({super.key});

  @override
  State<OverallAgendaScreen> createState() => _OverallAgendaScreenState();
}

class _OverallAgendaScreenState extends State<OverallAgendaScreen> {
  bool _focusMode = false;
  FilterOptions selectedOption = FilterOptions.In_progress;

  Future<void> _fetchTasks(BuildContext context, FilterOptions? selectedOption,
      bool? focusMode) async {
    await Provider.of<Tasks>(context, listen: false)
        .fetchTasks(null, null, null, selectedOption, focusMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Overall'),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                selectedOption = selectedValue;
              });
              _fetchTasks(context, selectedOption, _focusMode);
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
      body: Column(
        children: [
          Row(
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
          ),
          Expanded(
            child: FutureBuilder(
              future: _fetchTasks(context, selectedOption, _focusMode),
              builder: (context, snapshot) =>
                  snapshot.connectionState == ConnectionState.waiting
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : RefreshIndicator(
                          onRefresh: () =>
                              _fetchTasks(context, selectedOption, _focusMode),
                          child: Consumer<Tasks>(
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
                              ),
                            ),
                          ),
                        ),
            ),
          ),
        ],
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
