import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:domandito/modules/notifications/repositories/notifications_repository.dart';

class BadgeService {
  static Future<void> updateBadgeCount() async {
    bool isSupported = await FlutterAppBadger.isAppBadgeSupported();
    if (isSupported) {
      try {
        final count = await NotificationsRepository().getUnreadCount();
        // log(count.toString());
        if (count > 0) {
          FlutterAppBadger.updateBadgeCount(count);
        } else {
          FlutterAppBadger.removeBadge();
        }
      } catch (e) {
        // Handle/ignore
      }
    }
  }

  static Future<void> removeBadge() async {
    bool isSupported = await FlutterAppBadger.isAppBadgeSupported();
    if (isSupported) {
      FlutterAppBadger.removeBadge();
    }
  }
}
