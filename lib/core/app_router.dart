// lib/core/config/app_pages.dart

import 'dart:developer';
import 'package:domandito/core/utils/utils.dart';
import 'package:domandito/modules/landing/views/landing_screen.dart';
import 'package:domandito/modules/profile/view/profile_screen.dart';
import 'package:domandito/modules/signin/signin_screen.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
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

  // دالة لتحديد الشاشة الرئيسية بناءً على حالة تسجيل الدخول
  static Widget _getInitialScreen() {
    return MySharedPreferences.isLoggedIn ? LandingScreen() : SignInScreen();
  }
}

class AppPages {
  static final routes = [
    // 1. المسار الرئيسي (الـ Root /) - للبدء العادي
    GetPage(
      name: AppRoutes.landing,
      page: () => AppRoutes._getInitialScreen(), // الشاشة الافتتاحية
    ),

    // 2. مسار البروفايل (مثال: /m0ustafamahm0ud أو /#/m0ustafamahm0ud)
    GetPage(
      name: AppRoutes.profile,
      page: () {
        // 1. استخلاص اسم المستخدم من المسار (يعمل للـ Path و الـ Hash)
        final String? userUserName = Get.parameters['username'];
        log('Deep Link Detected for User: $userUserName');

        // 2. التحقق من وجود اسم المستخدم
        if (userUserName == null || userUserName.isEmpty) {
          return AppRoutes._getInitialScreen();
        }

        // 3. استخدام FutureBuilder لانتظار جلب البيانات قبل العرض
        return FutureBuilder<dynamic>(
          future: getProfileByUserNameForDeepLink(userUserName: userUserName),
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
                userId: userModel.id, 
                userUserName: userModel.userName, // تمرير الـ userName الحقيقي
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

    // 3. مسار السؤال (قم بإلغاء التعليق إذا كنت تريد تفعيله)
    // GetPage(
    //   name: AppRoutes.question,
    //   // ... (منطق QuestionScreen)
    // ),
  ];
}