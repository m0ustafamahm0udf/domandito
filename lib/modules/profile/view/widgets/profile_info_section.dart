import 'package:domandito/core/constants/app_icons.dart';
import 'package:domandito/modules/signin/models/user_model.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

class ProfileInfoSection extends StatelessWidget {
  final UserModel user;
  final bool isMe;
  final bool isBlocked;
  final bool blockLoading;
  final VoidCallback onToggleBlock;

  const ProfileInfoSection({
    super.key,
    required this.user,
    required this.isMe,
    required this.isBlocked,
    required this.blockLoading,
    required this.onToggleBlock,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _nameWidget(),
        const SizedBox(height: 5),
        _userNameWidget(),
        if (user.bio.isNotEmpty) ...[
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              user.bio,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
        ],
      ],
    );
  }

  Row _nameWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          user.name,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        if (user.isVerified) const SizedBox(width: 2),
        if (user.isVerified)
          SvgPicture.asset(
            AppIcons.verified,
            height: 20,
            width: 20,
            color: AppColors.primary,
          ),
      ],
    );
  }

  Center _userNameWidget() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '@${user.userName}',
            textDirection: TextDirection.ltr,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          SizedBox(width: 5),
          if (!isMe)
            GestureDetector(
              onTap: blockLoading ? null : onToggleBlock,
              child: blockLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CupertinoActivityIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : CircleAvatar(
                      radius: 12,
                      backgroundColor: isBlocked
                          ? Colors.red
                          : Colors.transparent,
                      child: Icon(
                        isBlocked ? Icons.block_sharp : Icons.block_outlined,
                        color: isBlocked ? Colors.white : Colors.red,
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}
