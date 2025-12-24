import 'package:domandito/core/constants/app_icons.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:domandito/modules/home/home_screen.dart';
import 'package:domandito/modules/home/views/home_feed_screen.dart';
import 'package:domandito/modules/landing/controller/landing_cubit.dart';
import 'package:domandito/modules/new_questions/views/new_questions_screen.dart';
import 'package:domandito/modules/profile/view/profile_screen.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/custom_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

import 'package:svg_flutter/svg_flutter.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    super.initState();
  }

  List<PersistentTabConfig> _tabs() => [
    PersistentTabConfig(
      screen: const HomeFeedScreen(),
      item: ItemConfig(
        icon: SvgPicture.asset(
          AppIcons.anonymous,
          height: 28,
          color: currentIndex == 0
              ? AppColors.primary
              : AppColors.primary.withOpacity(0.15),
        ),
        title: "Domandito",
        textStyle: TextStyle(fontFamily: 'Dancing_Script', fontSize: 14),
        activeForegroundColor: AppColors.primary,
      ),
    ),

    //  PersistentTabConfig(
    //   screen: const ExploreLostPeople(),
    //   item: ItemConfig(
    //     icon: SvgPicture.asset(
    //       AppIcons.explore,
    //       color:
    //           currentIndex == 1
    //               ? AppColors.primary
    //               : AppColors.primary.withOpacity(0.15),
    //     ),
    //     title: "إبحث معانا",
    //     activeForegroundColor: AppColors.primary,
    //   ),
    // ),

    //  PersistentTabConfig(
    //   screen: const AddPostScreen(),
    //   item: ItemConfig(
    //     icon: SvgPicture.asset(
    //       AppIcons.addImage,
    //       color:
    //           currentIndex == 2
    //               ? AppColors.primary
    //               : AppColors.primary.withOpacity(0.15),
    //     ),
    //     title: "إضافة بلاغ",
    //     activeForegroundColor: AppColors.primary,
    //   ),
    // ),
    if (MySharedPreferences.isLoggedIn)
      PersistentTabConfig(
        screen: ProfileScreen(userId: MySharedPreferences.userId),
        item: ItemConfig(
          icon: CustomNetworkImage(
            url: MySharedPreferences.image,
            radius: 99,
            height: 28,
            width: 28,
          ),
          // icon: SvgPicture.asset(
          //   AppIcons.profile,
          //   color: currentIndex == 1
          //       ? AppColors.primary
          //       : AppColors.primary.withOpacity(0.15),
          // ),
          // title: MySharedPreferences.userUserName,
          // title: !context.isCurrentLanguageAr() ? 'Profile' : 'الملف الشخصي',
          title: '@${MySharedPreferences.userUserName}',
          textStyle: TextStyle(fontFamily: 'Dancing_Script', fontSize: 13),

          activeForegroundColor: AppColors.primary,
        ),
      ),
    if (MySharedPreferences.isLoggedIn)
      PersistentTabConfig(
        screen: const NewQuestionsScreen(),
        item: ItemConfig(
          icon: SvgPicture.asset(
            AppIcons.questions,
            color: currentIndex == 2
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.15),
          ),
          title: !context.isCurrentLanguageAr() ? "New Questions" : "جديد",
          textStyle: TextStyle(
            fontFamily: context.isCurrentLanguageAr()
                ? 'Rubik'
                : 'Dancing_Script',
            fontSize: 14,
          ),

          activeForegroundColor: AppColors.primary,
        ),
      ),
    // if (MySharedPreferences.isLoggedIn && !kIsWeb)
    //     PersistentTabConfig(
    //       screen: const NotificationsScreen(),
    //       item: ItemConfig(
    //         icon: SvgPicture.asset(
    //           AppIcons.notifications,
    //           color: currentIndex == 3
    //               ? AppColors.primary
    //               : AppColors.primary.withOpacity(0.15),
    //         ),
    //         title: "الاشعارات",
    //         activeForegroundColor: AppColors.primary,
    //       ),
    //     ),
  ];

  int currentIndex = 0;
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => LandingCubit()..getAppInfo(context: context),
    child: BlocBuilder<LandingCubit, LandingState>(
      builder: (context, state) {
        final landingCubit = context.read<LandingCubit>();

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarBrightness: Brightness.light,
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.dark,
          ),
          child: PersistentTabView(
            // screenTransitionAnimation: ScreenTransitionAnimation(
            //     curve: Curves.slowMiddle, duration: Duration(seconds: 1)),
            tabs: _tabs(),
            onTabChanged: (value) {
              setState(() {
                currentIndex = value;
              });
            },
            controller: landingCubit.controller,
            navBarBuilder: (navBarConfig) => Style7BottomNavBar(
              navBarConfig: navBarConfig,
              navBarDecoration: NavBarDecoration(color: Colors.white),
            ),
            // navBarHeight: 60,
            // navBarOverlap: NavBarOverlap.full(),
          ),
        );
      },
    ),
  );
}
