import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  //  REPLACE WITH YOUR RENDER BACKEND URL
  static const String baseUrl =
      'https://smart-task-manager-api-pvlf.onrender.com/api/tasks/';

  // GET all tasks
  static Future<List<dynamic>> fetchTasks() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  // CREATE task
  static Future<void> createTask({
    required String title,
    required String description,
    required String assignedTo,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'title': title,
        'description': description,
        'assigned_to': assignedTo,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create task');
    }
  }

  // DELETE task
  static Future<void> deleteTask(String taskId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$taskId'),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete task');
    }
  }
}
