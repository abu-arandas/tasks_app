class Tag {
  final String id;
  String name;
  String color; // Hex color code
  DateTime createdAt;

  Tag({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
  });

  // Create a Tag from JSON data
  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'],
      name: json['name'],
      color: json['color'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Convert Tag to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create a copy of the tag with updated fields
  Tag copyWith({
    String? id,
    String? name,
    String? color,
    DateTime? createdAt,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
