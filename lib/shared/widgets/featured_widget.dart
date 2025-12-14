import 'package:domandito/core/constants/app_images.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:flutter/material.dart';


class FeaturedWidget extends StatelessWidget {
  final double? height;
  final Color? color;
  const FeaturedWidget({super.key,  this.height, this.color});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
            AppImages.featchures,
            width: context.w,
            // height: 100,
            height: height,
            fit: BoxFit.fill,
            color: color?? AppColors.primary.withOpacity(0.08),
          );
  }
}