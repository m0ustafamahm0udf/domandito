enum ReportContentType { question, answer }

class ReportModel {
  final String id;
  final String contentId;
  final ReportContentType contentType;
  final String reason;
  final String reportedBy;
  final String contentOwnerId;
  final DateTime createdAt;

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
      'content_id': contentId,
      'content_type': contentType.name, // question | answer
      'reason': reason,
      'reporter_id': reportedBy,
      'owner_id': contentOwnerId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ReportModel.fromJson(Map<String, dynamic> json, String docId) {
    return ReportModel(
      id: docId,
      contentId: json['content_id'] ?? '',
      contentType: ReportContentType.values.byName(json['content_type']),
      reason: json['reason'] ?? '',
      reportedBy: json['reporter_id'] ?? '',
      contentOwnerId: json['owner_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : DateTime.now(),
    );
  }
}
