import 'package:flutter/material.dart';
import 'package:planify_app/services/voice_control_service.dart';
import 'package:avatar_glow/avatar_glow.dart';

class RecordCard extends StatefulWidget {
  const RecordCard({super.key});

  @override
  State<RecordCard> createState() => _RecordCardState();
}

class _RecordCardState extends State<RecordCard> {
  String text = 'Your voice recording will appear here..';
  bool _isRecording = false;

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
                    glowColor: Theme.of(context).primaryColor,
                    endRadius: 50.0,
                    child: IconButton(
                        onPressed: toggleRecording,
                        icon: Icon(!_isRecording ? Icons.mic_off : Icons.mic)),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
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

  Future toggleRecording() => VoiceControlService.toggleRecording(
        onResult: (result) {
          setState(() {
            text = result;
          });
        },
        onListening: (isListening) {
          setState(() {
            _isRecording = isListening;
          });
        },
      );
}
