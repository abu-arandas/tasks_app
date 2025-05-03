class Task {
  final String id;
  String title;
  String? description;
  bool isCompleted;
  DateTime? dueDate;
  String? priority; // 'low', 'medium', 'high'
  List<String> tagIds;
  List<Task>? subtasks;
  bool isRecurring;
  String? recurrencePattern; // 'daily', 'weekly', 'monthly', 'custom'
  DateTime createdAt;
  DateTime updatedAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.dueDate,
    this.priority = 'medium',
    this.tagIds = const [],
    this.subtasks,
    this.isRecurring = false,
    this.recurrencePattern,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create a Task from JSON data
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isCompleted: json['isCompleted'] ?? false,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      priority: json['priority'] ?? 'medium',
      tagIds: List<String>.from(json['tagIds'] ?? []),
      subtasks: json['subtasks'] != null
          ? List<Task>.from(
              json['subtasks'].map((x) => Task.fromJson(x)),
            )
          : null,
      isRecurring: json['isRecurring'] ?? false,
      recurrencePattern: json['recurrencePattern'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Convert Task to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority,
      'tagIds': tagIds,
      'subtasks': subtasks?.map((x) => x.toJson()).toList(),
      'isRecurring': isRecurring,
      'recurrencePattern': recurrencePattern,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create a copy of the task with updated fields
  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? dueDate,
    String? priority,
    List<String>? tagIds,
    List<Task>? subtasks,
    bool? isRecurring,
    String? recurrencePattern,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      tagIds: tagIds ?? this.tagIds,
      subtasks: subtasks ?? this.subtasks,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrencePattern: recurrencePattern ?? this.recurrencePattern,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
