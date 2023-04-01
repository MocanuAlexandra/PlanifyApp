import 'package:planify_app/helpers/utility.dart';

import '../models/task.dart';

class TextProcessingService {
  /// This method processes the text that is passed to it and returns a Task object
  static Task? processText(String inputText) {
    // eliminate the prepositions from inputText
    inputText = inputText.replaceAll(RegExp(r'(a|an|the|on|in)\s'), '');

    //define the regex
    final regex = RegExp(
        r'^(add|insert|put|go|go to|go for)\s+(\w+)\s+((January|February|March|April|May|June|July|August|September|October|November|December|january|february|march|april|may|june|july|august|september|october|november|december)\s+\d{1,2}(?:st|nd|rd|th)?(?: \d{4})?)$');

    // find the match
    final match = regex.firstMatch(inputText);

    if (match != null) {
      // the name of the task
      final taskName = match.group(2);

      // the due date
      final dueDateGroup = match.group(3);
      final dueDate = Utility.getStringDueDateFromVoiceInput(dueDateGroup!);

      //create the Task object
      final newTask = Task(
        title: taskName,
        dueDate: dueDate,
      );

      return newTask;
    } else {
      //TODO handle the case when the input text doesn't match the regex
      return null;
    }
  }
}
