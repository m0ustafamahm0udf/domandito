import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';
void showReportBottomSheet({
  required BuildContext context,
  required String contentId,
  required ReportContentType contentType,
  required String contentOwnerId,
}) {
  final reasons = [
    'Spam',
    'Harassment or bullying',
    'Hate speech',
    'Sexual or explicit content',
    'Other',
  ];

  // تحديد العنوان حسب نوع المحتوى
  final title = contentType == ReportContentType.question
      ? (context.isCurrentLanguageAr() ? 'الإبلاغ عن السؤال' : 'Report Question')
      : (context.isCurrentLanguageAr() ? 'الإبلاغ عن الإجابة' : 'Report Answer');

  showModalBottomSheet(
    context: context,
    builder: (_) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // العنوان
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            ListView(
              shrinkWrap: true,
              children: reasons
                  .map(
                    (reason) => ListTile(
                      title: Text(reason),
                      onTap: () async {
                        Navigator.pop(context);
                        AppConstance().showLoading(context);
                        final success = await ReportService.submitReport(
                          contentId: contentId,
                          contentType: contentType,
                          reason: reason,
                          contentOwnerId: contentOwnerId,
                        );

                        if (success) {
                          Loader.hide();

                          AppConstance().showSuccesToast(
                            context,
                            duration: 6,
                            msg: context.isCurrentLanguageAr()
                                ? 'شكرًا لإبلاغك. سيقوم فريقنا بمراجعة هذا المحتوى واتخاذ الإجراء المناسب في حال مخالفته لإرشادات المجتمع.'
                                : 'Thanks for reporting. Our team will review this content and take appropriate action if it violates our community guidelines.',
                          );
                        } else {
                          AppConstance().showSuccesToast(
                            context,
                            msg: context.isCurrentLanguageAr()
                                ? 'لقد قمت بالإبلاغ عن هذا المحتوى مسبقًا.'
                                : 'You already reported this content.',
                          );
                          Loader.hide();
                        }
                      },
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      );
    },
  );
}
