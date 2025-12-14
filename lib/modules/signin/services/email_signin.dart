// // import 'dart:developer' as dev;
// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
// import 'package:gms_check/gms_check.dart';
// import 'package:internet_connection_checker/internet_connection_checker.dart';
// import 'package:takeaway_v2/core/constants/app_constants.dart';
// import 'package:takeaway_v2/models/user_model.dart';
// import 'package:takeaway_v2/modules/signin/services/add_user_to_firestore.dart';
// import 'package:takeaway_v2/shared/functions/check_is_huawui.dart';
// import 'package:video_player/video_player.dart';

// class EmailSignin {
//   Future<User?> signInOrSignUpWithEmail({
//     required BuildContext context,
//     required String email,
//     required String password,
//     required TextEditingController phoneController,
//     required VideoPlayerController controller,
//   }) async {
//     User? user;
//     AppConstance().showLoading(context);

//     // Check for internet connection
//     if (!await InternetConnectionChecker().hasConnection) {
//       Loader.hide();
//       AppConstance().showInfoToast(context, msg: 'لا يوجد اتصال بالانترنت');
//       return user;
//     }

//     FirebaseAuth auth = FirebaseAuth.instance;

//     try {
//       // Attempt to sign in with email and password
//       final UserCredential userCredential =
//           await auth.signInWithEmailAndPassword(
//         email: email.trim(),
//         password: password.trim(),
//       );
//       user = userCredential.user;

//       if (user != null) {
//         if (context.mounted) {
//           // Create user model if needed
//           CheckIsHuawei checkIsHuawei = CheckIsHuawei();
//           String token =
//               await checkIsHuawei.getTokenIfIsnotHuawei(context: context);
//           UserModel userModel = UserModel(
//             cityId: '0',
//             image: '',
//             id: user.uid,
//             name: user.displayName ??
//                 email.split(
//                     '@')[0], // Default to part of email if no displayName
//             phone: phoneController.text.trim(),
//             token: token,
//             provider: Platform.isIOS
//                 ? 'email-ios'
//                 : GmsCheck().isGmsAvailable
//                     ? 'email-android'
//                     : 'email-huawei',
//             email: user.email ?? email,
//             points: 0,
//             isBlocked: false,
//             canBook: true,
//             createdAt: Timestamp.now(),
//             upload: false,
//           );

//           await AddUserToFirestore()
//               .addNewUser(userModel, context, false, controller);
//         }
//       }
//     } on FirebaseAuthException catch (e) {
//       // dev.log(e.toString());
//       if (e.code == 'wrong-password') {
//         AppConstance().showErrorToast(context,
//             msg: 'البريد الالكتروني او كلمة المرور غير صحيحة');
//       }
//       if (e.code == 'invalid-email') {
//         AppConstance()
//             .showErrorToast(context, msg: 'البريد الالكتروني غير صحيح');
//       }
//       if (e.code == 'user-not-found') {
//         try {
//           final UserCredential userCredential =
//               await auth.createUserWithEmailAndPassword(
//             email: email.trim(),
//             password: password.trim(),
//           );
//           user = userCredential.user;

//           if (user != null && context.mounted) {
//             // Create user model for new account
//             CheckIsHuawei checkIsHuawei = CheckIsHuawei();

//             String token =
//                 await checkIsHuawei.getTokenIfIsnotHuawei(context: context);
//             UserModel userModel = UserModel(
//               cityId: '0',
//               image: '',
//               id: user.uid,
//               name:
//                   email.split('@')[0], // Default to part of email for new users
//               phone: phoneController.text.trim(),
//               token: token,
//               provider: Platform.isIOS
//                   ? 'email-ios'
//                   : GmsCheck().isGmsAvailable
//                       ? 'email-android'
//                       : 'email-huawei',
//               email: email.trim(),
//               points: 0,
//               isBlocked: false,
//               canBook: true,
//               createdAt: Timestamp.now(),
//               upload: false,
//             );

//             await AddUserToFirestore()
//                 .addNewUser(userModel, context, false, controller);
//           }
//         } on FirebaseAuthException catch (signUpError) {
//           Loader.hide();
//           AppConstance().showErrorToast(context,
//               msg: signUpError.message ?? 'Sign-up failed');
//         }
//       } else {
//         // Handle other sign-in errors
//         Loader.hide();
//       }
//     } catch (e) {
//       // General error handling
//       Loader.hide();
//       AppConstance().showErrorToast(context, msg: e.toString());
//     }

//     // Hide loader after all operations
//     Loader.hide();
//     return user;
//   }
// }
