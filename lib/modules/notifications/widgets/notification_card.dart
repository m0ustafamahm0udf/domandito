// import 'package:timeago/timeago.dart' as timeago;

import 'package:domandito/modules/notifications/models/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:domandito/core/constants/app_images.dart';
import 'package:domandito/core/services/launch_urls.dart';
import 'package:domandito/core/utils/custom_format_date.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/custom_bounce_button.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notificationsData;

  const NotificationCard({super.key, required this.notificationsData});

  // Widget getNotificationType(String type) {
  //   switch (type) {
  //     case AppConstance.follow:
  //       return ProfileScreen(userId: MySharedPreferences.userId);
  //     case AppConstance.like:
  //     case AppConstance.answer:
  //     case AppConstance.question:

  //     case AppConstance.url:
  //       return AppConstance.url;

  //     default:
  //       return '';
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // DateTime myDateTime = DateTime.now().subtract(
    //     Duration(minutes: 30)); // Replace this with your desired DateTime

    return BounceButton(
      onPressed: () {
        // print(notificationsData.routeId);
        if (notificationsData.actionUrl != null) {
          LaunchUrlsService().launchBrowesr(
            uri: notificationsData.actionUrl!,
            context: context,
          );
        }
      },
      child: Container(
        // height: 75,
        // margin: EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          // color: AppColors.white,
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        // padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        width: context.w - 40,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(AppImages.logo, height: 35, width: 35),
                ),
                const SizedBox(width: 10),
                // Spacer(),
                // Spacer(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notificationsData.title,
                          // maxLines: 3,
                          // overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            // color: AppColors.primary,
                          ),
                        ),
                        Text(
                          notificationsData.message,
                          maxLines: 3,
                          // overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            // color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 15),
              ],
            ),
            SizedBox(height: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  formatDate(notificationsData.createdAt.toDate(),context),
                  // maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.primary.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            // Padding(
            //   padding: EdgeInsetsDirectional.only(start: 22.w),
            //   child: ,
            // ),
          ],
        ),
      ),
    );
  }
}
