import 'package:cloud_firestore/cloud_firestore.dart';

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
    return LikeModel(
      id: json['id'] ?? '',
      questionId: json['questionId'] ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      user: LikeUser.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionId': questionId,
      'createdAt': Timestamp.fromDate(createdAt),
      'user': user.toJson(),
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
  required  this.token ,
  });

  factory LikeUser.fromJson(Map<String, dynamic> json) {
    return LikeUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      userName: json['userName'] ?? '',
      image: json['image'] ?? '',
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'userName': userName,
      'image': image,
      'token': token
    };
  }
}
