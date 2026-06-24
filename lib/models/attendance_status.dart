class AttendanceStatus {
  final int? id;
  final int eventId;
  final String userId;
  final String username;
  final String login;
  final String status; // 'pending' | 'confirmed' | 'declined'
  final String visibility; // 'public' | 'private'

  AttendanceStatus({
    this.id,
    required this.eventId,
    required this.userId,
    required this.username,
    required this.login,
    required this.status,
    this.visibility = 'public',
  });

  factory AttendanceStatus.fromJson(Map<String, dynamic> json) {
    return AttendanceStatus(
      id: json['id'] as int?,
      eventId: json['event_id'] as int,
      userId: json['user_id'] as String,
      username: json['users']?['username'] as String? ?? 'Desconhecido',
      login: json['users']?['login'] as String? ?? '',
      status: json['status'] as String,
      visibility: json['visibility'] as String? ?? 'public',
    );
  }

  AttendanceStatus copyWith({String? status, String? visibility}) {
    return AttendanceStatus(
      id: id,
      eventId: eventId,
      userId: userId,
      username: username,
      login: login,
      status: status ?? this.status,
      visibility: visibility ?? this.visibility,
    );
  }
}
