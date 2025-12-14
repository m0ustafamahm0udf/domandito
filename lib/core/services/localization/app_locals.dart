import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:one_context/one_context.dart';

class AppLocals {
  toggleLocal({
    required BuildContext context,
    required Locale locale,
  }) {
    if (context.locale != locale) {
      context.setLocale(locale).then((value) => OneNotification.hardReloadRoot(context));
    }
  }
}
