// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:taskflow_ai/core/constants/app_theme.dart';
import 'package:taskflow_ai/features/tasks/domain/task_model.dart';
import 'package:taskflow_ai/features/tasks/application/task_providers.dart';
import 'package:taskflow_ai/features/tasks/presentation/screens/add_edit_task_screen.dart';

class TaskTile extends ConsumerWidget {
  final Task task;
  const TaskTile({required this.task, super.key});

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: isDarkMode
          ? theme.colorScheme.surfaceContainerHighest
          : theme.colorScheme.surface,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: 16.0,
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => AddEditTaskScreen(task: task)),
          );
        },
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (bool? value) {
            final updatedTask = task.copyWith(isCompleted: value ?? false);
            ref
                .read(taskControllerProvider.notifier)
                .updateTask(
                  updatedTask: updatedTask,
                  onError: (error) => _showErrorSnackbar(context, error),
                );
          },
          activeColor: AppTheme.primaryColor,
          shape: const CircleBorder(),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            fontWeight: FontWeight.bold,
            color: isDarkMode
                ? theme.colorScheme.onSurfaceVariant
                : theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            DateFormat.yMMMd().add_jm().format(task.dueDate),
            style: TextStyle(
              color: task.dueDate.isBefore(DateTime.now()) && !task.isCompleted
                  ? Colors.red.shade400
                  : (isDarkMode
                        ? theme.colorScheme.onSurfaceVariant.withOpacity(0.7)
                        : theme.colorScheme.onSurface.withOpacity(0.7)),
            ),
          ),
        ),
        trailing: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: AppTheme.priorityColor(task.priority),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDarkMode ? Colors.white70 : Colors.black26,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}
