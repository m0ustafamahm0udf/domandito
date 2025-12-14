import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id; // Firestore document ID (required)
  final String objectId; //  question (like,new,answer)
  final Timestamp createdAt; // Required
  final String title; // Required
  final String message; // Required
  final String type; // Required ('question','like','follow','answer','url')
  final String?
  actionUrl; // Optional (URL to navigate to when the notification is clicked)
  final String? userId; //question (like,new,answer)

  NotificationModel({
    required this.id,
    required this.objectId,
    required this.createdAt,
    required this.title,
    required this.message,
    required this.type,
    this.actionUrl,
    this.userId,
  });

  // Factory method to create a Notification object from a Firestore document
  factory NotificationModel.fromFirestore(Map<String, dynamic> data) {
    return NotificationModel(
      objectId: data['objectId'] ?? '',
      id: data['id'] ?? '', // Firestore document ID
      createdAt:
          data['createdAt'] as Timestamp? ??
          Timestamp.now(), // Default to current timestamp
      title: data['title'] as String? ?? '', // Default to empty string
      message: data['message'] as String? ?? '', // Default to empty string
      type: data['type'] as String? ?? 'system', // Default to 'system'
      actionUrl: data['actionUrl'] ?? '', // Optional
      userId: data['userId'] ?? 'all',
    );
  }

  // Convert a Notification object to a Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'objectId': objectId,
      'createdAt': createdAt,
      'title': title,
      'message': message,
      'type': type,
      'actionUrl': actionUrl,
      'userId': userId,
    };
  }
}
