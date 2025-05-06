class TaskSuggestion {
  final String title;
  final String? description;
  final String? priority; // 'low', 'medium', 'high'
  final List<String> tagIds;
  final double confidence; // 0.0 to 1.0 representing ML confidence

  TaskSuggestion({
    required this.title,
    this.description,
    this.priority = 'medium',
    this.tagIds = const [],
    required this.confidence,
  });

  // Create a TaskSuggestion from JSON data
  factory TaskSuggestion.fromJson(Map<String, dynamic> json) {
    return TaskSuggestion(
      title: json['title'],
      description: json['description'],
      priority: json['priority'] ?? 'medium',
      tagIds: List<String>.from(json['tagIds'] ?? []),
      confidence: json['confidence'] ?? 0.5,
    );
  }

  // Convert TaskSuggestion to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'priority': priority,
      'tagIds': tagIds,
      'confidence': confidence,
    };
  }
}
