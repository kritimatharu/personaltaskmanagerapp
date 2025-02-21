import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/scheduler.dart';
import 'package:personaltaskmanagerapp/model/task_model.dart';

class DatabaseService {
  final CollectionReference taskCollection =
      FirebaseFirestore.instance.collection("tasks");

  User? user = FirebaseAuth.instance.currentUser;

  // Add task
  Future<DocumentReference> addTask(String title, String description, String priority) async {
    return await taskCollection.add({
      'uid': user!.uid,
      'title': title,
      'description': description,
      'priority': priority,
      'completed': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  //update  task
  Future<void> updateTask(String id, String title, String description, String priority) async {
    final updatetaskCollection =
        FirebaseFirestore.instance.collection("tasks").doc(id);
    return await updatetaskCollection.update({
      'title': title,
      'description': description,
      'priority':priority,

    });
  }

  //update task status
  Future<void> updateTaskStatus(String id, bool completed) async {
    return await taskCollection.doc(id).update({
      'completed': completed,
    });
  }

  // delete task
  Future<void> deleteTask(String id) async {
    return await taskCollection.doc(id).delete();
  }

  //get pending task
  Stream<List<Task>> get tasks {
    return taskCollection
        .where('uid', isEqualTo: user!.uid)
        .where('completed', isEqualTo: false)
        .snapshots()
        .map(_taskListFromSnapshot);
  }

  //get completed task
  Stream<List<Task>> get completedtasks {
    return taskCollection
        .where('uid', isEqualTo: user!.uid)
        .where('completed', isEqualTo: true)
        .snapshots()
        .map(_taskListFromSnapshot);
  }

  List<Task> _taskListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Task(

          id: doc.id,
          title: doc['title'] ?? '',
          description: doc['description'] ?? '',
         priority: doc['priority'] ?? 'low',
          completed: doc['completed'] ?? '',
          timeStamp: doc['createdAt'] ?? '');
          
    }).toList();
  }
}
