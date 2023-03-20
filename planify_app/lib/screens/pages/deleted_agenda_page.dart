import 'package:flutter/material.dart';
import '../../helpers/database_helper.dart';
import 'overall_agenda_page.dart';
import 'package:provider/provider.dart';

import '../../helpers/utility.dart';
import '../../providers/task_provider.dart';
import '../../widgets/drawer.dart';
import '../../widgets/task/task_list_item.dart';

class DeletedAgendaPage extends StatefulWidget {
  static const routeName = '/deleted-agenda-tab';

  const DeletedAgendaPage({super.key});

  @override
  State<DeletedAgendaPage> createState() => _DeletedAgendaPageState();
}

class _DeletedAgendaPageState extends State<DeletedAgendaPage> {
  final ScrollController _controller = ScrollController();
  FilterOptions selectedOption = FilterOptions.deleted;

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
        title: const Text('Trash'),
        actions: [
          clearTrash(context),
        ],
      ),
      drawer: const MainDrawer(),
      body: displayTasks(context),
    );
  }

  FutureBuilder<dynamic> clearTrash(BuildContext context) {
    return FutureBuilder(
      future: _existDeletedTasks(),
      builder: (context, snapshot) => snapshot.connectionState ==
              ConnectionState.waiting
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : snapshot.data == true
              ? IconButton(
                  icon: const Icon(Icons.delete_forever_outlined),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Question'),
                        content: const Text(
                            'Are you sure you want to permanently delete all tasks?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              //remove the images for the tasks
                              DBHelper.deleteAllImages();

                              //delete tasks from DB
                              DBHelper.deleteAllTasks();

                              // remove task from UI
                              Provider.of<TaskProvider>(context, listen: false)
                                  .deleteAllTasks();

                              //close dialog
                              Navigator.of(context).pushReplacementNamed(
                                OverallAgendaPage.routeName,
                              );
                            },
                            child: const Text('Yes'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('No'),
                          ),
                        ],
                      ),
                    );
                  },
                )
              : const SizedBox(),
    );
  }

  FutureBuilder<void> displayTasks(BuildContext context) {
    return FutureBuilder(
      future: _fetchTasks(context, FilterOptions.deleted),
      builder: (context, snapshot) => snapshot.connectionState ==
              ConnectionState.waiting
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
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
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  //Auxiliary function
  //check if there are any deleted tasks in the database
  Future<bool> _existDeletedTasks() async {
    return await DBHelper.checkForDeletedTasks();
  }
}
