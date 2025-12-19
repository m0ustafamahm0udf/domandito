import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/constants/app_icons.dart';
import 'package:domandito/core/services/launch_urls.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

void showDownloadAppDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        // backgroundColor: AppColors.primary, // أو أي لون مناسب
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                !context.isCurrentLanguageAr()
                    ? 'Download the app'
                    : 'تحميل التطبيق',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      context.back;
                      LaunchUrlsService().launchBrowesr(
                        uri: AppConstance.appStoreUrl,
                        context: context,
                      );
                    },
                    icon: SvgPicture.asset(
                      AppIcons.appstore,
                      height: 25,
                      width: 25,
                    ),
                    label: Text(
                      'App Store',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton.icon(
                    onPressed: () {
                      context.back;

                      LaunchUrlsService().launchBrowesr(
                        uri: AppConstance.googleplayUrl,
                        context: context,
                      );
                    },
                    icon: SvgPicture.asset(
                      AppIcons.googleplay,
                      height: 25,
                      width: 25,
                    ),
                    label: Text(
                      'Google Play',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
