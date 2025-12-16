// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'dart:math';
// import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:domandito/core/services/get_device_serv.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/modules/signin/models/user_model.dart';

import 'package:domandito/modules/signin/services/add_user_to_firestore.dart';
import 'package:domandito/shared/functions/check_is_huawui.dart';

import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleSignin {
  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> signInWithApple({required BuildContext context}) async {
    try {
      AppConstance().showLoading(context);
      if (!await hasInternetConnection()) {
        Loader.hide();
        AppConstance().showInfoToast(
          context,
          msg: !context.isCurrentLanguageAr()
              ? 'No internet connection'
              : 'لا يوجد اتصال بالانترنت',
        );
        return;
      }

      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      if (appleCredential.identityToken == null) {
        Loader.hide();
        return;
      }
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );
      final auth = await FirebaseAuth.instance.signInWithCredential(
        oauthCredential,
      );
      if (context.mounted) {
        CheckIsHuawei checkIsHuawei = CheckIsHuawei();
        String token = await checkIsHuawei.getTokenIfIsnotHuawei(
          context: context,
        );

        // dev.log('appleCredential:: $oauthCredential');
        // dev.log('uid:: ${auth.user!.uid}');
        // dev.log('email:: ${auth.user!.email}');
        // dev.log('displayName:: ${appleCredential.givenName ?? ''}');
        // dev.log('SUCCESS');
        final platform = PlatformService.platform;
        DateTime now = await getNetworkTime() ?? DateTime.now();

        UserModel userModel = UserModel(
          image:
              auth.user!.photoURL ??
              'https://takeawayapp.ams3.digitaloceanspaces.com/play_store_512.png',
          id: auth.user!.uid,
          name: '${appleCredential.givenName} ${appleCredential.familyName}',
          phone: '',
          token: token.toString(),
          provider: platform.name,
          email: auth.user!.email.toString(),
          upload: false,
          isBlocked: false,
          appVersion: AppConstance.appVersion,
          bio: '',
          createdAt: Timestamp.fromDate(now),
          followersCount: 0,
          followingCount: 0,
          userName: auth.user!.email != null
              ? auth.user!.email!.split('@')[0]
              : '',
          canAskedAnonymously: false,
          postsCount: 0,
          isVerified: false,
        );
        if (appleCredential.givenName != null) {
          await AddUserToFirestore().addNewUser(userModel, context, false);
        } else {
          await AddUserToFirestore().addNewUser(userModel, context, true);
        }
      }
      Loader.hide();
    } on PlatformException catch (e) {
      print(e);
      AppConstance().showErrorToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'Failed to sign in with Apple. Please try again.'
            : 'حدث خطأ أثناء تسجيل الدخول',
      );

      if (e.code == GoogleSignIn.kNetworkError) {
        // log(e);
      } else {
        // log(e);
      }
      Loader.hide();
    } catch (e) {
      print(e);

      AppConstance().showErrorToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'Failed to sign in with Apple. Please try again.'
            : 'حدث خطأ أثناء تسجيل الدخول',
      );

      // log(e);
      Loader.hide();
    }
  }
}
