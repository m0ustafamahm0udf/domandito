// lib/services/platform_service.dart

import 'package:domandito/core/constants/app_platforms_serv.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;



class PlatformService {
  /// هل هو Web؟
  static bool get isWeb => kIsWeb;

  /// هل التطبيق يعمل على Mobile App (Android/iOS) وليس Web؟
  static bool get isMobileApp => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// هل التطبيق يعمل على Desktop وليس Web؟
  static bool get isDesktop =>
      !kIsWeb &&
      (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  /// هل هو Android App؟
  static bool get isAndroidApp => !kIsWeb && Platform.isAndroid;

  /// هل هو iOS App؟
  static bool get isIOSApp => !kIsWeb && Platform.isIOS;

  /// اكتشاف نوع الجهاز على Web باستخدام UserAgent
  static AppPlatform get webDeviceType {
    if (!kIsWeb) return AppPlatform.unknown;

    try {
      // Use Uri.base as fallback if dart:html is unavailable
      final ua = Uri.base.toString().toLowerCase();

      if (ua.contains("iphone") || ua.contains("ipad") || ua.contains("ipod") || ua.contains("ios")) {
        return AppPlatform.webIOS;
      } else if (ua.contains("android")) {
        return AppPlatform.webAndroid;
      } else {
        return AppPlatform.webDesktop;
      }
    } catch (_) {
      return AppPlatform.webDesktop;
    }
  }

  /// المنصة الموحدة
  static AppPlatform get platform {
    if (kIsWeb) return webDeviceType;

    if (Platform.isAndroid) return AppPlatform.androidApp;
    if (Platform.isIOS) return AppPlatform.iosApp;
    if (Platform.isWindows) return AppPlatform.windowsApp;
    if (Platform.isMacOS) return AppPlatform.macOSApp;
    if (Platform.isLinux) return AppPlatform.linuxApp;

    return AppPlatform.unknown;
  }
}
