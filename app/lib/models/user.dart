class User {
  final String id;
  final String nickname;
  final String email;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.nickname,
    required this.email,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      nickname: json['nickname'] as String,
      email: json['email'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
