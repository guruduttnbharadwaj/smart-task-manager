import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ✅ Render backend URL (NO trailing slash)
  static const String baseUrl =
      'https://smart-task-manager-api-pvlf.onrender.com/api/tasks';

  // =========================
  // GET TASKS (OPTIONAL STATUS FILTER)
  // =========================
  static Future<List<dynamic>> fetchTasks({String? status}) async {
    final uri = status == null
        ? Uri.parse(baseUrl)
        : Uri.parse('$baseUrl?status=$status');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  // =========================
  // CREATE TASK
  // =========================
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

  // =========================
  // UPDATE TASK (EDIT / COMPLETE)
  // =========================
  static Future<void> updateTask({
    required String id,
    required String title,
    required String description,
    required String assignedTo,
    String status = 'pending',
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'title': title,
        'description': description,
        'assigned_to': assignedTo,
        'status': status,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update task');
    }
  }

  // =========================
  // DELETE TASK
  // =========================
  static Future<void> deleteTask(String taskId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$taskId'),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete task');
    }
  }
}
