import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helpers/utility.dart';
import '../../providers/task_provider.dart';
import '../../widgets/drawer.dart';
import '../../widgets/other/buttons/expandable_fab/expandable_floating_action_button.dart';
import '../../widgets/task_related/task_list_item.dart';
import '../task_related/add_edit_task_category_screen.dart';

class CategoryAgendaPage extends StatefulWidget {
  static const routeName = '/category-agenda-tab';

  const CategoryAgendaPage({super.key});

  @override
  State<CategoryAgendaPage> createState() => _CategoryAgendaPageState();
}

class _CategoryAgendaPageState extends State<CategoryAgendaPage> {
  final ScrollController _controller = ScrollController();
  FilterOptions selectedOption = FilterOptions.inProgress;
  var _category;
  var _isInit = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final categoryName =
          ModalRoute.of(context)!.settings.arguments as String?;
      if (categoryName != null) _category = categoryName;
    }

    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _fetchTasks(BuildContext context, FilterOptions? selectedOption,
      String? category) async {
    await Provider.of<TaskProvider>(context, listen: false)
        .fetchTasks(null, null, null, selectedOption, _category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_category), actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            Navigator.of(context).pushNamed(AddEditTaskCategoryScreen.routeName,
                arguments: _category);
          },
        ),
        displayFilters(context)
      ]),
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
        future: _fetchTasks(context, selectedOption, _category),
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
                child: Text('There are no tasks for this category',
                    style: TextStyle(fontSize: 16)),
              );
            }

            return RefreshIndicator(
              onRefresh: () => _fetchTasks(context, selectedOption, _category),
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
        _fetchTasks(context, selectedOption, _category);
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
