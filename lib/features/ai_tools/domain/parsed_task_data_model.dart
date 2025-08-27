import 'package:flutter/foundation.dart';
import 'package:taskflow_ai/features/tasks/domain/task_model.dart';

@immutable
class ParsedTaskData {
  final String title;
  final DateTime? dueDate;
  final TaskPriority priority;

  const ParsedTaskData({
    required this.title,
    this.dueDate,
    this.priority = TaskPriority.medium,
  });

  // A factory constructor to create ParsedTaskData from a JSON map
  // that we expect to receive from the Gemini API.
  factory ParsedTaskData.fromJson(Map<String, dynamic> json) {
    // Safely parse the due date
    DateTime? parsedDueDate;
    if (json['dueDate'] != null && json['dueDate'].isNotEmpty) {
      try {
        parsedDueDate = DateTime.parse(json['dueDate']);
      } catch (e) {
        // If parsing fails, leave it as null
        parsedDueDate = null;
      }
    }

    // Safely parse the priority
    TaskPriority parsedPriority = TaskPriority.values.firstWhere(
      (e) => e.name == json['priority'],
      orElse: () => TaskPriority.medium,
    );

    return ParsedTaskData(
      title: json['title'] ?? 'Untitled Task',
      dueDate: parsedDueDate,
      priority: parsedPriority,
    );
  }
}
