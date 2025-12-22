class LikeModel {
  final String id;
  final String questionId;
  final DateTime createdAt;
  final LikeUser user;

  LikeModel({
    required this.id,
    required this.questionId,
    required this.createdAt,
    required this.user,
  });

  factory LikeModel.fromJson(Map<String, dynamic> json) {
    // Prefer joined 'users' table data if available (fresh), otherwise fallback to snapshot 'user_data'
    final userData = json['users'] ?? json['user_data'] ?? {};

    return LikeModel(
      id: json['id'].toString(), // Supabase id is int/bigint
      questionId: json['question_id'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : DateTime.now(),
      user: LikeUser.fromJson(userData),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'user_id': user.id,
      'created_at': createdAt.toIso8601String(),
      'user_data': user.toJson(),
    };
  }
}

class LikeUser {
  final String id;
  final String name;
  final String userName;
  final String image;
  final String token;

  LikeUser({
    required this.id,
    required this.name,
    required this.userName,
    required this.image,
    required this.token,
  });

  factory LikeUser.fromJson(Map<String, dynamic> json) {
    return LikeUser(
      id: json['id'] ?? '',
      name: json['name'] ?? json['full_name'] ?? '',
      userName: json['userName'] ?? json['username'] ?? json['user_name'] ?? '',
      image: json['image'] ?? json['avatar_url'] ?? '',
      token: json['token'] ?? json['fcm_token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'userName': userName,
      'image': image,
      'token': token,
    };
  }
}
