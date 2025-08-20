
// ignore_for_file: unintended_html_in_doc_comment

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// A custom enum to define the priority levels for a task.
/// Using an enum makes the code safer and more readable than using raw integers.
enum TaskPriority { low, medium, high }

/// The core data model for a task in the TaskFlow AI app.
/// This class is immutable, which is a best practice in Flutter/Riverpod.
@immutable
class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;
  final TaskPriority priority;
  final String? projectId; // Can be null if not assigned to a project
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    this.projectId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a copy of the current Task instance with updated fields.
  /// This is useful for updating the state of a task without mutating the original.
  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    TaskPriority? priority,
    String? projectId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      projectId: projectId ?? this.projectId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converts a Task object into a Map<String, dynamic> format for Firestore.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'isCompleted': isCompleted,
      'priority': priority.name, // Store enum as a string (e.g., 'high')
      'projectId': projectId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Creates a Task object from a Firestore document snapshot.
  factory Task.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      isCompleted: data['isCompleted'] ?? false,
      // Convert string back to enum, defaulting to medium if invalid
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == data['priority'],
        orElse: () => TaskPriority.medium,
      ),
      projectId: data['projectId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}