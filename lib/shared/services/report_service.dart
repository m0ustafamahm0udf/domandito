import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import '../models/report_model.dart';

class ReportService {
  static final _collection =
      FirebaseFirestore.instance.collection('reports');

  /// returns true if report submitted
  /// returns false if user already reported this content
  static Future<bool> submitReport({
    required String contentId,
    required ReportContentType contentType,
    required String reason,
    required String contentOwnerId,
  }) async {
    final String userId = MySharedPreferences.userId;

    // 🔍 check if user already reported this content
    final existingReport = await _collection
        .where('contentId', isEqualTo: contentId)
        .where('contentType', isEqualTo: contentType.name)
        .where('reportedBy', isEqualTo: userId)
        .limit(1)
        .get();

    if (existingReport.docs.isNotEmpty) {
      // 🚫 already reported
      
      return false;
    }

    final report = ReportModel(
      id: '',
      contentId: contentId,
      contentType: contentType,
      reason: reason,
      reportedBy: userId,
      contentOwnerId: contentOwnerId,
      createdAt: Timestamp.now(),
    );

    await _collection.add(report.toJson());
    return true;
  }
}
