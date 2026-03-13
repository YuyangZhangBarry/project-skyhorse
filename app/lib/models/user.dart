enum UserTier {
  free,
  premium;

  factory UserTier.fromJson(String value) {
    return switch (value) {
      'premium' => UserTier.premium,
      _ => UserTier.free,
    };
  }

  String toJson() => name;
}

class User {
  final String id;
  final String nickname;
  final String email;
  final String? avatarUrl;
  final UserTier tier;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.nickname,
    required this.email,
    this.avatarUrl,
    this.tier = UserTier.free,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
      tier: UserTier.fromJson(json['tier'] as String? ?? 'free'),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'email': email,
      'avatar_url': avatarUrl,
      'tier': tier.toJson(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
