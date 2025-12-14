import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final Timestamp createdAt;

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
   required this.postsCount ,
  });

  /// ---------------------------
  /// ⭐ From Firestore Document
  /// ---------------------------
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      id: doc.id,
      createdAt: _parseTimestamp(data['createdAt']),
      name: data['name'] ?? '',
      userName: data['userName'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      isBlocked: data['isBlocked'] ?? false,
      isVerified: data['isVerified'] ?? false,
      provider: data['provider'] ?? '',
      token: data['token'] ?? '',
      upload: data['upload'] ?? false,
      image: data['image'] ?? '',
      appVersion: data['appVersion'] ?? '',
      followersCount: data['followersCount'] ?? 0,
      followingCount: data['followingCount'] ?? 0,
      bio: data['bio'] ?? '',
      postsCount: data['postsCount'] ?? 0,
    );
  }

  /// ---------------------------
  /// ⭐ From JSON (optional use)
  /// ---------------------------
  factory UserModel.fromJson(Map<String, dynamic> data, String docId) {
    return UserModel(
      id: docId,
      createdAt: _parseTimestamp(data['createdAt']),
      name: data['name'] ?? '',
      userName: data['userName'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      isBlocked: data['isBlocked'] ?? false,
      isVerified: data['isVerified'] ?? false,
      provider: data['provider'] ?? '',
      token: data['token'] ?? '',
      upload: data['upload'] ?? false,
      image: data['image'] ?? '',
      appVersion: data['appVersion'] ?? '',
      followersCount: data['followersCount'] ?? 0,
      followingCount: data['followingCount'] ?? 0,
      bio: data['bio'] ?? '',
      postsCount: data['postsCount'] ?? 0,
    );
  }

  /// ---------------------------
  /// ⭐ To Firestore JSON
  /// ---------------------------
  Map<String, dynamic> toFirestore() {
    return {
      'createdAt': createdAt,
      'name': name,
      'userName': userName,
      'phone': phone,
      'email': email,
      'isBlocked': isBlocked,
      'isVerified': isVerified,
      'provider': provider,
      'token': token,
      'upload': upload,
      'image': image,
      'appVersion': appVersion,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'bio': bio,
      'postsCount': postsCount
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
      postsCount: postsCount ?? this.postsCount
    );
  }

  /// ---------------------------
  /// ⭐ Helper: Parse Firestore timestamp safely
  /// ---------------------------
  static Timestamp _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value;
    return Timestamp.now();
  }
}
