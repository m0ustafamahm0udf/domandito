// ignore_for_file: use_build_context_synchronously

// import 'dart:developer' as dev;
// import 'dart:developer';

import 'dart:developer';

import 'package:domandito/modules/signin/create_account_screen.dart';
import 'package:domandito/modules/signin/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:domandito/modules/landing/views/landing_screen.dart';
// import 'package:domandito/modules/signin/services/add_user_token_to_firestore.dart';

class AddUserToFirestore {
  Future<bool> isPhoneUsed(String phone, String currentUserId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return false; // الرقم غير مستخدم
      }

      return true;

      // final existingUserId = snapshot.docs.first.id;
      // return existingUserId != currentUserId; // true = مستخدم من شخص آخر
    } catch (e) {
      return true; // لمنع التكرار في حالة error
    }
  }

  Future<bool> isUsernameUsed(String username, String currentUserId) async {
    try {
      log('username: $username');
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userName', isEqualTo: username)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return false; // الاسم غير مستخدم
      }

      return true;

      // final existingUserId = snapshot.docs.first.id;
      // return existingUserId != currentUserId; // true = مستخدم من شخص آخر
    } catch (e) {
      return true;
    }
  }

  Future<bool> isEmailUsed(String email, String currentUserId) async {
    try {
      log('email: $email');
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return false; // الاسم غير مستخدم
      }
      return true;

      // final existingUserId = snapshot.docs.first.id;
      // return existingUserId != currentUserId; // true = مستخدم من شخص آخر
    } catch (e) {
      return true;
    }
  }

  Future<String?> validatePhoneAndUsername({
    required String phone,
    required String username,
    required String email,
    required String currentUserId,
    required BuildContext context,
  }) async {
    try {
      // تنفيذ جميع الفحوصات في نفس الوقت
      final results = await Future.wait([
        isPhoneUsed(phone, currentUserId),
        isUsernameUsed(username, currentUserId),
        isEmailUsed(email, currentUserId),
      ]);

      final phoneUsed = results[0];
      final usernameUsed = results[1];
      final emailUsed = results[2];

      if (phoneUsed) {
        return !context.isCurrentLanguageAr()
            ? 'Phone number is already in use'
            : 'رقم الهاتف موجود بالفعل';
      }
      if (usernameUsed) {
        return !context.isCurrentLanguageAr()
            ? 'Username is already in use'
            : 'اسم المستخدم موجود بالفعل';
      }
      if (emailUsed) {
        return !context.isCurrentLanguageAr()
            ? 'Email is already in use'
            : 'البريد الالكتروني موجود بالفعل';
      }

      return null; // كله تمام
    } catch (e) {
      // في حالة خطأ، ممكن ترجّع رسالة عامة أو null
      return !context.isCurrentLanguageAr()
          ? 'An error occurred, please try again later'
          : 'حدث خطأ، يرجى المحاولة لاحقًا';
    }
  }

  Future<void> addNewUser(
    UserModel newUser,
    BuildContext context,
    bool isApple,
  ) async {
    try {
      Map<String, dynamic> updatedData = {
        'provider': newUser.provider,
        'token': newUser.token,
      };

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: newUser.email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        // البريد غير موجود، تابع إنشاء اسم المستخدم
        final emailUsed = await isEmailUsed(newUser.email, newUser.id);
        if (!emailUsed) {
          context.to(CreateAccountScreen(newUser: newUser));
          return;
        }
      } else {
        // البريد موجود، استخدم docId الموجود في Firestore لتحديثه
        final existingDoc = snapshot.docs.first;
        final userDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(existingDoc.id);
        await userDoc.update(updatedData);

        final data = existingDoc.data();
        log('data: $data');
        // حفظ البيانات SharedPreferences
        MySharedPreferences.isLoggedIn = true;
        MySharedPreferences.userName = data['name'] ?? '';
        MySharedPreferences.userUserName = data['userName'] ?? '';
        MySharedPreferences.phone = data['phone'] ?? '';
        MySharedPreferences.bio = data['bio'] ?? '';
        MySharedPreferences.userId = existingDoc.id; // <--- مهم
        MySharedPreferences.email = newUser.email;
        MySharedPreferences.deviceToken = newUser.token;
        MySharedPreferences.image = data['image'] ?? newUser.image;
        MySharedPreferences.isVerified = data['isVerified'] ?? false;

        // AppConstance().showSuccesToast(
        //   context,
        //   msg: 'أهلا ${data['name'] ?? ''}',
        // );
        context.toAndRemoveAll(LandingScreen());
      }
    } catch (e) {
      log('Error adding new user: $e');
      AppConstance().showErrorToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'An error occurred, please try again later'
            : 'حدث خطأ ما يرجى المحاولة لاحقا',
      );
    }
  }
}
