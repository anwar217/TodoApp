import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:todoapp/models/sprint.dart';
import 'package:todoapp/models/task.dart';

class Api {
  static const String baseUrl = 'http://localhost:3000';

  static Future<List<dynamic>> getSprints() async {
    final response = await http.get(Uri.parse('$baseUrl/sprints'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load sprints');
    }
  }

  static Future<List<dynamic>> getTasks() async {
    final response = await http.get(Uri.parse('$baseUrl/tasks'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  // Ajouter un sprint
  static Future<Sprint> addSprint(Sprint sprint) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sprints'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(sprint.toJson()),
    );

    if (response.statusCode == 201) {
      final jsonSprint = json.decode(response.body);
      return Sprint.fromJson(jsonSprint);
    } else {
      throw Exception('Failed to add sprint');
    }
  }

  // Ajouter une tâche
  static Future<Task> addTask(Task task) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(task.toJson()),
    );

    if (response.statusCode == 201) {
      final jsonTask = json.decode(response.body);
      return Task.fromJson(jsonTask);
    } else {
      throw Exception('Failed to add task');
    }
  }

  // Supprimer un sprint
  static Future<void> deleteSprint(int sprintId) async {
    final response = await http.delete(Uri.parse('$baseUrl/sprints/$sprintId'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete sprint');
    }
  }
  


  // Supprimer une tâche
  static Future<void> deleteTask(int taskId) async {
    final response = await http.delete(Uri.parse('$baseUrl/tasks/$taskId'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete task');
    }
  }

  // Mettre à jour un sprint
  static Future<Sprint> updateSprint(Sprint sprint) async {
    final response = await http.put(
      Uri.parse('$baseUrl/sprints/${sprint.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(sprint.toJson()),
    );

    if (response.statusCode == 200) {
      final jsonSprint = json.decode(response.body);
      return Sprint.fromJson(jsonSprint);
    } else {
      throw Exception('Failed to update sprint');
    }
  }

  // Mettre à jour une tâche
  static Future<void> updateTask(Task task) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tasks/${task.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(task.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update task');
    }
  }

 
}