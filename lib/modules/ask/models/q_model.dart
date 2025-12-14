import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionModel {
  final String id;
  final Timestamp createdAt;
  final Timestamp? answeredAt;
  String title;
  Sender sender;
  String? answerText;
  final bool isDeleted;
  final List<String> images;
  final bool isAnonymous;
  int likesCount;
  final int commentCount;
  final Receiver receiver;
  //  final int likesCount;
  bool isLiked;

  QuestionModel({
    required this.id,
    required this.createdAt,
    this.answeredAt,
    required this.title,
    required this.sender,
    this.answerText,
    this.isDeleted = false,
    this.images = const [],
    this.isAnonymous = false,
    this.likesCount = 0,
    this.commentCount = 0,
    required this.receiver,
    this.isLiked = false,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] ?? '',
      createdAt: json['createdAt'] ?? Timestamp.now(),
      answeredAt: json['answeredAt'],
      title: json['title'] ?? '',
      sender: Sender.fromJson(json['sender']),
      answerText: json['answerText'],
      isDeleted: json['isDeleted'] ?? false,
      images: List<String>.from(json['images'] ?? []),
      isAnonymous: json['isAnonymous'] ?? false,
      likesCount: json['likesCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      receiver: Receiver.fromJson(json['receiver']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt,
      'answeredAt': answeredAt,
      'title': title,
      'sender': sender.toJson(),
      'answerText': answerText,
      'isDeleted': isDeleted,
      'images': images,
      'isAnonymous': isAnonymous,
      'likesCount': likesCount,
      'commentCount': commentCount,
      'receiver': receiver.toJson(),
    };
  }
}

class Sender {
  final String id;
  final String name;
  final String userName;
  final String? image;
  final String token;

  Sender({
    required this.id,
    required this.name,
    required this.userName,
    required this.token,
    this.image,
  });

  factory Sender.fromJson(Map<String, dynamic> json) {
    return Sender(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'],
      userName: json['userName'] ?? '',
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'userName': userName,
      'token': token,
    };
  }
}

class Receiver {
  final String id;
  final String name;
  final String token;

  final String image;
  final String userName;

  Receiver({
    required this.id,
    required this.image,
    required this.name,
    required this.userName,
    required this.token,
  });

  factory Receiver.fromJson(Map<String, dynamic> json) {
    return Receiver(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'],
      userName: json['userName'] ?? '',
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'userName': userName,
      'token': token,
    };
  }
}
