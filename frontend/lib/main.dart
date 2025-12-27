import 'package:flutter/material.dart';
import 'services/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<dynamic>> tasks;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _assignedController = TextEditingController();

  String? editingTaskId;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    tasks = ApiService.fetchTasks();
  }

  void _refreshTasks() {
    setState(() {
      _loadTasks();
    });
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _openTaskDialog({Map<String, dynamic>? task}) {
    if (task != null) {
      editingTaskId = task['id'];
      _titleController.text = task['title'];
      _descController.text = task['description'] ?? '';
      _assignedController.text = task['assigned_to'] ?? '';
    } else {
      editingTaskId = null;
      _titleController.clear();
      _descController.clear();
      _assignedController.clear();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(editingTaskId == null ? 'Create Task' : 'Edit Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _assignedController,
              decoration: const InputDecoration(labelText: 'Assigned To'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (editingTaskId == null) {
                await ApiService.createTask(
                  title: _titleController.text,
                  description: _descController.text,
                  assignedTo: _assignedController.text,
                );
              } else {
                await ApiService.updateTask(
                  id: editingTaskId!,
                  title: _titleController.text,
                  description: _descController.text,
                  assignedTo: _assignedController.text,
                );
              }
              Navigator.pop(context);
              _refreshTasks();
            },
            child: Text(editingTaskId == null ? 'Create' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String taskId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await ApiService.deleteTask(taskId);
              Navigator.pop(context);
              _refreshTasks();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _markCompleted(Map<String, dynamic> task) async {
    await ApiService.updateTask(
      id: task['id'],
      title: task['title'],
      description: task['description'],
      assignedTo: task['assigned_to'],
      status: 'completed',
    );
    _refreshTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Task Manager'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: tasks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final task = data[index];
              final isCompleted = task['status'] == 'completed';

              return Card(
                elevation: 3,
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TITLE + PRIORITY
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              task['title'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  _priorityColor(task['priority']),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              task['priority'].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Text(task['description'] ?? ''),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          const Icon(Icons.person, size: 14),
                          const SizedBox(width: 4),
                          Text(task['assigned_to'],
                              style: const TextStyle(fontSize: 12)),
                          const Spacer(),
                          Chip(
                            label: Text(task['status']),
                            backgroundColor: isCompleted
                                ? Colors.green.shade100
                                : Colors.grey.shade200,
                          ),
                        ],
                      ),

                      const Divider(),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () =>
                                _openTaskDialog(task: task),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.check_circle,
                              color:
                                  isCompleted ? Colors.green : Colors.grey,
                            ),
                            onPressed: isCompleted
                                ? null
                                : () => _markCompleted(task),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red),
                            onPressed: () =>
                                _confirmDelete(task['id']),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openTaskDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
