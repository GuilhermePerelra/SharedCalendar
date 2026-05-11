class EventShare {
  final String id;
  final String eventId;
  final String userId;

  EventShare({
    required this.id,
    required this.eventId,
    required this.userId,
  });

  factory EventShare.fromJson(Map<String, dynamic> json) {
    return EventShare(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      userId: json['user_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'user_id': userId,
    };
  }
}
