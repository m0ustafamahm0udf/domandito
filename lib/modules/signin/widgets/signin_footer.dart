import 'package:animate_do/animate_do.dart';
import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/constants/app_icons.dart';
import 'package:domandito/core/constants/app_platforms_serv.dart';
import 'package:domandito/core/services/get_device_serv.dart';
import 'package:domandito/core/services/launch_urls.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/modules/landing/views/landing_screen.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

class SignInFooter extends StatelessWidget {
  final bool mustLogin;

  const SignInFooter({super.key, required this.mustLogin});

  @override
  Widget build(BuildContext context) {
    final platform = PlatformService.platform;

    return Column(
      children: [
        if (!mustLogin)
          FadeInUp(
            from: 10,
            duration: const Duration(milliseconds: 600),
            delay: Duration(
              milliseconds: AppPlatform.iosApp == platform ? 1000 : 800,
            ),
            child: TextButton(
              onPressed: () => context.toAndRemoveAll(LandingScreen()),
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
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      LaunchUrlsService().launchBrowesr(
                        uri: AppConstance.googleplayUrl,
                        context: context,
                      );
                    },
                    label: Text(
                      'Google Play',
                      style: TextStyle(color: AppColors.white),
                    ),
                    icon: SvgPicture.asset(
                      AppIcons.googleplay,
                      height: 25,
                      width: 25,
                    ),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }
}
