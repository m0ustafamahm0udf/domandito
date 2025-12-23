import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import '../models/report_model.dart';
import 'package:flutter/material.dart';

class ReportService {
  static final _supabase = Supabase.instance.client;
  static const String reportsTable = 'reports';

  /// returns true if report submitted
  /// returns false if user already reported this content
  static Future<bool> submitReport({
    required String contentId,
    required ReportContentType contentType,
    required String reason,
    required String contentOwnerId,
  }) async {
    final String userId = MySharedPreferences.userId;

    try {
      // 🔍 check if user already reported this content
      final existingReport = await _supabase
          .from(reportsTable)
          .select()
          .eq('content_id', contentId)
          .eq('content_type', contentType.name)
          .eq('reporter_id', userId)
          .limit(1)
          .maybeSingle();

      if (existingReport != null) {
        // 🚫 already reported
        return false;
      }

      final report = ReportModel(
        id: '', // DB Generated
        contentId: contentId,
        contentType: contentType,
        reason: reason,
        reportedBy: userId,
        contentOwnerId: contentOwnerId,
        createdAt: DateTime.now(),
      );

      await _supabase.from(reportsTable).insert(report.toJson());
      return true;
    } catch (e) {
      debugPrint('Error submitReport: $e');
      return false; // Fail gracefully
    }
  }

  /// Returns a list of content IDs (questions/answers) reported by [userId]
  // static Future<List<String>> getReportedContentIds(String userId) async {
  //   try {
  //     final List<dynamic> response = await _supabase
  //         .from(reportsTable)
  //         .select('content_id')
  //         .eq('reporter_id', userId);

  //     final List<String> reportedIds = response
  //         .map((e) => e['content_id'] as String)
  //         .toList();

  //     return reportedIds;
  //   } catch (e) {
  //     debugPrint('Error getReportedContentIds: $e');
  //     return [];
  //   }
  // }
}
