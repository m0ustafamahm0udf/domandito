import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/services/launch_urls.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domandito/main.dart';
import 'package:domandito/modules/ask/models/q_model.dart';
import 'package:domandito/modules/signin/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

bool validatePassword(String value) {
  String pattern =
      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
  RegExp regExp = RegExp(pattern);
  return regExp.hasMatch(value);
}

String getOrderTypeText(String type) {
  switch (type) {
    case 'delivery':
      return 'توصيل';
    case 'pickup':
      return 'استلام';
    default:
      return type;
  }
}

String getTranslatedContent(String content) {
  switch (content) {
    case AppConstance.liked:
      return AppConstance().likedAnswerNotification(
        context: navigatorKey.currentState!.context,
      );
    case AppConstance.asnwered:
      return AppConstance().answeredQNotification(
        context: navigatorKey.currentState!.context,
      );
    case AppConstance.questioned:
      return AppConstance().questionedNotification(
        context: navigatorKey.currentState!.context,
      );
    case AppConstance.followed:
      return AppConstance().followedNotification(
        context: navigatorKey.currentState!.context,
      );
    default:
      return content;
  }
}

bool isArabic(String text) {
  final arabicRegex = RegExp(r'[\u0600-\u06FF]');
  return arabicRegex.hasMatch(text);
}

Future<DateTime?> getNetworkTime() async {
  try {
    final response = await http.head(Uri.parse('https://www.google.com'));

    final dateHeader = response.headers['date'];
    if (dateHeader != null) {
      // parse HTTP date
      final dateTimeUtc = HttpDate.parse(dateHeader);

      // لو عايزه local
      final localDateTime = dateTimeUtc.toLocal();
      log('$localDateTime dateHeader');

      return localDateTime;
    }
  } catch (e) {
    log(e.toString());
  }
  return null;
}

String formatToHttpDate(DateTime dateTime) {
  final formatter = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'", 'en_US');
  return formatter.format(dateTime.toUtc());
}

Future<QuestionModel?> getQuestionData({required String questionId}) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('questions')
        .doc(questionId)
        .get();

    if (doc.exists) {
      final q = QuestionModel.fromJson(doc.data()!);
      return q;
    } else {
      return null;
      // debugPrint("No restaurant found with id: $resId");
    }
  } catch (e) {
    return null;

    // debugPrint("Error loading restaurant: $e");
  }
}

Future<UserModel?> getProfileByUserNameForDeepLink({
  required String userUserName,
}) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .where('userName', isEqualTo: userUserName)
        .limit(1)
        .get();
    if (doc.docs.isNotEmpty) {
      final user = UserModel.fromFirestore(doc.docs.first);
      return user;
      // await getQuestionsCount();
    } else {
      return null;
    }
  } catch (e) {
    debugPrint("Error fetching profile: $e");
    return null;
  }
}

String timeAgo(dynamic timestamp, BuildContext context) {
  DateTime date;

  if (timestamp is Timestamp) {
    date = timestamp.toDate();
  } else if (timestamp is DateTime) {
    date = timestamp;
  } else {
    return "";
  }

  final now = DateTime.now();
  final diff = now.difference(date);

  // أقل من ساعة → دقائق
  if (diff.inMinutes < 60) {
    final m = diff.inMinutes;
    if (m <= 0) return !context.isCurrentLanguageAr() ? 'Now' : "الآن";

    if (m == 1) {
      return !context.isCurrentLanguageAr() ? 'A minute ago' : "منذ دقيقة";
    }
    if (m == 2) {
      return !context.isCurrentLanguageAr() ? '2 minutes ago' : "منذ دقيقتين";
    }
    if (m < 11) {
      return !context.isCurrentLanguageAr()
          ? '${m} minutes ago'
          : "منذ $m دقائق";
    }
    return !context.isCurrentLanguageAr() ? '${m} minute ago' : "منذ $m دقيقة";
  }

  // أقل منذ 24 ساعة → ساعات
  if (diff.inHours < 24) {
    final h = diff.inHours;

    if (h == 1) {
      return !context.isCurrentLanguageAr() ? 'An hour ago' : "منذ ساعة";
    }
    if (h == 2) {
      return !context.isCurrentLanguageAr() ? '2 hours ago' : "منذ ساعتين";
    }
    if (h < 11) {
      return !context.isCurrentLanguageAr() ? '$h hours ago' : "منذ $h ساعات";
    }
    return !context.isCurrentLanguageAr() ? '$h hour ago' : "منذ $h ساعة";
  }

  // أقل منذ أسبوع → اسم اليوم
  if (diff.inDays < 7) {
    final days = [
      !context.isCurrentLanguageAr() ? 'Monday' : "الاثنين",
      !context.isCurrentLanguageAr() ? 'Tuesday' : "الثلاثاء",
      !context.isCurrentLanguageAr() ? 'Wednesday' : "الأربعاء",
      !context.isCurrentLanguageAr() ? 'Thursday' : "الخميس",
      !context.isCurrentLanguageAr() ? 'Friday' : "الجمعة",
      !context.isCurrentLanguageAr() ? 'Saturday' : "السبت",
      !context.isCurrentLanguageAr() ? 'Sunday' : "الأحد",
    ];
    return days[date.weekday - 1];
  }

  // أكثر من أسبوع → التاريخ
  return DateFormat(
    'dd-MMMM-yyyy',
    !context.isCurrentLanguageAr() ? 'ar' : 'en',
  ).format(date);
}

Future<bool> hasInternetConnection({
  Duration timeout = const Duration(milliseconds: 100),
}) async {
  if (kIsWeb) return true;
  try {
    final result = await InternetAddress.lookup('google.com').timeout(timeout);
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    }
    return false;
  } on SocketException catch (_) {
    return false;
  } on TimeoutException catch (_) {
    return false;
  }
}

// Get status color based on order status
// Color getStatusColor(String status) {
//   switch (status) {
//     case AppConstance.pending:
//       return AppColors.warning06;
//     case AppConstance.approved:
//       return AppColors.success59;
//     case AppConstance.completed:
//       return AppColors.primary;
//     case AppConstance.canceled || AppConstance.rejected:
//       return AppColors.error3c;
//     default:
//       return Colors.black;
//   }
// }

// double getRatio(BuildContext context) {
//   double height = MediaQuery.of(context).size.height;

//   if (height < 650) {
//     log('Small phone');
//     return 0.67;
//   } else if (height >= 650 && height <= 900) {
//     log('Medium phone');
//     return .7;
//   } else if (height > 900 && height <= 912) {
//     log('Large phone');
//     return .83;
//   } else {
//     log('Tablet');
//     return 1.2;
//   }
// }

double getRatio(BuildContext context) {
  double height = MediaQuery.of(context).size.height;

  if (height < 650) {
    // log('Small phone');
    return 0.71;
  } else if (height >= 650 && height <= 900) {
    // log('Medium phone');
    return .79;
  } else if (height > 900 && height <= 912) {
    // log('Large phone');
    return .83;
  } else if (height > 912 && height <= 1200) {
    // log('Small tablet');
    return .85;
  } else {
    // log('Large tablet');
    return 1.65;
  }
}

double getRatioAdd(BuildContext context) {
  double height = MediaQuery.of(context).size.height;

  if (height < 650) {
    // log('Small phone');
    return 0.65;
  } else if (height >= 650 && height <= 900) {
    // log('Medium phone');
    return .75;
  } else if (height > 900 && height <= 912) {
    // log('Large phone');
    return .83;
  } else if (height > 912 && height <= 1200) {
    // log('Small tablet');
    return .8;
  } else {
    // log('Large tablet');
    return 1.65;
  }
}

String englishTimestamp() {
  const Map<String, String> arabicToEnglish = {
    '٠': '0',
    '١': '1',
    '٢': '2',
    '٣': '3',
    '٤': '4',
    '٥': '5',
    '٦': '6',
    '٧': '7',
    '٨': '8',
    '٩': '9',
  };

  String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

  return timestamp
      .split('')
      .map((char) => arabicToEnglish[char] ?? char)
      .join();
}

Future<String> saveImageToTempFile(Uint8List imageBytes) async {
  final tempDir = await getTemporaryDirectory();
  final tempFile = File('${tempDir.path}/temp_image.jpg');
  await tempFile.writeAsBytes(imageBytes);
  return tempFile.path;
}

// List<String> generateSearchKeywords(String name) {
//   final words = name.toLowerCase().split(' ');
//   final keywords = <String>{};

//   for (final word in words) {
//     for (int i = 1; i <= word.length; i++) {
//       keywords.add(word.substring(0, i)); // add prefixes of each word
//     }
//   }

//   return keywords.toList();
// }

Future<bool> mustLogin() async {
  final re = await FirebaseFirestore.instance
      .collection('appInfo')
      .doc('appDetails')
      .get();
  if (re.data()!['mustLogin'] == true) {
    return true;
  } else {
    return false;
  }
}

List<String> generateSearchKeywords(String text) {
  text = text.trim().toLowerCase();
  if (text.isEmpty) return [];

  List<String> keywords = [];
  List<String> words = text.split(' ').where((w) => w.isNotEmpty).toList();

  // 1️⃣ prefixes لكل كلمة
  for (var word in words) {
    for (int i = 1; i <= word.length; i++) {
      keywords.add(word.substring(0, i));
    }
  }

  // 2️⃣ cumulative combinations
  for (int i = 0; i < words.length; i++) {
    String combination = "";
    for (int j = i; j < words.length; j++) {
      combination = ("$combination ${words[j]}").trim();
      keywords.add(combination);

      // prefixes لكل combination (بدون مسافات إضافية)
      for (int k = 1; k <= combination.length; k++) {
        final sub = combination.substring(0, k);
        if (!sub.endsWith(" ")) {
          keywords.add(sub);
        }
      }
    }
  }

  // 3️⃣ إزالة التكرار + ترتيب
  final uniqueSorted = keywords.toSet().toList()..sort();
  return uniqueSorted;
}

Future<void> addKeywordsToAllLostPeople() async {
  final firestore = FirebaseFirestore.instance;

  try {
    final snapshot = await firestore.collection('lost_people').get();

    for (final doc in snapshot.docs) {
      final data = doc.data();

      // الاسم أو النص اللي هتعمله keywords
      final String? name = data['name']; // غير name حسب الحقل اللي عندك
      if (name == null || name.trim().isEmpty) continue;

      // توليد الكلمات
      final keywords = generateSearchKeywords(name);

      // تحديث الدوكمنت
      await doc.reference.update({'searchKeywords': keywords});
    }

    // print('✅ تم تحديث كل المستندات بكلمات البحث');
  } catch (e) {
    // print('❌ خطأ أثناء التحديث: $e');
  }
}

String formatNumber(int number) {
  if (number < 1000) {
    return number.toString();
  }

  // آلاف
  if (number < 10000) {
    double result = number / 1000;
    return '${result.toStringAsFixed(1)}K';
  }

  if (number < 1000000) {
    int result = number ~/ 1000;
    return '${result}K';
  }

  // ملايين
  if (number < 10000000) {
    double result = number / 1000000;
    return '${result.toStringAsFixed(1)}M';
  }

  int result = number ~/ 1000000;
  return '${result}M';
}

final _urlRegex = RegExp(r'(https?:\/\/[^\s]+)', caseSensitive: false);
bool containsLink(String text) {
  return _urlRegex.hasMatch(text);
}

String? extractLink(String text) {
  final match = _urlRegex.firstMatch(text);
  return match?.group(0);
}

Widget linkifyText({
  required BuildContext context,
  required String text,
  required bool isInProfileScreen,
}) {
  final matches = _urlRegex.allMatches(text);

  if (matches.isEmpty) {
    return Text(
      "\"$text\"",
      textAlign: isArabic(text) ? TextAlign.right : TextAlign.left,
      textDirection: isArabic(text)
          ? ui.TextDirection.rtl
          : ui.TextDirection.ltr,
      overflow: !isInProfileScreen ? null : TextOverflow.ellipsis,
      maxLines: !isInProfileScreen ? null : 2,
      style: const TextStyle(fontSize: 16),
    );
  }

  final spans = <TextSpan>[];
  int lastIndex = 0;

  for (final match in matches) {
    if (match.start > lastIndex) {
      spans.add(
        TextSpan(
          text: text.substring(lastIndex, match.start),
          style: const TextStyle(fontSize: 16,
          fontFamily: 'Rubik',
          
          ),
        ),
      );
    }

    final url = match.group(0)!;

    spans.add(
      TextSpan(
        text: url,
        style:  TextStyle(
          fontSize: 14,
          // color: Colors.indigo,
          // fontWeight: FontWeight.bold,
          // fontFamily: 'Ruwudu',
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            LaunchUrlsService().launchBrowesr(uri: url, context: context);
          },
      ),
    );

    lastIndex = match.end;
  }

  if (lastIndex < text.length) {
    spans.add(
      TextSpan(
        text: text.substring(lastIndex),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  return RichText(
    textAlign: isArabic(text) ? TextAlign.right : TextAlign.left,
    textDirection: isArabic(text) ? ui.TextDirection.rtl : ui.TextDirection.ltr,
    overflow: !isInProfileScreen ? TextOverflow.visible : TextOverflow.ellipsis,
    maxLines: !isInProfileScreen ? null : 3,
    text: TextSpan(
      style: const TextStyle(color: Colors.black),
      children: spans,
    ),
  );
}

Future<bool> checkIsBlocked() async {
  if (MySharedPreferences.isLoggedIn) {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(MySharedPreferences.userId)
          .get();

      if (!docSnapshot.exists) return false;

      final data = docSnapshot.data();
      if (data == null) return false;

      return data['isBlocked'] == true;
    } catch (e, _) {
      return false;
    }
  } else {
    return false;
  }
}
