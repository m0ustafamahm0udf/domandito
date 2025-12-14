import 'package:domandito/core/constants/app_icons.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:domandito/modules/following/views/following_list.dart';
import 'package:domandito/modules/search/search.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:svg_flutter/svg.dart';

class FollowingScreen extends StatefulWidget {
  final Function(int)? followingCount;
  final bool isHome;
  const FollowingScreen({super.key, this.followingCount, this.isHome = false});

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.isHome ? 'Domandito' : !context.isCurrentLanguageAr()? 'Following' : 'أتابعهم',
            style: TextStyle(
              fontSize: widget.isHome ? 36 : null,
              fontFamily: widget.isHome ? 'Dancing_Script' : null,
            ),
          ),
          leading: widget.isHome
              ? !MySharedPreferences.isLoggedIn
                    ? IconButton.filled(
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                            AppColors.white,
                          ),
                        ),
                        onPressed: () {
                          MySharedPreferences.clearProfile(context: context);
                        },
                        icon: Directionality(
                          textDirection: TextDirection.rtl,
                          child: SvgPicture.asset(
                            AppIcons.logout,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : null
              : IconButton.filled(
                  onPressed: () => context.back(),
                  icon: Icon(Icons.arrow_back),
                ),
          actions: [
            if (widget.isHome)
              IconButton.filled(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(AppColors.white),
                ),
                onPressed: () =>
                    pushScreen(context, screen: SearchUsersScreen()),
                icon: SvgPicture.asset(
                  AppIcons.searchIcon,
                  color: AppColors.primary,
                ),
              ),
          SizedBox(width: 4),

          ],
        ),
        body: SafeArea(
          bottom: false,

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: Column(
              children: [
                SizedBox(height: 20),
                FollowingList(followingCount: widget.followingCount),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
