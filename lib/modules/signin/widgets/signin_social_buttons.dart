import 'package:animate_do/animate_do.dart';
import 'package:domandito/core/constants/app_icons.dart';
import 'package:domandito/core/constants/app_platforms_serv.dart';
import 'package:domandito/core/services/get_device_serv.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/modules/signin/services/appl_signin.dart';
import 'package:domandito/modules/signin/services/google_signin.dart';
import 'package:domandito/modules/signin/widgets/social_button.dart';
import 'package:flutter/material.dart';

class SignInSocialButtons extends StatelessWidget {
  const SignInSocialButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final platform = PlatformService.platform;

    return Column(
      children: [
        if (AppPlatform.iosApp == platform)
          FadeInUp(
            from: 10,
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 600),
            child: SocialButton(
              title: context.isCurrentLanguageAr()
                  ? 'تسجيل الدخول بحساب Apple'
                  : 'Sign in with Apple',
              onPressed: () async {
                FocusManager.instance.primaryFocus?.unfocus();
                await AppleSignin().signInWithApple(context: context);
              },
              icon: AppIcons.apple,
            ),
          ),
        if (AppPlatform.iosApp == platform) const SizedBox(height: 10),
        FadeInUp(
          from: 10,
          duration: const Duration(milliseconds: 600),
          delay: Duration(
            milliseconds: AppPlatform.iosApp == platform ? 800 : 600,
          ),
          child: SocialButton(
            title: context.isCurrentLanguageAr()
                ? 'تسجيل الدخول بحساب جوجل'
                : 'Sign in with Google',
            onPressed: () async {
              FocusManager.instance.primaryFocus?.unfocus();

              await GSignin().signInWithGoogle(context: context);
            },
            icon: AppIcons.google,
          ),
        ),
      ],
    );
  }
}
