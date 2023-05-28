import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../helpers/utility.dart';
import '../../../providers/task_provider.dart';
import '../../../widgets/drawer.dart';
import '../../../widgets/other/buttons/expandable_fab/expandable_floating_action_button.dart';
import '../../../widgets/task_related/task_list_item.dart';

class OverallAgendaTab extends StatefulWidget {
  static const routeName = '/overall-agenda-tab';

  const OverallAgendaTab({super.key});

  @override
  State<OverallAgendaTab> createState() => _OverallAgendaTabState();
}

class _OverallAgendaTabState extends State<OverallAgendaTab> {
  final ScrollController _controller = ScrollController();
  FilterOptions selectedOption = FilterOptions.inProgress;

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
        title: const Text('Overall'),
        actions: [
          displayFilters(context),
        ],
      ),
      drawer: const MainDrawer(),
      body: Column(
        children: [
          displayTasks(context),
        ],
      ),
      floatingActionButton: const ExpandableFloatingActionButton(),
    );
  }

  Expanded displayTasks(BuildContext context) {
    return Expanded(
      child: FutureBuilder(
        future: _fetchTasks(context, selectedOption),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Error occurred while fetching tasks'),
            );
          } else {
            var taskProvider = Provider.of<TaskProvider>(context);
            var tasks = taskProvider.tasksList;

            if (tasks.isEmpty) {
              return const Center(
                child: Text('There are no tasks added',
                    style: TextStyle(fontSize: 16)),
              );
            }

            return RefreshIndicator(
              onRefresh: () => _fetchTasks(context, selectedOption),
              child: Consumer<TaskProvider>(
                builder: (context, tasksProvider, ch) => Scrollbar(
                  controller: _controller,
                  thumbVisibility: true,
                  thickness: 5,
                  child: ListView.builder(
                    controller: _controller,
                    itemCount: tasks.length,
                    itemBuilder: (context, index) => TaskListItem(
                      id: tasks[index].id,
                      title: tasks[index].title,
                      dueDate: Utility.dateTimeToString(tasks[index].dueDate),
                      address: tasks[index].address,
                      time: Utility.timeOfDayToString(tasks[index].dueTime),
                      priority:
                          Utility.priorityEnumToString(tasks[index].priority),
                      isDone: tasks[index].isDone,
                      isDeleted: tasks[index].isDeleted,
                      locationCategory: tasks[index].locationCategory,
                      owner: tasks[index].owner,
                      imageUrl: tasks[index].imageUrl,
                      category: tasks[index].category,
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  PopupMenuButton<FilterOptions> displayFilters(BuildContext context) {
    return PopupMenuButton(
      icon: const Icon(Icons.more_vert),
      onSelected: (FilterOptions selectedValue) {
        setState(() {
          selectedOption = selectedValue;
        });
        _fetchTasks(context, selectedOption);
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: FilterOptions.all,
          child: Row(
            children: [
              Icon(
                Icons.all_inbox,
                color: selectedOption == FilterOptions.all
                    ? Colors.green
                    : Colors.black,
              ),
              const SizedBox(width: 8),
              Text(
                'All',
                style: TextStyle(
                  color: selectedOption == FilterOptions.all
                      ? Colors.green
                      : Colors.black,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: FilterOptions.inProgress,
          child: Row(
            children: [
              Icon(
                Icons.work,
                color: selectedOption == FilterOptions.inProgress
                    ? Colors.green
                    : Colors.black,
              ),
              const SizedBox(width: 8),
              Text(
                'In progress',
                style: TextStyle(
                  color: selectedOption == FilterOptions.inProgress
                      ? Colors.green
                      : Colors.black,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: FilterOptions.done,
          child: Row(
            children: [
              Icon(
                Icons.done,
                color: selectedOption == FilterOptions.done
                    ? Colors.green
                    : Colors.black,
              ),
              const SizedBox(width: 8),
              Text(
                'Done',
                style: TextStyle(
                  color: selectedOption == FilterOptions.done
                      ? Colors.green
                      : Colors.black,
                ),
              )
            ],
          ),
        ),
        PopupMenuItem(
          value: FilterOptions.focusMode,
          child: Row(
            children: [
              Icon(
                Icons.notification_important_rounded,
                color: selectedOption == FilterOptions.focusMode
                    ? Colors.green
                    : Colors.black,
              ),
              const SizedBox(width: 8),
              Text(
                'Focus Mode',
                style: TextStyle(
                  color: selectedOption == FilterOptions.focusMode
                      ? Colors.green
                      : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
