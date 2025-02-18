import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final String priority;
  final bool completed;
  final Timestamp timeStamp;
  

  Task(
      {required this.id,
      required this.title,
      required this.description,
       required this.priority,
      required this.completed,
      required this.timeStamp,
     
      });
}
