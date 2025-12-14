import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/custom_back_button.dart';
import 'package:flutter/material.dart';

class CustomAppbar extends StatelessWidget {
  final String title;
  final bool isBack;
  final bool isColored;
  final bool isMapScreen;
  final String preTitle;
  final String subTitle;
  final Widget? actions;
  final double subTitleTextSize;
  final bool isHome;

  const CustomAppbar({
    super.key,
    this.title = '',
    this.preTitle = '',
    this.subTitle = '',
    this.isBack = true,
    this.isColored = false,
    this.actions,
    this.isMapScreen = false,
    this.isHome = false,
    this.subTitleTextSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: isMapScreen ? Colors.transparent : Colors.white,
      foregroundColor: isMapScreen ? Colors.transparent : Colors.white,
      surfaceTintColor: isMapScreen ? Colors.transparent : Colors.white,
      elevation: 0,
      shadowColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: AppConstance.hPaddingTiny,
          top: 0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppConstance.hPaddingBig),

            if (isBack) Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomBackButton(isColored: isColored),
                actions ?? const SizedBox(),

              ],
            ),
            // if (context.isCurrentLanguageAr())
            //   FadeInLeft(from: 5, child: CustomBackButton(isColored: isColored))
            // else
            //   FadeInRight(
            //     from: 5,
            //     child: CustomBackButton(isColored: isColored),
            //   ),
            // SizedBox(height: AppConstance.vPaddingTiny),

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstance.hPadding,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (preTitle.isNotEmpty)
                    Text(
                      preTitle.toUpperCase(),
                      style: TextStyle(color: AppColors.greya9f),
                    ),
                  if (title.isNotEmpty)
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: isHome ? 36 : 24,
                      ),
                    ),
                  if (subTitle.isNotEmpty)
                    Text(
                      subTitle,
                      // textDirection: TextDirection.ltr,
                      style: TextStyle(
                        color: AppColors.greya8,
                        fontSize: subTitleTextSize,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
