class ShareRequest {
  final int id;
  final String senderId;
  final String senderUsername;
  final String senderLogin;
  final String receiverId;
  final String status;
  final DateTime createdAt;

  ShareRequest({
    required this.id,
    required this.senderId,
    required this.senderUsername,
    required this.senderLogin,
    required this.receiverId,
    required this.status,
    required this.createdAt,
  });

  factory ShareRequest.fromJson(Map<String, dynamic> json) {
    return ShareRequest(
      id: json['id'] as int,
      senderId: json['sender_id'] as String,
      senderUsername: json['users']?['username'] as String? ?? 'Desconhecido',
      senderLogin: json['users']?['login'] as String? ?? '',
      receiverId: json['receiver_id'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
