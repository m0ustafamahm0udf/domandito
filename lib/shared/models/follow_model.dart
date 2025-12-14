import 'package:cloud_firestore/cloud_firestore.dart';

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
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      targetUser: FollowUser.fromJson(json['targetUser'] ?? {}),
      me: FollowUser.fromJson(json['me'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': Timestamp.fromDate(createdAt),
      'targetUser': targetUser.toJson(),
      'me': me.toJson(),
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
      userName: json['userName'] ?? '',
      image: json['image'] ?? '',
      userToken: json['userToken'] ?? '',
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
