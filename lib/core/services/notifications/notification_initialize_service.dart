import 'package:domandito/core/services/notifications/cloud_messaging_service.dart';
import 'package:domandito/core/services/notifications/local_notifications_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class InitFirebaseNotification {
  void init() async {
    // طلب الإذن
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // تهيئة الإشعارات المحلية
    LocalNotificationsService().initialize();

    // إشعار تم فتحه بعد إغلاق التطبيق (terminated)
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        CloudMessagingService().terminated(message);
        // CloudMessagingService().routeToggle(message.data);
      }
    });

    // إشعار أثناء عمل التطبيق في الخلفية وتم فتحه
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      CloudMessagingService().handleTap(message);
      // CloudMessagingService().routeToggle(message.data);
    });

    // إشعار أثناء عمل التطبيق في المقدمة
    FirebaseMessaging.onMessage.listen((message) {
      CloudMessagingService().foreground(message);
    });
  }
}
