import 'package:domandito/core/constants/app_platforms_serv.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gms_check/gms_check.dart';

import '../../core/services/get_device_serv.dart';

class CheckIsHuawei {
  Future<String> getTokenIfIsnotHuawei({required BuildContext context}) async {
    if (kIsWeb) return '';

    final platform = PlatformService.platform;

    if (platform == AppPlatform.androidApp) {
      if (GmsCheck().isGmsAvailable) {
        String? token = await FirebaseMessaging.instance.getToken();
        await FirebaseMessaging.instance.subscribeToTopic('allUsers');

        // AppConstance().showInfoToast(context, msg: 'Domandito');
        return token ?? '';
      } else {
        // AppConstance().showInfoToast(context, msg: '<3');
        // AppConstance().showInfoToast(context, msg: 'NO GMS');
        return '';
      }
    } else {
      String? token = await FirebaseMessaging.instance.getToken();
      await FirebaseMessaging.instance.subscribeToTopic('allUsers');

      return token ?? '';
    }
    // return  '';
  }
}
