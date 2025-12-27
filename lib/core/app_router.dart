// lib/core/config/app_pages.dart

import 'package:domandito/core/utils/utils.dart';
import 'package:domandito/modules/child_safety/child_safety.dart';
import 'package:domandito/modules/landing/views/landing_screen.dart';
import 'package:domandito/modules/privacy/privacy.dart';
import 'package:domandito/modules/profile/view/profile_screen.dart';
import 'package:domandito/modules/signin/signin_screen.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:domandito/modules/terms/teerms.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/logo_widg.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  // تعريف ثابت لأسماء المسارات
  static const String landing = '/';
  static const String profile = '/:username'; // مسار البروفايل الديناميكي
  static const String question = '/q/:questionId'; // مسار الأسئلة الديناميكي
  static const String terms = '/terms';
  static const String privacy = '/privacy';
  static const String childSafety = '/child_safety';

  // دالة لتحديد الشاشة الرئيسية بناءً على حالة تسجيل الدخول
  static Widget _getInitialScreen() {
    return MySharedPreferences.isLoggedIn ? LandingScreen() : SignInScreen();
  }
}
// lib/core/config/app_pages.dart

// ... (تعريف AppRoutes يبقى كما هو)

class AppPages {
  static final routes = [
    // 1. المسار الرئيسي (الـ Root /)
    GetPage(
      name: AppRoutes.landing,
      page: () => AppRoutes._getInitialScreen(), // الشاشة الافتتاحية
    ),
    GetPage(
      name: AppRoutes.terms,
      page: () => TermsScreen(), // الشاشة الافتتاحية
    ),
    GetPage(
      name: AppRoutes.privacy,
      page: () => PrivacyPolicyScreen(), // الشاشة الافتتاحية
    ),

    GetPage(name: AppRoutes.childSafety, page: () => SafetyStandardsScreen()),
    // 2. مسار البروفايل (مثال: /m0ustafamahm0ud)
    GetPage(
      name: AppRoutes.profile,
      // 🌟 التعديل هنا: استخدام FutureBuilder أو انتظار النتيجة مباشرة (وهو الأفضل هنا) 🌟
      page: () {
        // 1. استخلاص اسم المستخدم من المسار
        final String? userUserName = Get.parameters['username'];

        // 2. التحقق من وجود اسم المستخدم
        if (userUserName == null || userUserName.isEmpty) {
          return AppRoutes._getInitialScreen();
        }

        // Sanitize username (remove query params like ?fbclid=...)
        final String cleanUserName = userUserName.split('?').first;

        // 3. استخدام FutureBuilder لانتظار جلب البيانات (لأن دالة page غير متزامنة)
        return FutureBuilder<dynamic>(
          // 'dynamic' يمكن استبدالها بـ 'UserModel?' أو نوع الإرجاع الفعلي
          future: getProfileByUserNameForDeepLink(userUserName: cleanUserName),
          builder: (context, snapshot) {
            // انتظار جلب البيانات
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CupertinoActivityIndicator(color: AppColors.primary),
                ),
              );
            }

            // البيانات جاهزة
            final userModel = snapshot.data;

            if (userModel != null) {
              // إذا تم العثور على المستخدم، قم بعرض شاشة البروفايل
              return ProfileScreen(
                userId: userModel.id, // 🌟 تمرير الـ userId المسترجع
              );
            } else {
              // إذا لم يتم العثور على المستخدم
              return const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LogoWidg(),
                      Text(
                        'User Not Found (404)',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontFamily: 'Dancing_Script',
                          fontSize: 42,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        );
      },
    ),

    // ... (مسار السؤال AppRoutes.question إذا كان مفعلاً)
  ];
}
