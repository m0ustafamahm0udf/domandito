import 'package:domandito/main.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationsService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void initialize() {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/notification_icon'), //
      iOS: DarwinInitializationSettings(
        requestSoundPermission: false,
        requestBadgePermission: false,
        requestAlertPermission: false,
      ),
    );
    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (message) {
        if (notificationsMap.isNotEmpty) {
          // RoutesService().toggle(notificationsMap);
        }
      },
    );
  }

  //for notifications in foreground
  void display(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'Domandito', // id
        'Domandito', // title
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
        playSound: true,
      );

      await _flutterLocalNotificationsPlugin.show(
        id,
        message.notification!.title,
        message.notification!.body,
        // getTranslatedContent(message.notification!.body!),
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.max,
            playSound: true,
            icon: '@mipmap/notification_icon', //
            color: AppColors.primary,
            colorized: true,
          ),
          iOS: DarwinNotificationDetails(sound: 'default'),
        ),
      );
    } on Exception {
      // log("Exception:: $e");
    }
  }
}
