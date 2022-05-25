class Todo {
  int? id;
  String name;
  String? description;
  String? completeBy;
  int? priority;

  Todo({
    required this.name,
    this.description,
    this.completeBy,
    this.priority,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'completeBy': completeBy,
      'priority': priority,
    };
  }

  static Todo fromMap(Map<String, dynamic> map) {
    return Todo(
      name: map['name'],
      description: map['description'],
      completeBy: map['completeBy'],
      priority: map['priority'],
    );
  }
}
