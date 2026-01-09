import 'package:domandito/core/constants/app_images.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:domandito/modules/admin/views/admin_screen.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/custom_network_image.dart';
import 'package:domandito/shared/widgets/featured_widget.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class AccountFooter extends StatelessWidget {
  final String adminId;
  final String appLogoUrl;
  final String appTitle;

  const AccountFooter({
    super.key,
    required this.adminId,
    required this.appLogoUrl,
    required this.appTitle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const FeaturedWidget(height: 130, color: AppColors.primary),
          GestureDetector(
            onLongPress: () {
              if (adminId.isNotEmpty && MySharedPreferences.userId == adminId) {
                pushScreen(context, screen: const AdminScreen());
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (appLogoUrl.isNotEmpty)
                  Center(
                    child: CustomNetworkImage(
                      url: appLogoUrl,
                      radius: 12,
                      height: 40,
                      width: 40,
                    ),
                  ),
                const SizedBox(height: 10),
                if (appTitle.isNotEmpty)
                  Center(
                    child: Text(
                      appTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                Image.asset(AppImages.logo, height: 60, width: 60),
                Transform.translate(
                  offset: const Offset(0, -15),
                  child: Center(
                    child: Text(
                      'Domandito',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Dancing_Script',
                        fontSize: 32,
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
