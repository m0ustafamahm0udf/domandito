// import 'dart:io';

// import 'package:flutter/foundation.dart';
// import 'package:safe_device/safe_device.dart';

// //! Security status returned by the SecurityService.
// enum SecurityStatus {
//   safe,
//   rooted,
//   jailbroken,
//   emulator,
//   isMockLocation,
//   debugMode,
//   developmentMode,
//   unknown,
// }

// //! SecurityService centralizes device safety checks using `safe_device`.

// class SecurityService {
//   SecurityService();

//   bool isJailBroken = false;
//   bool isJailBrokenCustom = false;
//   bool isMockLocation = false;
//   bool isRealDevice = true;
//   bool isOnExternalStorage = false;
//   bool isSafeDevice = true;
//   bool isDevelopmentModeEnable = false;
//   Map<String, dynamic> jailbreakDetails = {};
//   Map<String, dynamic> rootDetectionDetails = {};
//   Future<void> init() async {
//     isJailBroken = await SafeDevice.isJailBroken;
//     isMockLocation = await SafeDevice.isMockLocation;
//     isRealDevice = await SafeDevice.isRealDevice;
//     isOnExternalStorage = await SafeDevice.isOnExternalStorage;
//     isSafeDevice = await SafeDevice.isSafeDevice;
//     isDevelopmentModeEnable = await SafeDevice.isDevelopmentModeEnable;

//     // iOS-specific enhanced jailbreak detection
//     if (Platform.isIOS) {
//       isJailBrokenCustom = await SafeDevice.isJailBrokenCustom;
//       // jailbreakDetails = await SafeDevice.jailbreakDetails;
//     }

//     // Android-specific enhanced root detection debugging
//     if (Platform.isAndroid) {
//       rootDetectionDetails = await SafeDevice.rootDetectionDetails;
//     }

//     // Print debug info
//     print('SecurityService initialized:');
//     print('  isJailBroken: $isJailBroken');
//     print('  isJailBrokenCustom: $isJailBrokenCustom');
//     print('  isMockLocation: $isMockLocation');
//     print('  isRealDevice: $isRealDevice');
//     print('  isOnExternalStorage: $isOnExternalStorage');
//     print('  isSafeDevice: $isSafeDevice');
//     print('  isDevelopmentModeEnable: $isDevelopmentModeEnable');
//     print('  jailbreakDetails: $jailbreakDetails');
//     print('  rootDetectionDetails: $rootDetectionDetails');
//   }

//   Future<SecurityStatus> evaluateSecurityStatus() async {
//     //! kDebugMode bypass security
//     if (kDebugMode) {
//       return SecurityStatus.safe;
//     }
//     try {
      

//       if (Platform.isIOS) {
//         if (isJailBroken || isJailBrokenCustom)
//           return SecurityStatus.jailbroken;
//       }

//       if (isMockLocation) return SecurityStatus.isMockLocation;

//       if (!isRealDevice) return SecurityStatus.emulator;

//       if (isDevelopmentModeEnable) return SecurityStatus.developmentMode;

//       if (Platform.isAndroid) {
//         if (!isSafeDevice) {
//           return SecurityStatus.rooted;
//         }
//       }
//       return SecurityStatus.safe;
//     } catch (_) {
//       return SecurityStatus.unknown;
//     }
//   }

//   /// Perform platform checks and return the most important detected issue.
//   // Future<SecurityStatus> checkDeviceSecurity() async {
//   //   try {
//   //     // safe_device provides multiple helpers; we query the ones we care about.
//   // // top-level getters from safe_device are imported with prefix `sd`.
//   //   // Use safe_device public API. The package exposes pre-built checks we
//   //   // can await. If the API differs, update accordingly to match the
//   //   // package version in pubspec.yaml.
//   //   final bool rootedFlag = await SafeDevice.;
//   //   final bool jailBrokenFlag = await SafeDevice.isJailBroken;
//   //   final bool emulatorFlag = await SafeDevice.isEmulator;
//   //     final bool isDebug = kDebugMode; // compile-time constant

//   // if (rootedFlag) return SecurityStatus.rooted;
//   // if (jailBrokenFlag) return SecurityStatus.jailbroken;
//   // if (emulatorFlag) return SecurityStatus.emulator;
//   //     if (isDebug) return SecurityStatus.debugMode;

//   //     return SecurityStatus.safe;
//   //   } catch (e) {
//   //     // On any error, return unknown so the app can decide a safe fallback.
//   //     return SecurityStatus.unknown;
//   //   }
//   // }
// }
