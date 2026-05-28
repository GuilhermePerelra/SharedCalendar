class AttendanceStatus {
  final int? id;
  final int eventId;
  final String userId;
  final String username;
  final String login;
  final String status; // 'pending' | 'confirmed' | 'declined'

  AttendanceStatus({
    this.id,
    required this.eventId,
    required this.userId,
    required this.username,
    required this.login,
    required this.status,
  });

  factory AttendanceStatus.fromJson(Map<String, dynamic> json) {
    return AttendanceStatus(
      id: json['id'] as int?,
      eventId: json['event_id'] as int,
      userId: json['user_id'] as String,
      username: json['users']?['username'] as String? ?? 'Desconhecido',
      login: json['users']?['login'] as String? ?? '',
      status: json['status'] as String,
    );
  }
}
