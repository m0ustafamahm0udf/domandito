import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/services/notifications/send_message_notification.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileVisitService {
  /// Records a visit to a user's profile and sends a notification if applicable.
  ///
  /// Logic:
  /// 1. If Visitor == Target, do nothing.
  /// 2. If Visitor visited recently (within 2 hours), do nothing (Throttle).
  /// 3. If Visitor is Logged In:
  ///    - If Visitor is NOT verified, send notification (Push).
  ///    - If Visitor IS verified, remain silent.
  /// 4. If Visitor is NOT Logged In (Guest):
  ///    - Send generic "Guest viewed your profile" notification.
  static Future<void> recordVisit({
    required String targetUserId,
    required String targetUserToken,
    required BuildContext context,
  }) async {
    // 0. Safety Check
    if (!context.mounted) return;

    // 1. Don't notify self-visits
    if (MySharedPreferences.userId == targetUserId) return;

    // 2. Throttle Check (Cooldown)
    final canNotify = await _shouldNotify(targetUserId);
    // final canNotify = true;
    // log(canNotify.toString());
    if (!canNotify) return;

    final isVisitorLoggedIn = MySharedPreferences.isLoggedIn;

    if (isVisitorLoggedIn) {
      final isVisitorVerified = MySharedPreferences.isVerified;

      final visitorName = MySharedPreferences.userName;
      final visitorId = MySharedPreferences.userId;

      String body;
      String idToSend;

      if (isVisitorVerified) {
        body = !context.isCurrentLanguageAr()
            ? 'Someone viewed your profile'
            : 'شخص ما شاهد ملفك الشخصي';
        idToSend = 'HIDDEN';
      } else {
        body = !context.isCurrentLanguageAr()
            ? '$visitorName viewed your profile'
            : 'قام $visitorName بمشاهدة ملفك الشخصي';
        idToSend = visitorId;
      }

      final title = !context.isCurrentLanguageAr() ? 'Domandito' : 'زائر جديد';

      // Send Push Notification
      await SendMessageNotificationWithHTTPv1().send2(
        type: AppConstance.profileVisit,
        urll: '',
        toToken: targetUserToken,
        message: body,
        title: title,
        id: idToSend,
      );
    } else {
      // 4. Guest Visit Logic
      // "Tell me a solution" -> Notify about anonymous interest

      // final title = !context.isCurrentLanguageAr() ? 'Domandito' : 'زائر جديد';

      // final body = !context.isCurrentLanguageAr()
      //     ? 'Someone viewed your profile'
      //     : 'شخص ما شاهد ملفك الشخصي';

      // if (targetUserToken.isNotEmpty) {
      //   await SendMessageNotificationWithHTTPv1().send2(
      //     type: AppConstance.profileVisit,
      //     urll: '',
      //     toToken: targetUserToken,
      //     message: body,
      //     title: title,
      //     id: '', // No specific user to open
      //   );
      // }
    }
  }

  /// Checks if we should notify this target user based on last visit time.
  /// Returns [true] if cooldown has passed or never visited.
  static Future<bool> _shouldNotify(String targetUserId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'last_visit_timestamp_$targetUserId';
      final lastVisitMillis = prefs.getInt(key);
      final now = DateTime.now().millisecondsSinceEpoch;

      if (lastVisitMillis != null) {
        final diff = now - lastVisitMillis;
        // 1 hours cooldown = 1 * 60 * 60 * 1000 milliseconds
        if (diff < 1 * 60 * 60 * 1000) {
          return false;
        }
      }

      await prefs.setInt(key, now);
      return true;
    } catch (e) {
      // If error (e.g. SharedPreferences failure), allow notification to be safe/visible
      // or block to be safe against spam? Let's allow it but log error.
      debugPrint("Error in _shouldNotify: $e");
      return true;
    }
  }
}
