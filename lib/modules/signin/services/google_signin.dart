// // ignore_for_file: use_build_context_synchronously

// // import 'dart:developer';
// // import 'dart:developer' as dev;
// import 'package:domandito/core/constants/app_constants.dart';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:internet_connection_checker/internet_connection_checker.dart';
// import 'package:domandito/modules/signin/models/user_model.dart';
// import 'package:domandito/modules/signin/services/add_user_to_firestore.dart';
// import 'package:domandito/shared/functions/check_is_huawui.dart';
// import '../../../core/services/get_device_serv.dart';

// class GSignin {
//   final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

//   Future<User?> signInWithGoogle({
//     required BuildContext context,

//     // required TextEditingController phoneController,
//   }) async {
//     User? user;
//     AppConstance().showLoading(context);
//     if (!await InternetConnectionChecker().hasConnection) {
//       Loader.hide();
//       AppConstance().showInfoToast(context, msg: 'لا يوجد اتصال بالانترنت');
//       return user;
//     }
//     await googleSignIn.signOut();
//     FirebaseAuth auth = FirebaseAuth.instance;

//     if (kIsWeb) {
//       // Web login using popup
//       GoogleAuthProvider googleProvider = GoogleAuthProvider();
//       UserCredential userCredential = await auth.signInWithPopup(
//         googleProvider,
//       );
//       user = userCredential.user;
//     }

//     final GoogleSignInAccount? googleSignInAccount = await googleSignIn
//         .signIn();

//     if (googleSignInAccount != null) {
//       final GoogleSignInAuthentication googleSignInAuthentication =
//           await googleSignInAccount.authentication;

//       final AuthCredential credential = GoogleAuthProvider.credential(
//         accessToken: googleSignInAuthentication.accessToken,
//         idToken: googleSignInAuthentication.idToken,
//       );
//       try {
//         final UserCredential userCredential = await auth.signInWithCredential(
//           credential,
//         );
//         user = userCredential.user;
//         if (context.mounted) {
//           CheckIsHuawei checkIsHuawei = CheckIsHuawei();
//           String token = await checkIsHuawei.getTokenIfIsnotHuawei(
//             context: context,
//           );
//           final platform = PlatformService.platform;

//           // log('SUCCESS');
//           // log('googleSignInAccountID:: ${googleSignInAccount.id}');
//           // log('googleSignInAccountEmail:: ${googleSignInAccount.email}');
//           UserModel userModel = UserModel(
//             image: googleSignInAccount.photoUrl ?? '',
//             id: googleSignInAccount.id,
//             name: googleSignInAccount.displayName.toString(),
//             phone: '',
//             token: token.toString(),
//             provider: platform.name,
//             email: googleSignInAccount.email,
//             isBlocked: false,
//             createdAt: Timestamp.now(),
//             appVersion: AppConstance.appVersion,
//             upload: false,
//             followersCount: 0,
//             followingCount: 0,
//             userName: '',
//             isPremium: false,
//           );
//           await AddUserToFirestore().addNewUser(userModel, context, false);
//         }

//         // log(user);
//       } on FirebaseAuthException catch (e) {
//         Loader.hide();
//         AppConstance().showErrorToast(
//           context,
//           msg: 'حدث خطأ أثناء تسجيل الدخول',
//         );

//         // AppConstants().showMsgToast(context, msg: e.toString());
//         if (e.code == 'account-exists-with-different-credential') {
//           // ...
//         } else if (e.code == 'invalid-credential') {
//           // ...
//         }
//       } catch (e) {
//         //  log(e.toString());
//         Loader.hide();
//         AppConstance().showErrorToast(
//           context,
//           msg: 'حدث خطأ أثناء تسجيل الدخول',
//         );

//         // AppConstants().showMsgToast(context, msg: e.toString() + e.toString());
//         // ...
//       }
//     }
//     Loader.hide();
//     return user;
//   }
// }

// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:domandito/core/constants/app_constants.dart';

import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:domandito/modules/signin/models/user_model.dart';
import 'package:domandito/modules/signin/services/add_user_to_supabase.dart';
import 'package:domandito/shared/functions/check_is_huawui.dart';
import '../../../core/services/get_device_serv.dart';

class GSignin {
  final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  Future<User?> signInWithGoogle({required BuildContext context}) async {
    User? user;
    AppConstance().showLoading(context);

    if (!await hasInternetConnection()) {
      Loader.hide();
      AppConstance().showInfoToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'No internet connection'
            : 'لا يوجد اتصال بالانترنت',
      );
      return null;
    }

    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      if (kIsWeb) {
        // Web: use FirebaseAuth popup directly
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        UserCredential userCredential = await auth.signInWithPopup(
          googleProvider,
        );
        user = userCredential.user;
        if (user != null) {
          log(user.photoURL.toString() + ' AAAAAAA');
        }

        if (context.mounted) {
          // Check Huawei and get token

          log(user?.photoURL ?? '');
          DateTime now = await getNetworkTime() ?? DateTime.now();

          UserModel userModel = UserModel(
            postsCount: 0,
            canAskedAnonymously: false,

            image:
                user?.photoURL ??
                'https://takeawayapp.ams3.digitaloceanspaces.com/play_store_512.png',
            id: user!.uid,
            name: user.displayName ?? '',
            phone: '',
            token: '',
            provider: PlatformService.platform.name,
            email: user.email ?? '',
            isBlocked: false,
            createdAt: now,
            appVersion: AppConstance.appVersion,
            upload: false,
            followersCount: 0,
            followingCount: 0,
            userName: user.email != null ? user.email!.split('@')[0] : '',
            isVerified: false,
            bio: '',
          );
          log(user.email!.split('@')[0] + ' BBBBBBBBB');
          await AddUserToSupabase().addNewUser(userModel, context, false);
        }
      } else {
        // Mobile: use GoogleSignIn
        await googleSignIn.signOut();
        final GoogleSignInAccount? googleSignInAccount = await googleSignIn
            .signIn();
        if (googleSignInAccount == null) return null;

        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        UserCredential userCredential = await auth.signInWithCredential(
          credential,
        );
        user = userCredential.user;
        if (user != null) {
          log(user.photoURL.toString() + ' BBBBBBBBB');
        }

        if (context.mounted) {
          // Check Huawei and get token
          CheckIsHuawei checkIsHuawei = CheckIsHuawei();
          String token = await checkIsHuawei.getTokenIfIsnotHuawei(
            context: context,
          );
          final platform = PlatformService.platform;
          log(token + 'ASAASASASASASAS');
          DateTime now = await getNetworkTime() ?? DateTime.now();

          UserModel userModel = UserModel(
            postsCount: 0,
            canAskedAnonymously: false,

            image:
                user?.photoURL ??
                'https://takeawayapp.ams3.digitaloceanspaces.com/play_store_512.png',
            id: user!.uid,
            name: user.displayName ?? '',
            phone: '',
            token: token,
            provider: platform.name,
            email: user.email ?? '',

            isBlocked: false,
            createdAt: now,
            appVersion: AppConstance.appVersion,
            upload: false,
            followersCount: 0,
            followingCount: 0,
            userName: user.email != null ? user.email!.split('@')[0] : '',

            isVerified: false,
            bio: '',
          );

          await AddUserToSupabase().addNewUser(userModel, context, false);
        }
      }
    } on FirebaseAuthException catch (e) {
      AppConstance().showErrorToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? e.toString()
            : 'حدث خطأ أثناء تسجيل الدخول',
      );
      print('FirebaseAuthException: ${e.code} - ${e.message}');
    } catch (e) {
      AppConstance().showErrorToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? e.toString()
            : 'حدث خطأ أثناء تسجيل الدخول',
      );
      print('Other Exception: $e');
    } finally {
      Loader.hide();
    }

    return user;
  }
}
