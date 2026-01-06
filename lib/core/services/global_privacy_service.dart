import 'dart:async';

import 'dart:io';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:screen_protector/screen_protector.dart';

/// Global Privacy Service
/// - Blocks Screenshot & Recording App-Wide.
/// - Exempts Verified Users.
/// - Handles App Lifecycle.
class GlobalPrivacyService with WidgetsBindingObserver {
  static final GlobalPrivacyService _instance =
      GlobalPrivacyService._internal();
  factory GlobalPrivacyService() => _instance;
  GlobalPrivacyService._internal();

  bool _isProtectionActive = false;

  /// Initialize and start watching lifecycle
  void init() {
    if (kIsWeb) return;
    WidgetsBinding.instance.addObserver(this);
    evaluatePrivacyParameters(); // Initial check
    // log('🛡️ GlobalPrivacyService Initialized');
  }

  /// Called when app lifecycle state changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // log('🛡️ App Resumed: Re-evaluating privacy');
      evaluatePrivacyParameters();
    }
  }

  /// Checks user status and enables/disables protection accordingly
  void evaluatePrivacyParameters() {
    final isVerified = MySharedPreferences.isVerified;

    if (isVerified) {
      // log('🛡️ User is Verified: Disabling Protection ✅');/
      _disableProtection();
    } else {
      // log('🛡️ User NOT Verified: Enabling Protection 🔒');
      _enableProtection();
    }
  }

  Future<void> _enableProtection() async {
    // If already active, maybe we still want to re-enforce (especially on iOS)
    // But let's check flag to avoid spamming logs, unless on iOS where we need to be aggressive.

    try {
      _isProtectionActive = true;

      // 1. Basic Prevention
      await ScreenProtector.preventScreenshotOn();

      // 2. Data Leakage
      if (Platform.isIOS) {
        await ScreenProtector.protectDataLeakageWithColor(Colors.black);
      } else if (Platform.isAndroid) {
        await ScreenProtector.protectDataLeakageOn();
      }

      // 3. Retry for iOS stability
      Future.delayed(const Duration(milliseconds: 500), () async {
        try {
          if (MySharedPreferences.isVerified) return; // double check
          await ScreenProtector.preventScreenshotOn();
          if (Platform.isIOS) {
            await ScreenProtector.protectDataLeakageWithColor(Colors.black);
          }
        } catch (_) {}
      });
    } catch (e) {
      // log('❌ Privacy Enable Error: $e');
    }
  }

  Future<void> _disableProtection() async {
    if (!_isProtectionActive) return; // Already disabled

    try {
      _isProtectionActive = false;
      await ScreenProtector.preventScreenshotOff();
      await ScreenProtector.protectDataLeakageOff();
      // log('🔓 Protection Disabled');
    } catch (e) {
      // log('❌ Privacy Disable Error: $e');
    }
  }

  /// Remove observer
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
