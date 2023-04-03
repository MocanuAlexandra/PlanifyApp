import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:planify_app/services/database_helper_service.dart';

import '../../helpers/utility.dart';
import '../../screens/pages/overall_agenda_page.dart';
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

    if (taskToBeAdded != null) {
      //add Task object to DB
      final taskId = await DBHelper.addTask(taskToBeAdded);

      //add an empty sharedWith list to DB
      await DBHelper.addShareWithUser(taskId, 'no users');

      //reload the screen
      navigator.popAndPushNamed(OverallAgendaPage.routeName);
    } else {
      Utility.displayInformationalDialog(
          context, '''The service could not understand you :(
Please try again.''');
    }
  }
}
