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
          child: PulseGlow(
            glowColor: AppColors.primary,
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
              height: 50,
              onPressed: () {
                if (!MySharedPreferences.isLoggedIn) {
                  onAsk();
                  return;
                }
                onAsk();
              },
              title: isMe
                  ? !context.isCurrentLanguageAr()
                        ? 'Domandito!'
                        : 'إسأل نفسك'
                  : !context.isCurrentLanguageAr()
                  ? 'Domandito!'
                  : 'إسأل',
              textSize: 18,
            ),
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
              height: 50,
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

class PulseGlow extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  const PulseGlow({super.key, required this.child, required this.glowColor});

  @override
  State<PulseGlow> createState() => _PulseGlowState();
}

class _PulseGlowState extends State<PulseGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 2.0,
      end: 10.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(60),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withOpacity(0.6),
                blurRadius: _animation.value,
                spreadRadius: _animation.value / 3,
              ),
            ],
          ),
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}
