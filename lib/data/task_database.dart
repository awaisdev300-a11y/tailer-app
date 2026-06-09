// lib/data/task_database.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';

class TaskDatabase {
  static List<TaskModel> tasks = [];

  static CollectionReference get _collection {
    final user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid ?? 'guest_data')
        .collection('tasks');
  }

  // --- LOAD LIVE DATA ---
  static Future<void> loadData() async {
    _collection.snapshots().listen((snapshot) {
      tasks = snapshot.docs.map((doc) {
        return TaskModel.fromJson(
          doc.data() as Map<String, dynamic>,
          docId: doc.id,
        );
      }).toList();

      // Sort by Due Date (Closest first)
      tasks.sort((a, b) => b.date.compareTo(a.date));
      print("Synced ${tasks.length} tasks from Cloud");
    });
  }

  static Future<void> addTask(TaskModel task) async {
    await _collection.add(task.toJson());
  }

  static Future<void> updateTask(TaskModel oldTask, TaskModel newTask) async {
    if (oldTask.id == null) return;
    await _collection.doc(oldTask.id).update(newTask.toJson());
  }

  static Future<void> deleteTask(TaskModel task) async {
    if (task.id == null) return;
    await _collection.doc(task.id).delete();
  }
}
