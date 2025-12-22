// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:domandito/modules/signin/create_account_screen.dart';
import 'package:domandito/modules/signin/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:domandito/modules/landing/views/landing_screen.dart';

class AddUserToSupabase {
  final _supabase = Supabase.instance.client;

  Future<bool> isPhoneUsed(String phone, String? currentUserId) async {
    if (phone.isEmpty) return false;
    try {
      var query = _supabase.from('users').select().eq('phone', phone);
      if (currentUserId != null && currentUserId.isNotEmpty) {
        query = query.neq('id', currentUserId); // Exclude current user
      }
      final response = await query.limit(1);

      if (response.isEmpty) {
        return false; // الرقم غير مستخدم
      }

      return true;
    } catch (e) {
      log('Error checking phone: $e');
      return true; // لمنع التكرار في حالة error
    }
  }

  Future<bool> isUsernameUsed(String username, String? currentUserId) async {
    try {
      log('username: $username');
      var query = _supabase.from('users').select().eq('username', username);
      if (currentUserId != null && currentUserId.isNotEmpty) {
        query = query.neq('id', currentUserId); // Exclude current user
      }
      final response = await query.limit(1);

      if (response.isEmpty) {
        return false; // الاسم غير مستخدم
      }

      return true;
    } catch (e) {
      log('Error checking username: $e');
      return true;
    }
  }

  Future<bool> isEmailUsed(String email, String? currentUserId) async {
    try {
      log('email: $email');
      var query = _supabase.from('users').select().eq('email', email);
      if (currentUserId != null && currentUserId.isNotEmpty) {
        query = query.neq('id', currentUserId); // Exclude current user
      }
      final response = await query.limit(1);

      if (response.isEmpty) {
        return false; // الاسم غير مستخدم
      }
      return true;
    } catch (e) {
      log('Error checking email: $e');
      return true;
    }
  }

  Future<String?> validatePhoneAndUsername({
    required String phone,
    required String username,
    required String email,
    String? currentUserId,
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

      final response = await _supabase
          .from('users')
          .select()
          .eq('email', newUser.email)
          .limit(1);

      if (response.isEmpty) {
        // البريد غير موجود، تابع إنشاء اسم المستخدم
        final emailUsed = await isEmailUsed(newUser.email, null);
        if (!emailUsed) {
          context.to(CreateAccountScreen(newUser: newUser));
          return;
        }
      } else {
        // البريد موجود، استخدم id الموجود للتحديث
        final existingUser = response.first;
        final userId =
            existingUser['id']; // Assuming 'id' is the primary key or unique identifier

        await _supabase.from('users').update(updatedData).eq('id', userId);

        final data = existingUser; // In Supabase response is the data already
        log('data: $data');
        // حفظ البيانات SharedPreferences
        MySharedPreferences.isLoggedIn = true;
        MySharedPreferences.userName = data['name'] ?? '';
        MySharedPreferences.userUserName = data['username'] ?? '';
        MySharedPreferences.phone = data['phone'] ?? '';
        MySharedPreferences.bio = data['bio'] ?? '';
        MySharedPreferences.userId = userId.toString();
        MySharedPreferences.email = newUser.email;
        MySharedPreferences.deviceToken = newUser.token;
        MySharedPreferences.image = data['image'] ?? newUser.image;
        MySharedPreferences.isVerified = data['is_verified'] ?? false;

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

  Future<void> saveUser(Map<String, dynamic> userData) async {
    try {
      await _supabase.from('users').insert(userData);
    } catch (e) {
      log('Error saving user: $e');
      throw e;
    }
  }
}
