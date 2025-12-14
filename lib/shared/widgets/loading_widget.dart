import 'package:domandito/core/constants/app_images.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingWidget extends StatelessWidget {
  final String loadingAsset;
  final double? height;
  final double? width;

  const LoadingWidget({super.key,  this.loadingAsset = AppImages.loading, this.height = 150, this.width = 150});

  @override
  Widget build(BuildContext context) {
    return LottieBuilder.asset(loadingAsset, height: height, width: width);
  }
}
