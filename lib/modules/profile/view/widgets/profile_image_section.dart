import 'package:domandito/core/constants/app_platforms_serv.dart';
import 'package:domandito/core/services/get_device_serv.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/modules/signin/models/user_model.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/custom_network_image.dart';
import 'package:domandito/shared/widgets/image_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class ProfileImageSection extends StatelessWidget {
  final UserModel user;
  final bool isMe;
  final bool isBlocked;
  final VoidCallback onEditProfile;

  const ProfileImageSection({
    super.key,
    required this.user,
    required this.isMe,
    required this.isBlocked,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    final platform = PlatformService.platform;

    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.w * 0.22,
            vertical: 6,
          ),
          child: GestureDetector(
            onTap: isBlocked
                ? null
                : () {
                    if (isMe) {
                      pushScreen(
                        context,
                        screen: ImageViewScreen(
                          images: [user.image],
                          // title: '',
                          onBack: (i) {},
                        ),
                      );
                    }
                  },
            child: Container(
              height: 175,
              width: 175,
              padding: const EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 1),
              ),
              child: ClipOval(
                child: CustomNetworkImage(
                  radius: 999,
                  url: user.image,
                  height: 175,
                  width: 175,
                  boxFit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        if (isMe)
          if (AppPlatform.webAndroid != platform &&
              AppPlatform.webIOS != platform &&
              AppPlatform.webDesktop != platform)
            Positioned(
              top: 20,
              left: context.w * 0.24,
              child: Container(
                // padding: const EdgeInsets.all(0.0),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: onEditProfile,
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(
                      AppColors.primary,
                    ),
                  ),
                  icon: Icon(Icons.edit, color: AppColors.white),
                ),
              ),
            ),
      ],
    );
  }
}
