import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../../screens/task_related/add_edit_task_category_screen.dart';
import '../../../../screens/task_related/add_edit_task_screen.dart';
import '../../../task_related/voice_control_card.dart';
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
        // action button used for voice input
        ActionButton(
          onPressed: () => startRecording(context),
          icon: const Icon(Icons.mic_rounded),
        ),
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

  void startRecording(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          behavior: HitTestBehavior.opaque,
          child: const VoiceControlCard(),
          //TODO resolve issue when tapp outside of the card
        );
      },
    );
  }
}
