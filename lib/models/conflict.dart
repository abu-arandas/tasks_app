class Conflict {
  final String id;
  final String entityId;
  final String entityType; // 'task', 'tag', 'reminder'
  final Map<String, dynamic> localData;
  final Map<String, dynamic> remoteData;
  final DateTime createdAt;
  bool resolved;

  Conflict({
    required this.id,
    required this.entityId,
    required this.entityType,
    required this.localData,
    required this.remoteData,
    required this.createdAt,
    this.resolved = false,
  });

  // Create a Conflict from JSON data
  factory Conflict.fromJson(Map<String, dynamic> json) {
    return Conflict(
      id: json['id'],
      entityId: json['entityId'],
      entityType: json['entityType'],
      localData: Map<String, dynamic>.from(json['localData']),
      remoteData: Map<String, dynamic>.from(json['remoteData']),
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is DateTime ? json['createdAt'] : DateTime.parse(json['createdAt']))
          : DateTime.now(),
      resolved: json['resolved'] ?? false,
    );
  }

  // Convert Conflict to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entityId': entityId,
      'entityType': entityType,
      'localData': localData,
      'remoteData': remoteData,
      'createdAt': createdAt.toIso8601String(),
      'resolved': resolved,
    };
  }

  // Create a copy of the conflict with updated fields
  Conflict copyWith({
    String? id,
    String? entityId,
    String? entityType,
    Map<String, dynamic>? localData,
    Map<String, dynamic>? remoteData,
    DateTime? createdAt,
    bool? resolved,
  }) {
    return Conflict(
      id: id ?? this.id,
      entityId: entityId ?? this.entityId,
      entityType: entityType ?? this.entityType,
      localData: localData ?? this.localData,
      remoteData: remoteData ?? this.remoteData,
      createdAt: createdAt ?? this.createdAt,
      resolved: resolved ?? this.resolved,
    );
  }
}
