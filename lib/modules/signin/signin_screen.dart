// ignore_for_file: use_build_context_synchronously

import 'package:animate_do/animate_do.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/utils.dart';
import 'package:domandito/modules/landing/views/landing_screen.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:domandito/core/constants/app_icons.dart';
import 'package:domandito/modules/signin/services/appl_signin.dart';
import 'package:domandito/modules/signin/services/google_signin.dart';
import 'package:domandito/modules/signin/widgets/social_button.dart';
import 'package:flutter/services.dart';
import 'package:svg_flutter/svg.dart';

import '../../core/constants/app_platforms_serv.dart';
import '../../core/services/get_device_serv.dart';

import 'dart:developer';

import 'package:domandito/core/constants/app_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:domandito/modules/signin/models/user_model.dart';
import 'package:domandito/modules/signin/services/add_user_to_firestore.dart';
import 'package:domandito/shared/functions/check_is_huawui.dart';
import '../../../core/services/get_device_serv.dart';
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController phoneController = TextEditingController();

  bool mustlogin = false;
  getMustLogin() async {
    mustlogin = await mustLogin();
    setState(() {});
  }
String err = '';
  @override
  void initState() {
    super.initState();
    getMustLogin();
  }
  final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  Future<User?> signInWithGoogle({required BuildContext context}) async {
    User? user;
    AppConstance().showLoading(context);

    if (!await hasInternetConnection()) {
      Loader.hide();
      AppConstance().showInfoToast(context, msg:!context.isCurrentLanguageAr() ? 'No internet connection' : 'لا يوجد اتصال بالانترنت');
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
            createdAt: Timestamp.fromDate(now),
            appVersion: AppConstance.appVersion,
            upload: false,
            followersCount: 0,
            followingCount: 0,
            userName: user.email != null ? user.email!.split('@')[0] : '',
            isVerified: false,
            bio: '',
          );
          log(user.email!.split('@')[0] + ' BBBBBBBBB');
          await AddUserToFirestore().addNewUser(userModel, context, false);
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
            createdAt: Timestamp.fromDate(now),
            appVersion: AppConstance.appVersion,
            upload: false,
            followersCount: 0,
            followingCount: 0,
            userName: user.email != null ? user.email!.split('@')[0] : '',

            isVerified: false,
            bio: '',
          );

          await AddUserToFirestore().addNewUser(userModel, context, false);
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        err = e.toString();
      });
      AppConstance().showErrorToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? e.toString()
            : 'حدث خطأ أثناء تسجيل الدخول',
      );
      print('FirebaseAuthException: ${e.code} - ${e.message}');
    } catch (e) {
      setState(() {
        err = e.toString();
      });
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
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final platform = PlatformService.platform;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.primary,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Stack(
          children: [
            Container(
              height: context.h,
              width: context.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple, AppColors.primary, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, right: 20, left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(height: size.height * 0.01),
                    Column(
                      children: [
                        Column(
                          children: [
                            SelectableText(err),
                            FadeInUp(
                          from: 50,

                          duration: const Duration(milliseconds: 600),

                              child: Transform.translate(
                                offset: const Offset(0, 40),
                                child: SvgPicture.asset(
                                  AppIcons.anonymous,
                                  color: AppColors.white,
                                  width: size.height * 0.18,
                                  height: size.height * 0.18,
                                ),
                              ),
                            ),
                            FadeInUp(
                          from: 10,

                          duration: const Duration(milliseconds: 600),

                              delay: Duration(milliseconds: 200),
                              child: Text(
                                'Domandito',
                                style: TextStyle(
                                  fontSize: 62,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                  fontFamily: 'Dancing_Script',
                                ),
                              ),
                            ),
                          ],
                        ),
                          FadeInUp(
                          from: 10,

                          duration: const Duration(milliseconds: 600),

                              delay: Duration(milliseconds: 350),
                          child: Text(
                            context.isCurrentLanguageAr()
                                ? 'قول اللي في نفسك'
                                : 'Ask anoynmously',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.05),

                    Column(
                      children: [
                        
                         if (AppPlatform.iosApp == platform)
                         FadeInUp(
                          from: 10,

                          duration: const Duration(milliseconds: 600),

                   
                              delay: Duration(milliseconds: 600),
                            child: SocialButton(
                              title: context.isCurrentLanguageAr()
                                  ? 'تسجيل الدخول بحساب Apple'
                                  : 'Sign in with Apple',
                              onPressed: () async {
                                FocusManager.instance.primaryFocus?.unfocus();
                                await AppleSignin().signInWithApple(
                                  context: context,
                                );
                              },
                              icon: AppIcons.apple,
                            ),
                          ),
                           if (AppPlatform.iosApp == platform)
                          const SizedBox(height: 10),
                         FadeInUp(

                          from: 10,
                          duration: const Duration(milliseconds: 600),

                              delay: Duration(milliseconds:AppPlatform.iosApp == platform ? 800 : 600),
                          child: SocialButton(
                            title: context.isCurrentLanguageAr()
                                ? 'تسجيل الدخول بحساب جوجل'
                                : 'Sign in with Google',
                            onPressed: () async {
                              FocusManager.instance.primaryFocus?.unfocus();
                          
                              await signInWithGoogle(context: context);
                            },
                            icon: AppIcons.google,
                          ),
                        ),
                       
                       
                        const SizedBox(height: 10),
                        if (!mustlogin)
                          FadeInUp(
                          from: 10,

                          duration: const Duration(milliseconds: 600),

                              delay: Duration(milliseconds:AppPlatform.iosApp == platform ? 1000 : 800),
                            child: TextButton(
                              onPressed: () =>
                                  context.toAndRemoveAll(LandingScreen()),
                              child: Text(
                                context.isCurrentLanguageAr() ? 'تخط' : 'Skip',
                                style: TextStyle(color: AppColors.white),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
