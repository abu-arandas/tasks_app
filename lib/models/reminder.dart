class Reminder {
  final String id;
  final String taskId;
  DateTime reminderTime;
  bool isRepeating;
  String? repeatPattern; // 'daily', 'weekly', 'monthly'
  bool isDismissed;
  bool isSnoozing;
  DateTime? snoozeUntil;

  Reminder({
    required this.id,
    required this.taskId,
    required this.reminderTime,
    this.isRepeating = false,
    this.repeatPattern,
    this.isDismissed = false,
    this.isSnoozing = false,
    this.snoozeUntil,
  });

  // Create a Reminder from JSON data
  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'],
      taskId: json['taskId'],
      reminderTime: DateTime.parse(json['reminderTime']),
      isRepeating: json['isRepeating'] ?? false,
      repeatPattern: json['repeatPattern'],
      isDismissed: json['isDismissed'] ?? false,
      isSnoozing: json['isSnoozing'] ?? false,
      snoozeUntil: json['snoozeUntil'] != null ? DateTime.parse(json['snoozeUntil']) : null,
    );
  }

  // Convert Reminder to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'reminderTime': reminderTime.toIso8601String(),
      'isRepeating': isRepeating,
      'repeatPattern': repeatPattern,
      'isDismissed': isDismissed,
      'isSnoozing': isSnoozing,
      'snoozeUntil': snoozeUntil?.toIso8601String(),
    };
  }

  // Create a copy of the reminder with updated fields
  Reminder copyWith({
    String? id,
    String? taskId,
    DateTime? reminderTime,
    bool? isRepeating,
    String? repeatPattern,
    bool? isDismissed,
    bool? isSnoozing,
    DateTime? snoozeUntil,
  }) {
    return Reminder(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      reminderTime: reminderTime ?? this.reminderTime,
      isRepeating: isRepeating ?? this.isRepeating,
      repeatPattern: repeatPattern ?? this.repeatPattern,
      isDismissed: isDismissed ?? this.isDismissed,
      isSnoozing: isSnoozing ?? this.isSnoozing,
      snoozeUntil: snoozeUntil ?? this.snoozeUntil,
    );
  }
}
