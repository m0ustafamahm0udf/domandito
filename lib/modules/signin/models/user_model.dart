class UserModel {
  final String id;
  final DateTime createdAt;

  final String name;
  final String bio;
  final String userName;
  final String phone;
  final String email;

  final bool isBlocked;
  final bool isVerified;

  final String provider; // google / email
  final String token;
  final bool upload;

  String image;
  final String appVersion;
  bool canAskedAnonymously;

  int followersCount;
  int followingCount;
  int postsCount;

  UserModel({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.userName,
    required this.phone,
    required this.email,
    required this.isBlocked,
    required this.isVerified,
    required this.provider,
    required this.token,
    required this.upload,
    required this.image,
    required this.appVersion,
    required this.followersCount,
    required this.followingCount,
    required this.bio,
    required this.canAskedAnonymously,

    required this.postsCount,
  });

  /// ---------------------------
  /// ⭐ From Firestore Document
  /// ---------------------------
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['id']?.toString() ?? '',
      createdAt: _parseTimestamp(data['created_at']),
      name: data['name'] ?? '',
      userName: data['username'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      isBlocked: data['is_blocked'] ?? false,
      isVerified: data['is_verified'] ?? false,
      provider: data['provider'] ?? '',
      token: data['token'] ?? '',
      upload: data['upload'] ?? false,
      image: data['image'] ?? '',
      appVersion: data['app_version'] ?? '',
      followersCount: data['followers_count'] ?? 0,
      followingCount: data['following_count'] ?? 0,
      bio: data['bio'] ?? '',
      postsCount: data['posts_count'] ?? 0,
      canAskedAnonymously: data['can_asked_anonymously'] ?? true,
    );
  }

  /// ---------------------------
  /// ⭐ From JSON (optional use)
  /// ---------------------------
  factory UserModel.fromJson(Map<String, dynamic> data, String docId) {
    return UserModel(
      id: docId,
      createdAt: _parseTimestamp(data['created_at']),
      name: data['name'] ?? '',
      userName: data['username'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      isBlocked: data['is_blocked'] ?? false,
      isVerified: data['is_verified'] ?? false,
      provider: data['provider'] ?? '',
      token: data['token'] ?? '',
      upload: data['upload'] ?? false,
      image: data['image'] ?? '',
      appVersion: data['app_version'] ?? '',
      followersCount: data['followers_count'] ?? 0,
      followingCount: data['following_count'] ?? 0,
      bio: data['bio'] ?? '',
      postsCount: data['posts_count'] ?? 0,
      canAskedAnonymously: data['can_asked_anonymously'] ?? false,
    );
  }

  /// ---------------------------
  /// ⭐ To Firestore JSON
  /// ---------------------------
  Map<String, dynamic> toMap() {
    return {
      'created_at': createdAt.toString(),
      'name': name,
      'username': userName,
      'phone': phone,
      'email': email,
      'is_blocked': isBlocked,
      'is_verified': isVerified,
      'provider': provider,
      'token': token,
      'upload': upload,
      'image': image,
      'app_version': appVersion,
      'followers_count': followersCount,
      'following_count': followingCount,
      'bio': bio,
      'posts_count': postsCount,
      'can_asked_anonymously': canAskedAnonymously,
    };
  }

  /// ---------------------------
  /// ⭐ copyWith — مفيد جدًا في التعديل
  /// ---------------------------
  UserModel copyWith({
    String? name,
    String? userName,
    String? phone,
    String? email,
    bool? isBlocked,
    bool? isPremium,
    String? provider,
    String? token,
    bool? upload,
    String? image,
    String? appVersion,
    int? followersCount,
    int? followingCount,
    String? bio,
    int? postsCount,
    bool? canAskedAnonymously,
  }) {
    return UserModel(
      id: id,
      createdAt: createdAt,
      name: name ?? this.name,
      userName: userName ?? this.userName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      isBlocked: isBlocked ?? this.isBlocked,
      isVerified: isPremium ?? this.isVerified,
      provider: provider ?? this.provider,
      token: token ?? this.token,
      upload: upload ?? this.upload,
      image: image ?? this.image,
      appVersion: appVersion ?? this.appVersion,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      bio: bio ?? this.bio,
      postsCount: postsCount ?? this.postsCount,
      canAskedAnonymously: canAskedAnonymously ?? this.canAskedAnonymously,
    );
  }

  /// ---------------------------
  /// ⭐ Helper: Parse Firestore timestamp safely
  /// ---------------------------
  static DateTime _parseTimestamp(dynamic value) {
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
