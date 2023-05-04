class Task {
  int id;
  String title;
  String description;
  int sprintId;
  String status;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.sprintId,
    required this.status,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      sprintId: json['sprintId'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'sprintId': sprintId,
      'status': status,
    };
  }
}
