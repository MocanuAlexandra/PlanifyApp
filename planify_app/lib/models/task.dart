import 'package:flutter/material.dart';

import 'task_address.dart';

enum Priority { casual, necessary, important, unknown }

class Task {
  final String? id;
  final String? title;
  final DateTime? dueDate;
  final TimeOfDay? time;
  final TaskAddress? address;
  final Priority? priority;
  bool isDone;
  bool isDeleted;

  Task({
    this.id,
    this.title,
    this.dueDate,
    this.time,
    this.address,
    this.priority,
    this.isDone = false,
    this.isDeleted = false,
  });
}
