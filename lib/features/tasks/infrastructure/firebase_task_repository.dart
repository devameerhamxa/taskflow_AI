import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taskflow_ai/features/tasks/domain/task_model.dart';
import 'package:taskflow_ai/features/tasks/domain/task_repository.dart';

class FirebaseTaskRepository implements TaskRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  FirebaseTaskRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  // Helper to get the current user's ID.
  String? get _userId => _firebaseAuth.currentUser?.uid;

  // Helper to get the reference to the user's tasks sub-collection.
  CollectionReference<Map<String, dynamic>> _tasksCollection() {
    if (_userId == null) throw Exception('User not logged in');
    return _firestore.collection('users').doc(_userId).collection('tasks');
  }

  @override
  Stream<List<Task>> watchAllTasks() {
    return _tasksCollection()
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Task.fromSnapshot(doc)).toList();
        });
  }

  @override
  Future<void> createTask(Task task) {
    // We use the task's toJson method but add server timestamps.
    final taskData = task.toJson()
      ..['createdAt'] = FieldValue.serverTimestamp()
      ..['updatedAt'] = FieldValue.serverTimestamp();

    return _tasksCollection().doc(task.id).set(taskData);
  }

  @override
  Future<void> updateTask(Task task) {
    final taskData = task.toJson()
      ..['updatedAt'] = FieldValue.serverTimestamp();

    return _tasksCollection().doc(task.id).update(taskData);
  }

  @override
  Future<void> deleteTask(String taskId) {
    return _tasksCollection().doc(taskId).delete();
  }
}
