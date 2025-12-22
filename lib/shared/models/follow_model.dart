class FollowModel {
  final String id;
  final DateTime createdAt;
  final FollowUser targetUser;
  final FollowUser me;

  FollowModel({
    required this.id,
    required this.createdAt,
    required this.targetUser,
    required this.me,
  });

  factory FollowModel.fromJson(Map<String, dynamic> json) {
    return FollowModel(
      id: json['id'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      // Expecting joins to return 'targetUser' and 'me' objects using aliases
      targetUser: FollowUser.fromJson(json['targetUser'] ?? {}),
      me: FollowUser.fromJson(json['me'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id, // Supabase generates ID usually
      'follower_id': me.id,
      'following_id': targetUser.id,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class FollowUser {
  final String id;
  final String name;
  final String userName;
  final String image;
  final String userToken;

  FollowUser({
    required this.id,
    required this.name,
    required this.userName,
    required this.image,
    required this.userToken,
  });

  factory FollowUser.fromJson(Map<String, dynamic> json) {
    return FollowUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      // Check for different casing conventions
      userName: json['username'] ?? json['user_name'] ?? json['userName'] ?? '',
      image: json['image'] ?? '',
      userToken: json['token'] ?? json['userToken'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'userName': userName,
      'image': image,
      'userToken': userToken,
    };
  }
}
