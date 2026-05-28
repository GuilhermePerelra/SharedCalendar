import 'event_category.dart';

class Event {
  final String id;
  final String title;
  final DateTime targetDate;
  final String? description;
  final EventCategory? category;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String createdBy;
  final String? createdByUsername;

  // futuramente adicionar:
  // final List<String> sharedWith;

  Event({
    required this.id,
    required this.title,
    required this.targetDate,
    this.description,
    this.category,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.createdByUsername,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    print('DEBUG event json: $json');
    return Event(
      id: json['id'].toString(),
      title: json['title'] as String,
      targetDate: DateTime.parse(json['target_date'] as String),
      description: json['description'] as String?,
      category: EventCategory.fromString(json['category'] as String?),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      createdBy: json['created_by'].toString(),
      createdByUsername: json['username'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'target_date': targetDate.toIso8601String(),
      'description': description,
      'created_by': createdBy,
    };
  }
}
