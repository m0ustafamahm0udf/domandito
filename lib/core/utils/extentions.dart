import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

extension NavigationExtension on BuildContext {
  void to(Widget screen) {
    Navigator.of(this).push(MaterialPageRoute(builder: (context) => screen));
    //  Navigator.of(this).push(PageRouteBuilder(pageBuilder: (BuildContext context,
    //     Animation<double> animation, Animation<double> secondaryAnimation) {
    //   return screen;
    // }));
  }

  void back() {
    Navigator.of(this).pop();
  }

  void backWithValue(dynamic value) {
    Navigator.of(this).pop(value);
  }

  void toAndRemove(Widget screen) {
    Navigator.of(this).pushReplacement(
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void toAndRemoveAll(Widget screen) {
    Navigator.of(this).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => screen),
      (route) => false,
    );
  }

  void print(String text) {
    debugPrint(text);
  }

  bool isCurrentLanguageAr() {
    return locale == const Locale('ar');
  }

  double get w => MediaQuery.of(this).size.width;
  double get h => MediaQuery.of(this).size.height;
}
