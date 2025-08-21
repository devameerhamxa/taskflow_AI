import 'package:taskflow_ai/features/tasks/domain/task_model.dart';

abstract class TaskRepository {
  // Stream to get all tasks for the current user in real-time.
  Stream<List<Task>> watchAllTasks();

  // Create a new task.
  Future<void> createTask(Task task);

  // Update an existing task.
  Future<void> updateTask(Task task);

  // Delete a task by its ID.
  Future<void> deleteTask(String taskId);
}
