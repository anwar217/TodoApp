import 'package:todoapp/models/task.dart';

class Sprint {
  int id;
  String name;
  DateTime startDate;
  DateTime endDate;
  List<Task> tasks;

  Sprint({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.tasks,
  });

  factory Sprint.fromJson(Map<String, dynamic> json) {
    List<dynamic> taskJsonList = json['tasks'] ?? [];
    List<Task> tasks =
        taskJsonList.map((taskJson) => Task.fromJson(taskJson)).toList();

    return Sprint(
      id: json['id'],
      name: json['name'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      tasks: tasks,
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> taskJsonList =
        tasks.map((task) => task.toJson()).toList();

    return {
      'id': id,
      'name': name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'tasks': taskJsonList,
    };
  }
}
