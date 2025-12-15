// lib/core/config/app_pages.dart

import 'package:domandito/modules/landing/views/landing_screen.dart';
import 'package:domandito/modules/profile/view/profile_screen.dart';
import 'package:domandito/modules/signin/signin_screen.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
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
    // 1. المسار الرئيسي (الـ Root /)
    GetPage(
      name: AppRoutes.landing,
      page: () => AppRoutes._getInitialScreen(), // الشاشة الافتتاحية
    ),

    // 2. مسار البروفايل (مثال: /m0ustafamahm0ud)
    GetPage(
      name: AppRoutes.profile,
      page: () =>  ProfileScreen(userId: '', userUserName: ''), 
      // سنقوم باستخراج البيانات داخل ProfileScreen
    ),

    // 3. مسار السؤال (مثال: /q/12345)
    // GetPage(
    //   name: AppRoutes.question,
    //   page: () => QuestionScreen(
    //       isVerified: false, 
    //       question: null, 
    //       receiverImage: '', 
    //       onBack: (s) {}, 
    //       currentProfileUserId: MySharedPreferences.userId
    //   ),
    // ),
  ];
}