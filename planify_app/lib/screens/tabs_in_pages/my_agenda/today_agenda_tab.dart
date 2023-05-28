import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/location_helper_service.dart';
import '../../../helpers/utility.dart';
import '../../../providers/task_provider.dart';
import '../../../widgets/drawer.dart';
import '../../../widgets/other/buttons/expandable_fab/expandable_floating_action_button.dart';
import '../../../widgets/task_related/task_list_item.dart';

class TodayAgendaTab extends StatefulWidget {
  static const routeName = '/today-agenda-tab';

  const TodayAgendaTab({super.key});

  @override
  State<TodayAgendaTab> createState() => _TodayAgendaTabState();
}

class _TodayAgendaTabState extends State<TodayAgendaTab> {
  final ScrollController _controller = ScrollController();
  FilterOptions selectedOption = FilterOptions.inProgress;
  var tasks = [];

  Future<void> _fetchTasks(
      BuildContext context, FilterOptions? selectedOption) async {
    var provider = Provider.of<TaskProvider>(context, listen: false);

    await Provider.of<TaskProvider>(context, listen: false)
        .fetchTasks(true, null, null, selectedOption);

    tasks = provider.tasksList;
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
        title: const Text('Today'),
        actions: [
          IconButton(
              onPressed: () async {
                //check if there is at least one task
                if (tasks.isEmpty) {
                  Utility.displayInformationalDialog(
                      context, 'There is no tasks for today');
                  return;
                }
                //check if at least one task has location chosen
                if (tasks
                    .where(
                        (task) => task.address.address != 'No address chosen')
                    .toList()
                    .isEmpty) {
                  Utility.displayInformationalDialog(
                      context, 'There is no task with location chosen');
                } else {
                  //get current location of user
                  var locData = await LocationHelper.getCurrentLocation();

                  //launch map
                  LocationHelper.launchMaps(
                      tasks, locData.latitude!, locData.longitude);
                }
              },
              icon: const Icon(Icons.directions)),
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
                child: Text('There are no tasks for today',
                    style: TextStyle(fontSize: 16)),
              );
            }

            return RefreshIndicator(
              onRefresh: () => _fetchTasks(context, selectedOption),
              child: Consumer<TaskProvider>(
                builder: (context, tasks, ch) => Scrollbar(
                  controller: _controller,
                  thumbVisibility: true,
                  thickness: 5,
                  child: ListView.builder(
                    controller: _controller,
                    itemCount: tasks.tasksList.length,
                    itemBuilder: (context, index) => TaskListItem(
                      id: tasks.tasksList[index].id,
                      title: tasks.tasksList[index].title,
                      dueDate: Utility.dateTimeToString(
                          tasks.tasksList[index].dueDate),
                      address: tasks.tasksList[index].address,
                      time: Utility.timeOfDayToString(
                          tasks.tasksList[index].dueTime),
                      priority: Utility.priorityEnumToString(
                          tasks.tasksList[index].priority),
                      isDone: tasks.tasksList[index].isDone,
                      isDeleted: tasks.tasksList[index].isDeleted,
                      locationCategory: tasks.tasksList[index].locationCategory,
                      owner: tasks.tasksList[index].owner,
                      imageUrl: tasks.tasksList[index].imageUrl,
                      category: tasks.tasksList[index].category,
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
