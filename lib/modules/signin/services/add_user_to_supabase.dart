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

  Future<String?> validatePhoneAndUsername({
    required String phone,
    required String username,
    required String email,
    String? currentUserId,
    required BuildContext context,
  }) async {
    try {
      final response = await _supabase.rpc(
        'check_user_availability',
        params: {
          'p_phone': phone,
          'p_username': username,
          'p_email': email,
          'p_exclude_user_id': currentUserId,
        },
      );

      final phoneUsed = response['phone_exists'] as bool;
      final usernameUsed = response['username_exists'] as bool;
      final emailUsed = response['email_exists'] as bool;

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
        // We only check email here, logic inside validatePhoneAndUsername handles the rest usually
        // But here we need to know if email is used to proceed.

        // Since we removed isEmailUsed, we can use the new RPC just for email or assume response.isEmpty means email is free.
        // Actually line 131 already checked if email exists: .eq('email').limit(1).
        // If response.isEmpty, then email is definitely NOT used by anyone else (or at all).
        // So we don't need to call isEmailUsed again.

        context.to(CreateAccountScreen(newUser: newUser));
        return;
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
