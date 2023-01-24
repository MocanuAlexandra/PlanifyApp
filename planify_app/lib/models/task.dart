import 'package:flutter/material.dart';
import 'package:planify_app/models/task_adress.dart';

enum Priority { casual, necessary, important, unknown }

class Task {
  final String? id;
  final String? title;
  final DateTime? dueDate;
  final TimeOfDay? time;
  final TaskAdress? address;
  final Priority? priority;
  bool isDone;

  Task({
    this.id,
    this.title,
    this.dueDate,
    this.time,
    this.address,
    this.priority,
    this.isDone = false,
  });
}
