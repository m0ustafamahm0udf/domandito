// ignore_for_file: use_build_context_synchronously

import 'package:animate_do/animate_do.dart';
import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/services/launch_urls.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/utils.dart';
import 'package:domandito/modules/landing/views/landing_screen.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:domandito/core/constants/app_icons.dart';
import 'package:domandito/modules/signin/services/appl_signin.dart';
import 'package:domandito/modules/signin/services/google_signin.dart';
import 'package:domandito/modules/signin/widgets/social_button.dart';
import 'package:flutter/services.dart';
import 'package:svg_flutter/svg.dart';

import '../../core/constants/app_platforms_serv.dart';
import '../../core/services/get_device_serv.dart';

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

  @override
  void initState() {
    super.initState();
    getMustLogin();
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

                          delay: Duration(
                            milliseconds: AppPlatform.iosApp == platform
                                ? 800
                                : 600,
                          ),
                          child: SocialButton(
                            title: context.isCurrentLanguageAr()
                                ? 'تسجيل الدخول بحساب جوجل'
                                : 'Sign in with Google',
                            onPressed: () async {
                              FocusManager.instance.primaryFocus?.unfocus();

                              await GSignin().signInWithGoogle(
                                context: context,
                              );
                            },
                            icon: AppIcons.google,
                          ),
                        ),

                        const SizedBox(height: 10),
                        if (!mustlogin)
                          FadeInUp(
                            from: 10,

                            duration: const Duration(milliseconds: 600),

                            delay: Duration(
                              milliseconds: AppPlatform.iosApp == platform
                                  ? 1000
                                  : 800,
                            ),
                            child: TextButton(
                              onPressed: () =>
                                  context.toAndRemoveAll(LandingScreen()),
                              child: Text(
                                context.isCurrentLanguageAr() ? 'تخط' : 'Skip',
                                style: TextStyle(color: AppColors.white),
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),

                        if (kIsWeb)
                          Column(
                            children: [
                              const SizedBox(height: 20),
                              Text(
                                !context.isCurrentLanguageAr()
                                    ? 'Download the app'
                                    : 'تحميل التطبيق',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                              ),
                              // const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton.icon(
                                    onPressed: () {
                                      LaunchUrlsService().launchBrowesr(
                                        uri: AppConstance.appStoreUrl,
                                        context: context,
                                      );
                                    },
                                    label: Text(
                                      'App Store',
                                      style: TextStyle(color: AppColors.white),
                                    ),
                                    icon: SvgPicture.asset(
                                      AppIcons.appstore,
                                      height: 25,
                                      width: 25,
                                      // color: AppColors.white,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      LaunchUrlsService().launchBrowesr(
                                        uri: AppConstance.googleplayUrl,
                                        context: context,
                                      );
                                    },
                                    label:  Text('Google Play',
                                      style: TextStyle(color: AppColors.white),
                                    ),

                                    icon: SvgPicture.asset(
                                      AppIcons.googleplay,
                                      height: 25,
                                      width: 25,
                                      // color: AppColors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
