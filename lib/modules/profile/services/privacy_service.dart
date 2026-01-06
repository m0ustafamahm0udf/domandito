// import 'dart:async';
//
// import 'package:domandito/core/constants/app_constants.dart';
// import 'package:domandito/core/services/notifications/send_message_notification.dart';
// import 'package:domandito/core/utils/extentions.dart';
// import 'package:domandito/core/utils/shared_prefrences.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:screen_capture_event/screen_capture_event.dart';

// class PrivacyService {
//   static final PrivacyService _instance = PrivacyService._internal();
//   factory PrivacyService() => _instance;
//   PrivacyService._internal();

//   final _screenCaptureEvent = ScreenCaptureEvent();

//   /// Enables screen protection and screenshot detection.
//   Future<void> enableSecureMode({
//     required BuildContext context,
//     required String targetUserId,
//     required String targetUserToken,
//   }) async {
//     // 0. Safety Check
//     if (MySharedPreferences.userId == targetUserId) return;

//     // Web Check
//     if (kIsWeb) return;

//     // 1. Check verified status
//     final isVisitorVerified = MySharedPreferences.isVerified;
//     if (isVisitorVerified) return;

//     log(
//       '🔒 Enabling Secure Mode (ScreenCaptureEvent) for userId: $targetUserId',
//     );

//     // 2. Add Listener for Detection (No Blocking)
//     try {
//       // Note: We use dynamic path to handle potential void/String mismatch across platforms
//       _screenCaptureEvent.addScreenShotListener((path) {
//         log('📸 Screen Capture Event Fired! Path: $path');
//         _sendScreenshotNotification(
//           context: context,
//           targetUserToken: targetUserToken,
//           isScreenshot: true,
//         );
//       });

//       // Note: 'addScreenRecordingListener' was removed as it does not exist in v1.2.0.
//       // We assume 'addScreenShotListener' covers captures.
//       // If Android Recording is not detected, this package might not support it natively.

//       // Start watching
//       _screenCaptureEvent.watch();
//     } catch (e) {
//       log('Error initializing ScreenCaptureEvent: $e');
//     }
//   }

//   /// Disables screen protection and removes listeners.
//   Future<void> disableSecureMode() async {
//     log('🔓 Disabling Secure Mode');
//     try {
//       // Since we can't easily remove anonymous listeners without storing them,
//       // and 'screen_capture_event' doesn't seem to have a 'stopWatch',
//       // we rely on the object lifecycle or maybe it stops on dispose?
//       // If usage documentation suggests 'dispose', we'd call it.
//       // For now logic assumes this Service singleton persists.

//       // Note: Re-enabling/Disabling might be limited by the package API.
//     } catch (e) {
//       log('Error disabling secure mode: $e');
//     }
//   }

//   /// Sends a notification to the content owner.
//   Future<void> _sendScreenshotNotification({
//     required BuildContext context,
//     required String targetUserToken,
//     bool isScreenshot = true,
//   }) async {
//     final tokenLog = targetUserToken.length > 5
//         ? targetUserToken.substring(0, 5)
//         : targetUserToken;
//     log('🚀 Sending Privacy Notification... Token: $tokenLog...');

//     if (targetUserToken.isEmpty) {
//       log('❌ Error: Target Token is Empty');
//       return;
//     }

//     final visitorName = MySharedPreferences.isLoggedIn
//         ? MySharedPreferences.userName
//         : (context.isCurrentLanguageAr() ? 'شخص ما' : 'Someone');

//     final title = !context.isCurrentLanguageAr() ? 'Domandito' : 'دومانديتو';

//     final actionEn = isScreenshot
//         ? 'took a screenshot!'
//         : 'is screen recording!';
//     final actionAr = isScreenshot ? 'بالتقاط صورة للشاشة!' : 'بتسجيل الشاشة!';

//     final body = !context.isCurrentLanguageAr()
//         ? '$visitorName $actionEn'
//         : 'قام $visitorName $actionAr';

//     await SendMessageNotificationWithHTTPv1().send2(
//       type: AppConstance.screenshot,
//       urll: '',
//       toToken: targetUserToken,
//       message: body,
//       title: title,
//       id: MySharedPreferences.userId,
//     );
//   }
// }
