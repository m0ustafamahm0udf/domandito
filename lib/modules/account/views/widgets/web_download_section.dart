import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/constants/app_icons.dart';
import 'package:domandito/core/services/launch_urls.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

class WebDownloadSection extends StatelessWidget {
  const WebDownloadSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = context.isCurrentLanguageAr();

    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          isAr ? 'تحميل التطبيق' : 'Download the app',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
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
              label: const Text('App Store'),
              icon: SvgPicture.asset(AppIcons.appstore, height: 25, width: 25),
            ),
            TextButton.icon(
              onPressed: () {
                LaunchUrlsService().launchBrowesr(
                  uri: AppConstance.googleplayUrl,
                  context: context,
                );
              },
              label: const Text('Google Play'),
              icon: SvgPicture.asset(
                AppIcons.googleplay,
                height: 25,
                width: 25,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
