import 'package:cloud_firestore/cloud_firestore.dart';

enum ReportContentType { question, answer }

class ReportModel {
  final String id;
  final String contentId;
  final ReportContentType contentType;
  final String reason;
  final String reportedBy;
  final String contentOwnerId;
  final Timestamp createdAt;

  ReportModel({
    required this.id,
    required this.contentId,
    required this.contentType,
    required this.reason,
    required this.reportedBy,
    required this.contentOwnerId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'contentId': contentId,
      'contentType': contentType.name, // question | answer
      'reason': reason,
      'reportedBy': reportedBy,
      'contentOwnerId': contentOwnerId,
      'createdAt': createdAt,
    };
  }

  factory ReportModel.fromJson(Map<String, dynamic> json, String docId) {
    return ReportModel(
      id: docId,
      contentId: json['contentId'] ?? '',
      contentType: ReportContentType.values.byName(json['contentType']),
      reason: json['reason'] ?? '',
      reportedBy: json['reportedBy'] ?? '',
      contentOwnerId: json['contentOwnerId']  ,
      createdAt: json['createdAt']   ,
    );
  }
}
