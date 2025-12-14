import 'package:animate_do/animate_do.dart';
import 'package:domandito/core/constants/app_icons.dart';
import 'package:domandito/core/constants/app_images.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:one_context/one_context.dart';
import 'package:svg_flutter/svg_flutter.dart';

import 'package:toastification/toastification.dart';

class AppConstance {
  static const double hPaddingTiny = 8;
  static const double vPaddingTiny = 8;
  static const double hPadding = 16;
  static const double vPadding = 16;
  static const double vPaddingBig = 32;
  static const double gap = 20;
  static const double hPaddingBig = 32;
  static const double radiusBig = 24;
  static const double radiusSmall = 16;
  static const double radiusTiny = 12;

  // Web
  static const String web = "Web";
  static const String webAndroid = "Web - Android";
  static const String webIOS = "Web - iOS";
  static const String webDesktop = "Web - Desktop";

  // Mobile App
  static const String androidApp = "Android App";
  static const String iosApp = "iOS App";

  // Desktop App
  static const String windowsApp = "Windows App";
  static const String macOSApp = "MacOS App";
  static const String linuxApp = "Linux App";

  // Generic
  static const String unknown = "Unknown";

  static const String asnwered = "تم الإجابة على سؤالك";
  static const String liked = 'إعجاب جديد على إجابتك';
  static const String questioned = 'لديك سؤال جديد 🌚';
  static const String followed = 'لديك متابعة جديدة';

  String answeredQNotification({required BuildContext context}) {
    return context.isCurrentLanguageAr()
        ? asnwered
        : 'Your question has been answered';
  }

  String likedAnswerNotification({required BuildContext context}) {
    return context.isCurrentLanguageAr()
        ? liked
        : 'New like on your answer';
  }

  String questionedNotification({required BuildContext context}) {
    return context.isCurrentLanguageAr()
        ? questioned
        : 'You have a new question 🌚';
  }

  String followedNotification({required BuildContext context}) {
    return context.isCurrentLanguageAr()
        ? followed
        : 'You have a new follower';
  }

  static const double textFieldH = 18;
  static const String appVersion = "1.0.0";
  static const String question = "question";
  static const String like = "like";
  static const String follow = "follow";
  static const String answer = "answer";
  static const String url = "url";

  // static const String CART_ITEM_BOX = 'CART_ITEM_BOX';

  // For uploading images
  static const String accessKey = 'DO00LTAVLD67VPDZPH68';
  static const String secretKey = 'jE7BgwyXs6KAaBpOTwEX1toE6gnKvzptPRxA0Z92WoA';
  static const String region = 'ams3';
  static const String bucketName = 'domandito';
  static const String endpoint =
      'https://domandito.ams3.digitaloceanspaces.com/';
  static const String destinationPath = 'profiles';
  static const String phonePrefix = '+2';

  static const String product = "PRODUCT";
  static const String offer = "OFFER";
  static const String shareLink = "domandito-rbuqt.ondigitalocean.app/";

  static const String digitaloceanspacesLink =
      "https://domandito.ams3.digitaloceanspaces.com/";

  showErrorToast(
    BuildContext context, {
    required String msg,
    int duration = 3,
  }) {
    toastification.show(
      closeOnClick: true,

      alignment: Alignment.topCenter,
      style: ToastificationStyle.minimal,
      primaryColor: AppColors.error3c,
      type: ToastificationType.error,
      borderSide: BorderSide(color: AppColors.error3c),
      context: context,
      title: Text(msg, style: TextStyle(color: AppColors.error3c)),
      autoCloseDuration: Duration(seconds: duration),
      // applyBlurEffect: true,
      direction: !context.isCurrentLanguageAr()
          ? TextDirection.ltr
          : TextDirection.rtl,

      showProgressBar: false,
      dismissDirection: DismissDirection.down,
    );
  }

  showInfoToast(
    BuildContext context, {
    required String msg,
    int duration = 3,
    bool isLogin = false,
  }) {
    toastification.show(
      closeButton: ToastCloseButton(
        buttonBuilder: (context, onClose) {
          if (isLogin) {
            return TextButton(
              child: Text(
                !context.isCurrentLanguageAr() ? 'Log in' : 'تسجيل الدخول',
                style: TextStyle(color: AppColors.primary, fontSize: 10),
              ),
              onPressed: () {
                // context.toAndRemoveAll(SignInScreen());
                OneNotification.hardReloadRoot(context);
              },
            );
          } else {
            return SizedBox();
          }
        },
      ),

      // closeOnClick: true,
      alignment: Alignment.topCenter,
      style: ToastificationStyle.minimal,
      primaryColor: AppColors.warning06,
      type: ToastificationType.warning,
      borderSide: BorderSide(color: AppColors.warning06),
      context: context,
      title: Text(msg, style: TextStyle(color: AppColors.warning06)),
      autoCloseDuration: Duration(seconds: duration),
      // applyBlurEffect: true,
      direction: !context.isCurrentLanguageAr()
          ? TextDirection.ltr
          : TextDirection.rtl,

      showProgressBar: false,
      dismissDirection: DismissDirection.down,
      closeOnClick: true,
    );
  }

  showSuccesToast(
    BuildContext context, {
    required String msg,
    int duration = 3,
  }) {
    toastification.show(
      closeOnClick: true,

      alignment: Alignment.topCenter,
      // margin: EdgeInsets.only(left: 35, right: 0),
      style: ToastificationStyle.minimal,
      dismissDirection: DismissDirection.down,

      primaryColor: AppColors.success59,
      type: ToastificationType.success,
      borderSide: BorderSide(color: AppColors.success59),

      context: context,
      title: Text(msg, style: TextStyle(color: AppColors.success59)),
      autoCloseDuration: Duration(seconds: duration),
      // applyBlurEffect: true,
      direction: !context.isCurrentLanguageAr()
          ? TextDirection.ltr
          : TextDirection.rtl,
      showProgressBar: false,
    );
    // CherryToast.success(
    //   textDirection: TextDirection.rtl,
    //   animationType: AnimationType.fromTop,
    //   toastDuration: Duration(seconds: duration),
    //   animationDuration: const Duration(milliseconds: 500),
    //   title: Text(
    //     msg,
    //     textAlign: TextAlign.center,
    //   ),
    // ).show(context);
  }

  showLoading(
    BuildContext context, {
    Widget? progressIndicator,
    String msg = 'يرجى الانتظار',
    Function()? cancel,
    String asset = AppImages.loading,
    double height = 100,
    double width = 100,
  }) {
    msg = context.isCurrentLanguageAr() ? 'يرجى الانتظار' : 'Please wait';
    Loader.show(
      context,
      overlayColor: AppColors.white.withOpacity(0.9),
      progressIndicator: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeIn(
            child: customLoading(asset: asset, height: height, width: width),
          ),
          Material(
            color: Colors.transparent,
            child: Text(
              msg,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget customLoading({
    String asset = AppImages.loading,
    double height = 100,
    double width = 100,
  }) {
    return SizedBox(
      height: height,
      width: width,
      // child: LottieBuilder.asset(asset),
      child: SvgPicture.asset(
        AppIcons.anonymous,
        height: height,
        width: width,
        color: AppColors.primary.withOpacity(0.5),
      ),
    );
  }
}
