import 'package:flutter/services.dart';

class SystemUiStyle {
  static void overlayStyle() async {
    // if (Platform.isAndroid) {
    //   SystemChrome.setSystemUIOverlayStyle(
    //     SystemUiOverlayStyle(
    //       statusBarBrightness: Brightness.dark,
    //       statusBarColor: Colors.white,
    //       statusBarIconBrightness: Brightness.dark,
    //       systemNavigationBarColor: Colors.white,
    //       systemNavigationBarDividerColor: Colors.white,
    //       systemNavigationBarIconBrightness: Brightness.dark,
    //     ),
    //   );
    // } else {
    //   SystemChrome.setSystemUIOverlayStyle(
    //     SystemUiOverlayStyle(
    //       statusBarBrightness: Brightness.light,
    //       statusBarColor: Colors.transparent,
    //       statusBarIconBrightness: Brightness.light,
    //       systemNavigationBarColor: Colors.white,
    //       systemNavigationBarDividerColor: Colors.white,
    //       systemNavigationBarIconBrightness: Brightness.light,
    //     ),
    //   );
    // }

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}
