import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:personaltaskmanagerapp/model/task_model.dart';
import 'package:personaltaskmanagerapp/services/database_services.dart';

class PendingWidget extends StatefulWidget {
  const PendingWidget({super.key});

  @override
  State<PendingWidget> createState() => _PendingWidgetState();
}

class _PendingWidgetState extends State<PendingWidget> {
  User? user = FirebaseAuth.instance.currentUser;
  late String uid;

  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    // Task:implement initstate
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Task>>(
        stream: _databaseService.tasks,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Task> tasks = snapshot.data!;
            return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  Task task = tasks[index];
                  final DateTime dt = task.timeStamp.toDate();
                  return Container(
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Slidable(
                        key: ValueKey(task.id),
                        endActionPane: ActionPane(
                          motion: DrawerMotion(),
                          children: [
                            SlidableAction(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                icon: Icons.done,
                                label: "Mark",
                                onPressed: (context) {
                                  _databaseService.updateTaskStatus(
                                      task.id, true);
                                })
                          ],
                        ),
                        startActionPane: ActionPane(
                          motion: DrawerMotion(),
                          children: [
                            SlidableAction(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.white,
                                icon: Icons.edit,
                                label: "Edit",
                                onPressed: (context) {
                                  _showTaskDialog(context, task: task);
                                }),
                            SlidableAction(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: "Delete",
                                onPressed: (context) async {
                                  await _databaseService.deleteTask(task.id);
                                })
                          ],
                        ),
                        child: ListTile(
                          title: Text(
                            task.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            task.description,
                          ),
                          trailing: Text(
                            '${dt.day}/${dt.month}/${dt.year}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ));
                });
          } else {
            return Center(
                child: CircularProgressIndicator(
              color: Colors.white,
            ));
          }
        });
  }

  void _showTaskDialog(BuildContext context, {Task? task}) {
    final TextEditingController _titleController =
        TextEditingController(text: task?.title);
    final TextEditingController _descriptionController =
        TextEditingController(text: task?.description);
          String _selectedPriority = task?.priority ?? "Low";  // Default to "Low"
    final DatabaseService _databaseService = DatabaseService();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            task == null ? "Add Task" : "Edit Task",
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          content: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: "Title",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: "Description",
                      border: OutlineInputBorder(),
                    ),
                  ),
                   SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedPriority,
                  decoration: InputDecoration(
                    labelText: "Priority",
                    border: OutlineInputBorder(),
                  ),
                  items: ["Low", "Medium", "High"]
                      .map((priority) => DropdownMenuItem<String>(
                            value: priority,
                            child: Text(priority),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPriority = value!;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
               
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (task == null) {
                  await _databaseService.addTask(
                      _titleController.text, _descriptionController.text, _selectedPriority);
                } else {
                  await _databaseService.updateTask(task.id,
                      _titleController.text, _descriptionController.text, _selectedPriority);
                }
                Navigator.pop(context);
              },
              child: Text(task == null ? "Add" : "Update"),
            ),
          ],
        );
      },
    );
  }
}
