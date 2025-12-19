import 'package:cloud_firestore/cloud_firestore.dart';

class BlockModel {
  final String id;
  final DateTime createdAt;
  final BlockUser blocker; // المستخدم اللي عمل block
  final BlockUser blocked; // المستخدم اللي اتعمله block

  BlockModel({
    required this.id,
    required this.createdAt,
    required this.blocker,
    required this.blocked,
  });

  factory BlockModel.fromJson(Map<String, dynamic> json) {
    return BlockModel(
      id: json['id'] ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      blocker: BlockUser.fromJson(json['blocker'] ?? {}),
      blocked: BlockUser.fromJson(json['blocked'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': Timestamp.fromDate(createdAt),
      'blocker': blocker.toJson(),
      'blocked': blocked.toJson(),
    };
  }
}

class BlockUser {
  final String id;
  final String name;
  final String userName;
  final String image;

  BlockUser({
    required this.id,
    required this.name,
    required this.userName,
    required this.image,
  });

  factory BlockUser.fromJson(Map<String, dynamic> json) {
    return BlockUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      userName: json['userName'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'userName': userName,
      'image': image,
    };
  }
}
