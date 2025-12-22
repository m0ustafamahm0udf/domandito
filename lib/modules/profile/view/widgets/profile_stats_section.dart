import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/utils.dart';
import 'package:domandito/modules/signin/models/user_model.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:flutter/material.dart';

class ProfileStatsSection extends StatelessWidget {
  final UserModel user;
  final bool isMe;
  final Function(int)? onFollowingUpdated;
  final VoidCallback onFollowingTap;
  final int questionsCount;

  const ProfileStatsSection({
    super.key,
    required this.user,
    required this.isMe,
    this.onFollowingUpdated,
    required this.onFollowingTap,
    required this.questionsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Text(
                formatNumber(user.followersCount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'Dancing_Script',
                ),
              ),
              Text(
                !context.isCurrentLanguageAr() ? 'Followers' : 'المتابعين',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          SizedBox(
            height: 20,
            child: VerticalDivider(
              width: 0,
              color: AppColors.primary,
              thickness: 1,
            ),
          ),
          GestureDetector(
            onTap: onFollowingTap,
            child: Container(
              color: Colors.transparent,
              child: Column(
                children: [
                  Text(
                    formatNumber(user.followingCount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'Dancing_Script',
                    ),
                  ),
                  Text(
                    !context.isCurrentLanguageAr()
                        ? 'Following'
                        : isMe
                        ? 'أتابع'
                        : 'يتابع',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20,
            child: VerticalDivider(
              width: 0,
              color: AppColors.primary,
              thickness: 1,
            ),
          ),
          Container(
            color: Colors.transparent,
            child: Column(
              children: [
                Text(
                  formatNumber(questionsCount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFamily: 'Dancing_Script',
                  ),
                ),
                Text(
                  !context.isCurrentLanguageAr() ? 'Answers' : 'إجابات',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
