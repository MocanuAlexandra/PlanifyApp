import 'package:flutter/material.dart';

import 'task_address.dart';

enum Priority { casual, necessary, important, unknown }

class Task {
  final String? id;
  final String? title;
  final DateTime? dueDate;
  final TimeOfDay? dueTime;
  final TaskAddress? address;
  final Priority? priority;
  bool isDone;
  bool isDeleted;
  final String? category;
  final String? locationCategory;
  final String? owner;
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
