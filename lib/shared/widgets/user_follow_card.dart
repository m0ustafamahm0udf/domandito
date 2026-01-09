import 'package:domandito/core/constants/app_icons.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:domandito/modules/ask/models/q_model.dart';
import 'package:domandito/modules/profile/view/profile_screen.dart';
import 'package:domandito/shared/models/follow_model.dart';
import 'package:domandito/shared/services/follow_service.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/custom_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:svg_flutter/svg.dart';

class UserFollowCard extends StatefulWidget {
  final Receiver user;

  const UserFollowCard({super.key, required this.user});

  @override
  State<UserFollowCard> createState() => _UserFollowCardState();
}

class _UserFollowCardState extends State<UserFollowCard> {
  bool isFollowing = false;
  bool isLoading = true;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    _checkFollowStatus();
  }

  Future<void> _checkFollowStatus() async {
    if (!MySharedPreferences.isLoggedIn) {
      if (mounted) setState(() => isLoading = false);
      return;
    }

    if (MySharedPreferences.userId == widget.user.id) {
      if (mounted) setState(() => isLoading = false);
      return;
    }

    try {
      final status = await FollowService.isFollowing(
        myId: MySharedPreferences.userId,
        targetUserId: widget.user.id,
      );
      if (mounted) {
        setState(() {
          isFollowing = status;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // If it's me, don't show the card? Or just don't show the button?
    // User requested "card for the user... with follow button".
    // If it's me, showing a card to follow myself is weird. I'll hide it or show without button.
    // The "Following page" logic hides the button or handles it.
    // Let's assume we show the card but maybe hide the button if it's me.

    final isMe = MySharedPreferences.userId == widget.user.id;

    if (isMe) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        pushScreen(context, screen: ProfileScreen(userId: widget.user.id));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            CustomNetworkImage(
              url: widget.user.image,
              radius: 999,
              height: 50,
              width: 50,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.user.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.user.isVerified)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: SvgPicture.asset(
                            AppIcons.verified,
                            height: 14,
                            width: 14,
                            color: AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                  Text(
                    "@${widget.user.userName}",
                    textDirection: TextDirection.ltr,
                    maxLines: 1,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (!isMe && MySharedPreferences.isLoggedIn)
              if (isLoading)
                const CupertinoActivityIndicator(color: AppColors.primary)
              else
                SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFollowing
                          ? Colors.grey[300]
                          : AppColors.primary,
                      foregroundColor: isFollowing
                          ? Colors.black
                          : Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      if (isProcessing) return;
                      setState(() => isProcessing = true);

                      final res = await FollowService.toggleFollow(
                        context: context,
                        me: FollowUser(
                          id: MySharedPreferences.userId,
                          name: MySharedPreferences.userName,
                          image: MySharedPreferences.image,
                          userName: MySharedPreferences.userUserName,
                          userToken: MySharedPreferences.deviceToken,
                        ),
                        targetUser: FollowUser(
                          id: widget.user.id,
                          name: widget.user.name,
                          userName: widget.user.userName,
                          image: widget.user.image,
                          userToken: widget.user.token,
                          isVerified: widget.user.isVerified,
                        ),
                      );

                      if (mounted) {
                        setState(() {
                          // toggleFollow returns the NEW status (true if following, false if unfollowed)
                          // Wait, let's double check toggleFollow return.
                          // It returns `isNowFollowing`.
                          isFollowing = res;
                          isProcessing = false;
                        });
                      }
                    },
                    child: isLoading
                        ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : Text(
                            isFollowing
                                ? (!context.isCurrentLanguageAr()
                                      ? "Following"
                                      : "أتابعه")
                                : (!context.isCurrentLanguageAr()
                                      ? "Follow"
                                      : "متابعة"),
                            style: const TextStyle(fontSize: 12),
                          ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
