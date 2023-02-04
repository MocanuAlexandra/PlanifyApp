import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helpers/utility.dart';
import '../../providers/tasks.dart';
import '../../widgets/drawer.dart';
import '../../widgets/helpers/expandable_fab/action_button.dart';
import '../../widgets/helpers/expandable_fab/expandable_fab.dart';
import '../../widgets/helpers/expandable_fab/expandable_floating_action_button.dart';
import '../../widgets/task/task_list_item.dart';
import '../task/add_edit_category_screen.dart';
import '../task/add_edit_task_screen.dart';

class TodayAgendaScreen extends StatefulWidget {
  static const routeName = '/today-agenda';

  const TodayAgendaScreen({super.key});

  @override
  State<TodayAgendaScreen> createState() => _TodayAgendaScreenState();
}

class _TodayAgendaScreenState extends State<TodayAgendaScreen> {
  bool _focusMode = false;
  FilterOptions selectedOption = FilterOptions.inProgress;

  Future<void> _fetchTasks(BuildContext context, FilterOptions? selectedOption,
      bool? focusMode) async {
    await Provider.of<Tasks>(context, listen: false)
        .fetchTasks(true, null, null, selectedOption, focusMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        actions: [
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
      floatingActionButton: const ExpandableFloatingActionButton(),
    );
  }

  Expanded displayTasks(BuildContext context) {
    return Expanded(
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
