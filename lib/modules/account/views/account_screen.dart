import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/constants/app_icons.dart';
import 'package:domandito/core/constants/app_images.dart';
import 'package:domandito/core/constants/app_platforms_serv.dart';
import 'package:domandito/core/services/get_device_serv.dart';
import 'package:domandito/core/services/launch_urls.dart';
import 'package:domandito/core/services/share_service.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:domandito/modules/privacy/privacy.dart';
import 'package:domandito/modules/terms/teerms.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/custom_network_image.dart';
import 'package:domandito/shared/widgets/fading_effect.dart';
import 'package:domandito/shared/widgets/featured_widget.dart';
import 'package:domandito/shared/widgets/logout_dialog.dart';
import 'package:domandito/shared/widgets/profile_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  List<String> profileTiles = [
    // 'تعديل الحساب',
    'الشروط والاحكام',
    'سياسة الخصوصية',
    'مشاركة التطبيق',
    'إبلاغ عن مشكلة',
    // 'إدعمنا',
    'تسجيل خروج',
    'حذف الحساب',
  ];

  List<String> profileTilesEnglish = [
    // 'Edit Profile',
    'Terms and Conditions',
    'Privacy Policy',
    'Share App',
    'Report Problem',
    // 'Support Us',
    'Logout',
    'Delete Account',
  ];

  List<String> icons = [
    // AppIcons.profile,
    AppIcons.terms,
    AppIcons.privacy,
    AppIcons.share,
    AppIcons.warning,
    // AppIcons.star,
    AppIcons.logout,
    AppIcons.delete,
  ];
  String appVersion = '';
  String developerName = '';
  String appStoreUrl = '';
  String playStoreUrl = '';
  String phone = '';
  String facebook = '';
  String whatsapp = '';
  String appLogoUrl = '';
  String appTitle = '';
  String privacy = '';
  String terms = '';

  @override
  void initState() {
    super.initState();
    final platform = PlatformService.platform;

    FirebaseFirestore.instance
        .collection('appInfo')
        .doc('appDetails')
        .get()
        .then((value) {
          if (value.exists) {
            if (value.data() != null) {
              if (AppPlatform.androidApp == platform) {
                appVersion = value.data()!['appVersionAndroid'];
              } else {
                appVersion = value.data()!['appVersionIos'];
              }
              developerName = value.data()!['developerName'];
              appStoreUrl = value.data()!['appStoreUrl'];
              playStoreUrl = value.data()!['playStoreUrl'];

              phone = value.data()!['phone'];
              facebook = value.data()!['facebook'];
              whatsapp = value.data()!['whatsapp'];
              appLogoUrl = value.data()!['appLogoUrl'];
              appTitle = value.data()!['appTitle'];
              privacy = value.data()!['privacyPolicyUrl'];
              terms = value.data()!['termsUrl'];
              setState(() {});
            }
            // log(value.data().toString());
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    Loader.hide();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton.filled(
          icon: Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        // actions: [
        //   IconButton(
        //     onPressed: () {
        //       AppLocals().toggleLocal(
        //         context: context,
        //         locale: context.isCurrentLanguageAr()
        //             ? Locale('en')
        //             : Locale('ar'),
        //       );
        //     },
        //     icon: Text(
        //       context.isCurrentLanguageAr() ? 'English' : 'العربية',
        //       style: TextStyle(color: AppColors.primary),
        //     ),
        //   ),
        //   SizedBox(width: 8),
        // ],
      ),
      bottomNavigationBar: SizedBox(
        height: 130,
        child: Stack(
          alignment: Alignment.center,
          children: [
            FeaturedWidget(height: 130, color: AppColors.primary),
            Column(
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
                SizedBox(height: 10),
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
                SizedBox(height: 4),

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
                // Padding(
                //   padding: const EdgeInsets.symmetric(
                //     horizontal: AppConstance.gap,
                //   ),
                //   child: Center(
                //     child: Text(
                //       '"نحن بحاجة إلى دعمكم لمواصلة رحلتنا والاستمرار في خدمة أكبر عدد ممكن من الأشخاص الذين يبحثون عن أحبائهم المفقودين."',
                //       textAlign: TextAlign.center,
                //       style: TextStyle(
                //         fontSize: 14,
                //         color: AppColors.white,
                //       ),
                //     ),
                //   ),
                // ),
                // SizedBox(height: 4),

                // SizedBox(height: 10),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   crossAxisAlignment: CrossAxisAlignment.center,
                //   children: [
                //     if (facebook.isNotEmpty)
                //       GestureDetector(
                //         onTap: () async {
                //           await LaunchUrlsService().launchBrowesr(uri: facebook, context: context);
                //         },
                //         child: SvgPicture.asset(
                //           AppIcons.facebook,
                //           height: 35,
                //         ),
                //       ),
                //     SizedBox(width: 10),
                //     if (phone.isNotEmpty)
                //       GestureDetector(
                //         onTap: () async {
                //           LaunchUrlsService().launchCall(
                //             phone: phone,
                //           );
                //         },
                //         child: SvgPicture.asset(
                //           AppIcons.phone,
                //           height: 30,
                //         ),
                //       ),
                //     SizedBox(width: 10),
                //     if (whatsapp.isNotEmpty)
                //       GestureDetector(
                //         onTap: () async {
                //           LaunchUrlsService().launchWhatsApp(context: context, phone: whatsapp);
                //         },
                //         child: SvgPicture.asset(
                //           AppIcons.whatsapp,
                //           height: 30,
                //         ),
                //       ),
                //   ],
                // ),
                SizedBox(height: 10),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CustomAppbar(
            //   preTitle: '',
            //   isBack: true,
            //   isColored: true,
            //   title: MySharedPreferences.userName,
            //   subTitle: MySharedPreferences.phone,

            // ),
            // SizedBox(height: AppConstance.vPadding * 2),
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  ListView(
                    children: [
                      ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.only(
                          top: AppConstance.vPadding,
                          // right: AppConstance.hPadding,
                          left: AppConstance.hPaddingBig,
                        ),
                        shrinkWrap: true,
                        itemCount: profileTiles.length,
                        separatorBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: EdgeInsets.only(
                              right: AppConstance.hPadding,
                              left: AppConstance.hPadding,
                            ),
                            child: Divider(color: AppColors.greye8, height: 10),
                          );
                        },
                        itemBuilder: (BuildContext context, int index) {
                          return ProfileTile(
                            size: index == 5 ? 22 : 25,
                            title: !context.isCurrentLanguageAr()
                                ? profileTilesEnglish[index]
                                : profileTiles[index],
                            icon: icons[index],
                            onTap: () => getOnTap(index: index),
                            color: index == 4 || index == 5
                                ? AppColors.error3c
                                : AppColors.primary,
                          );
                        },
                      ),
                      SizedBox(height: AppConstance.vPadding * 2),

                      SizedBox(height: 40),
                      if (appVersion.isNotEmpty)
                        Center(
                          child: Text(
                            !context.isCurrentLanguageAr()
                                ? 'Version $appVersion'
                                : 'إصدار $appVersion',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  FadingEffect(isFromTop: true),
                  const FadingEffect(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  getOnTap({required int index}) async {
    switch (index) {
      // case 0:
      //   pushScreenWithoutNavBar(context, EditProfileScreen()).then((value) {
      //     setState(() {});
      //   });

      //   break;

      case 0:
        pushScreenWithoutNavBar(context, TermsScreen());

        break;
      case 1:
        pushScreenWithoutNavBar(context, PrivacyPolicyScreen());

        break;
      case 2:
        if (playStoreUrl.isNotEmpty && appStoreUrl.isNotEmpty) {
          final platform = PlatformService.platform;

          ShareService1.shareContent(
            data: AppPlatform.androidApp == platform
                ? playStoreUrl
                : appStoreUrl,
            context: context,
          );
        }
        break;
      case 3:
        await LaunchUrlsService().launchBrowesr(
          uri: facebook,
          context: context,
        );
        break;

      // case 5:
      //   await LaunchUrlsService().launchBrowesr(
      //     uri: facebook,
      //     context: context,
      //   );
      // break;
      case 4:
        final rest = await showLogOutButtomSheet(
          isDelete: false,
          context: context,
        );
        if (rest != null && rest) {
          MySharedPreferences.clearProfile(context: context);
        }
        break;
      case 5:
        // context.to(const AboutCpvApp());
        final rest = await showLogOutButtomSheet(
          isDelete: true,
          context: context,
        );
        if (rest != null && rest) {
          MySharedPreferences.clearProfile(context: context);
        }
        break;
      default:
        break;
    }
  }
}
