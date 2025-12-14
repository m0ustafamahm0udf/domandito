import 'package:domandito/core/utils/extentions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

String formatDate(DateTime date, BuildContext context) {
  final DateFormat formatter = DateFormat('dd-MMMM hh:mm a', !context.isCurrentLanguageAr()? 'en' : 'ar');
  // final DateFormat formatter = DateFormat('dd-MM-yyyy', 'en');
  return formatter.format(date);
}

String formatDateWithoutTime(DateTime date, BuildContext context) {
  final DateFormat formatter = DateFormat('dd-MMMM-yyyy', !context.isCurrentLanguageAr()? 'en' : 'ar');
  // final DateFormat formatter = DateFormat('dd-MM-yyyy', 'en');
  return formatter.format(date);
}

String formatDateTimeShortcut(DateTime dt) {
  final day = dt.day;
  final month = _monthString(dt.month);
  final year = dt.year;
  // final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  // final minute = dt.minute.toString().padLeft(2, '0');
  // final amPm = dt.hour >= 12 ? 'PM' : 'AM';

  return '$day $month $year';
}

/// Return short month strings. Extend or localize as needed.
String _monthString(int monthNumber) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return months[monthNumber - 1];
}
