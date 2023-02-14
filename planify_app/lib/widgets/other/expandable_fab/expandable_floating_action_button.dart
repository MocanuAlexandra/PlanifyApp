import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../screens/task/add_edit_task_category_screen.dart';
import '../../../screens/task/add_edit_task_screen.dart';
import 'action_button.dart';
import 'expandable_fab.dart';

class ExpandableFloatingActionButton extends StatelessWidget {
  const ExpandableFloatingActionButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ExpandableFab(
      distance: 80,
      children: [
        // action button used for adding a new category
        ActionButton(
          onPressed: () {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context)
                  .pushNamed(AddEditTaskCategoryScreen.routeName);
            });
          },
          icon: const Icon(Icons.category_rounded),
        ),
        // action button used for adding a new task
        ActionButton(
          onPressed: () {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushNamed(AddEditTaskScreen.routeName);
            });
          },
          icon: const Icon(Icons.note_add_rounded),
        ),
      ],
    );
  }
}
