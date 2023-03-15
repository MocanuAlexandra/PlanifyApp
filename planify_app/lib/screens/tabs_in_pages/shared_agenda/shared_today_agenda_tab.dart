import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../helpers/location_helper.dart';
import '../../../helpers/utility.dart';
import '../../../providers/task_provider.dart';
import '../../../widgets/drawer.dart';
import '../../../widgets/task/task_list_item.dart';

class SharedTodayAgendaTab extends StatefulWidget {
  static const routeName = '/shared-today-agenda-tab';

  const SharedTodayAgendaTab({super.key});

  @override
  State<SharedTodayAgendaTab> createState() => _SharedTodayAgendaTabState();
}

class _SharedTodayAgendaTabState extends State<SharedTodayAgendaTab> {
  bool _focusMode = false;
  FilterOptions selectedOption = FilterOptions.inProgress;
  var tasks = [];

  Future<void> _fetchTasks(BuildContext context, FilterOptions? selectedOption,
      bool? focusMode) async {
    var provider = Provider.of<TaskProvider>(context, listen: false);
    await Provider.of<TaskProvider>(context, listen: false)
        .fetchSharedTasks(true, null, null, selectedOption, focusMode);

    tasks = provider.tasksList;
  }

  @override
  void initState() {
    _fetchTasks(context, selectedOption, _focusMode);
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
          changeFocusMode(context),
          displayTasks(context),
        ],
      ),
    );
  }

  Expanded displayTasks(BuildContext context) {
    return Expanded(
      child: FutureBuilder(
        future: _fetchTasks(context, selectedOption, _focusMode),
        builder: (context, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: () =>
                    _fetchTasks(context, selectedOption, _focusMode),
                child: Consumer<TaskProvider>(
                  builder: (context, tasks, ch) => ListView.builder(
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
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Row changeFocusMode(BuildContext context) {
    return Row(
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
    );
  }

  PopupMenuButton<FilterOptions> displayFilters(BuildContext context) {
    return PopupMenuButton(
      icon: const Icon(Icons.more_vert),
      onSelected: (FilterOptions selectedValue) {
        setState(() {
          selectedOption = selectedValue;
        });
        _fetchTasks(context, selectedOption, _focusMode);
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: FilterOptions.all,
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
          value: FilterOptions.inProgress,
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
          value: FilterOptions.done,
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
    );
  }
}
