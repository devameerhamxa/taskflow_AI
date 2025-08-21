import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_ai/features/tasks/domain/task_model.dart';
import 'package:taskflow_ai/features/tasks/domain/task_repository.dart';
import 'package:taskflow_ai/features/tasks/infrastructure/firebase_task_repository.dart';
import 'package:uuid/uuid.dart';

// 1. Repository Provider
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return FirebaseTaskRepository();
});

// 2. Tasks Stream Provider
// Provides a real-time stream of the user's tasks.
final tasksStreamProvider = StreamProvider<List<Task>>((ref) {
  final taskRepository = ref.watch(taskRepositoryProvider);
  return taskRepository.watchAllTasks();
});

// 3. Task Controller Provider (StateNotifier)
// Manages business logic like creating, updating, and deleting tasks.
final taskControllerProvider = StateNotifierProvider<TaskController, bool>((
  ref,
) {
  final taskRepository = ref.watch(taskRepositoryProvider);
  return TaskController(taskRepository: taskRepository, ref: ref);
});

class TaskController extends StateNotifier<bool> {
  final TaskRepository _taskRepository;
  final Ref _ref;

  TaskController({required TaskRepository taskRepository, required Ref ref})
    : _taskRepository = taskRepository,
      _ref = ref,
      super(false); // State represents loading status

  Future<void> createTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required TaskPriority priority,
    required Function(String) onError,
  }) async {
    state = true;
    try {
      final newTask = Task(
        id: const Uuid().v4(), // Generate a unique ID
        title: title,
        description: description,
        dueDate: dueDate,
        priority: priority,
        createdAt: DateTime.now(), // Will be overwritten by server timestamp
        updatedAt: DateTime.now(), // Will be overwritten by server timestamp
      );
      await _taskRepository.createTask(newTask);

      // Refresh the tasks stream to show the new task immediately
      _ref.invalidate(tasksStreamProvider);
    } catch (e) {
      onError(e.toString());
    } finally {
      state = false;
    }
  }

  Future<void> updateTask({
    required Task updatedTask,
    required Function(String) onError,
  }) async {
    state = true;
    try {
      await _taskRepository.updateTask(updatedTask);

      // Refresh the tasks stream to show updated data
      _ref.invalidate(tasksStreamProvider);
    } catch (e) {
      onError(e.toString());
    } finally {
      state = false;
    }
  }

  Future<void> deleteTask({
    required String taskId,
    required Function(String) onError,
  }) async {
    state = true;
    try {
      await _taskRepository.deleteTask(taskId);

      // Refresh the tasks stream to remove deleted task from UI
      _ref.invalidate(tasksStreamProvider);
    } catch (e) {
      onError(e.toString());
    } finally {
      state = false;
    }
  }
}
