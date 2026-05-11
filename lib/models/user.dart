class User {
  final String id;
  final String? username;
  final String password;
  final String login;

  User({
    required this.id,
    this.username,
    required this.password,
    required this.login,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String?,
      password: json['password'] as String,
      login: json['login'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'login': login,
    };
  }
}
