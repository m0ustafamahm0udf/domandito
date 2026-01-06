import 'dart:async';

import 'dart:io';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:screen_protector/screen_protector.dart';

/// VERSION 6 (Enhanced): Aggressive Blocking for iOS & Android
class PrivacyServiceV6 {
  static final PrivacyServiceV6 _instance = PrivacyServiceV6._internal();
  factory PrivacyServiceV6() => _instance;
  PrivacyServiceV6._internal();

  Future<void> enableSecureMode({
    required BuildContext context,
    required String targetUserId,
    required String targetUserToken,
  }) async {
    if (MySharedPreferences.userId == targetUserId) return;
    if (kIsWeb) return;

    final isVisitorVerified = MySharedPreferences.isVerified;
    if (isVisitorVerified) return;

    // log('🔒 V6+: Enabling Aggressive Security');

    try {
      // 1. Basic Prevention (Android FLAG_SECURE / iOS SecureField)
      await ScreenProtector.preventScreenshotOn();

      // 2. Data Leakage Protection (Background/Switcher)
      if (Platform.isIOS) {
        await ScreenProtector.protectDataLeakageWithColor(Colors.black);
      } else if (Platform.isAndroid) {
        await ScreenProtector.protectDataLeakageOn();
      }

      // 3. RETRY Mechanism (Fix for iOS animation timing issues)
      // Sometimes calling this too early during nav transition fails on iOS
      Future.delayed(const Duration(milliseconds: 500), () async {
        try {
          await ScreenProtector.preventScreenshotOn();
          if (Platform.isIOS) {
            await ScreenProtector.protectDataLeakageWithColor(Colors.black);
          }
          // log('🔒 V6+: Retry successful');
        } catch (e) {
          // log('❌ V6+: Retry failed: $e');
        }
      });
    } catch (e) {
      // log('❌ V6+: Error enabling protection: $e');
    }
  }

  Future<void> disableSecureMode() async {
    // log('🔓 V6+: Disabling protection');
    try {
      await ScreenProtector.preventScreenshotOff();
      await ScreenProtector.protectDataLeakageOff();
    } catch (e) {
      // log('V6+ Disable Error: $e');
    }
  }
}
