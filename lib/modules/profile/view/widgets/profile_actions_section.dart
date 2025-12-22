import 'package:domandito/core/constants/app_icons.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:domandito/modules/signin/models/user_model.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/custom_bounce_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

class ProfileActionsSection extends StatelessWidget {
  final UserModel user;
  final bool isMe;
  final bool isFollowing;
  final bool followLoading;
  final bool isBlocked;
  final VoidCallback onAsk;
  final VoidCallback onToggleFollow;

  const ProfileActionsSection({
    super.key,
    required this.user,
    required this.isMe,
    required this.isFollowing,
    required this.followLoading,
    required this.isBlocked,
    required this.onAsk,
    required this.onToggleFollow,
  });

  @override
  Widget build(BuildContext context) {
    if (isBlocked) {
      return const SizedBox();
    }
    return Row(
      children: [
        Expanded(
          child: BounceButton(
            gradient: LinearGradient(
              colors: [AppColors.primary, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            icon: SvgPicture.asset(
              AppIcons.anonymous,
              height: 25,
              color: AppColors.white,
            ),
            radius: 60,
            height: 55,
            onPressed: () {
              if (!MySharedPreferences.isLoggedIn) {
                // Should show toast, handled by parent usually but keeping logic here requires context
                // Passed callback instead
                onAsk();
                return;
              }
              onAsk();
            },
            title: isMe
                ? !context.isCurrentLanguageAr()
                      ? 'Ask yourself'
                      : 'إسأل نفسك'
                : !context.isCurrentLanguageAr()
                ? 'Ask'
                : 'إسأل',
            textSize: 18,
          ),
        ),
        if (!isMe) SizedBox(width: 10),
        if (!isMe)
          Expanded(
            child: BounceButton(
              isOutline: !isFollowing,
              gradient: !isFollowing
                  ? null
                  : LinearGradient(
                      colors: [AppColors.primary, Colors.deepOrange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              icon: SvgPicture.asset(
                AppIcons.anonymous,
                height: 25,
                color: isFollowing ? AppColors.white : AppColors.primary,
              ),
              radius: 60,
              height: 55,
              onPressed: () {
                if (!followLoading) {
                  onToggleFollow();
                }
              },
              title: followLoading
                  ? ''
                  : isFollowing
                  ? !context.isCurrentLanguageAr()
                        ? 'Unfollow'
                        : "إلغاء المتابعة"
                  : !context.isCurrentLanguageAr()
                  ? 'Follow'
                  : "متابعة",
              textSize: 18,
              child: followLoading
                  ? const Center(
                      child: SizedBox(
                        height: 22,
                        width: 22,
                        child: CupertinoActivityIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
      ],
    );
  }
}
