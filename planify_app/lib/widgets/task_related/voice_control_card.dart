import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import '../../services/database_helper_service.dart';

import '../../helpers/utility.dart';
import '../../screens/pages/overall_agenda_page.dart';
import '../../services/task_service.dart';
import '../../services/text_processing_service.dart';
import '../../services/voice_control_service.dart';

class VoiceControlCard extends StatefulWidget {
  const VoiceControlCard({super.key});

  @override
  State<VoiceControlCard> createState() => _VoiceControlCardState();
}

class _VoiceControlCardState extends State<VoiceControlCard> {
  String text = 'Your voice recording will appear here..';
  bool _isRecording = false;

  @override
  void initState() {
    VoiceControlService.initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        elevation: 5,
        child: Container(
          padding: EdgeInsets.only(
              top: 10,
              left: 10,
              right: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      text,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AvatarGlow(
                    animate: _isRecording,
                    glowColor: Theme.of(context).colorScheme.secondary,
                    endRadius: 50.0,
                    child: IconButton(
                        onPressed: toggleRecording,
                        icon: Icon(!_isRecording ? Icons.mic_off : Icons.mic)),
                  ),
                  ElevatedButton(
                    onPressed: processAndAddToDB,
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor:
                          Theme.of(context).textTheme.labelLarge!.color,
                    ),
                    child: const Text('Submit',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void toggleRecording() {
    _recordingServiceRecording();
    setState(() {
      _isRecording = !_isRecording;
    });
  }

  void _recordingServiceRecording() {
    VoiceControlService.toggleRecording(
      onResult: (result) {
        setState(() {
          text = result;
        });
      },
    );
  }

  Future<void> processAndAddToDB() async {
    NavigatorState navigator = Navigator.of(context);

    //stop recording
    setState(() {
      _isRecording = false;
    });

    VoiceControlService.stopRecording();

    //process text and return Task object
    final taskToBeAdded = TextProcessingService.processText(text);

    // if taskToBeAdded is not null, it means that the text was processed successfully
    // and the Task object was created, so we can add it to the DB
    if (taskToBeAdded != null) {
      //first check if task is from a special category
      // we first verify if the task is labeled as "appointment" and doesn't have
      // a due date and due time
      if (TaskService.isAppointment(taskToBeAdded)) {
        Utility.displayInformationalDialog(context,
            'This is an appointment! Try saying again and add due date and due time as well!');
      }
      //check if the task is labeled as "exam" and doesn't have
      // a due date and due time
      else if (TaskService.isExam(taskToBeAdded)) {
        Utility.displayInformationalDialog(context,
            'This is an important test! Try saying again and add due date and due time as well!');
      }

      //check if the task is labeled as "meeting" and doesn't have
      // a due date and due time
      else if (TaskService.isMeeting(taskToBeAdded)) {
        Utility.displayInformationalDialog(context,
            'This is a meeting! Try saying again and add due date and due time as well!');
      }

      //check if the task is labeled as "interview" and doesn't have
      // a due date and due time
      else if (TaskService.isInterview(taskToBeAdded)) {
        Utility.displayInformationalDialog(context,
            'This is an interview! Try saying again and add due date and due time as well!');
      }

      // if there is no case, add the task normally
      else {
        //add Task object to DB
        final taskId = await DBHelper.addTask(taskToBeAdded);

        //add an empty sharedWith list to DB
        await DBHelper.addShareWithUser(taskId, 'no users');

        //reload the screen
        navigator.popAndPushNamed(OverallAgendaPage.routeName);
      }
    } else {
      Utility.displayInformationalDialog(
          context, '''The service could not understand you :(
Please try again.''');
    }
  }
}
