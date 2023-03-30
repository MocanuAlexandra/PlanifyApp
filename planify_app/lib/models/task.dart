import 'package:flutter/material.dart';

import 'task_address.dart';

enum Priority { casual, necessary, important, unknown }

class Task {
  final String? id;
  String? title;
  DateTime? dueDate;
  TimeOfDay? dueTime;
  TaskAddress? address;
  Priority? priority;
  bool isDone;
  bool isDeleted;
  String? category;
  String? locationCategory;
  String? owner;
  String? imageUrl;

  Task({
    this.id,
    this.title,
    this.dueDate,
    this.dueTime,
    this.address,
    this.priority,
    this.isDone = false,
    this.isDeleted = false,
    this.category,
    this.locationCategory,
    this.owner,
    this.imageUrl,
  });
}
