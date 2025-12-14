import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/constants/app_images.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';


class CustomNetworkImage extends StatelessWidget {
  final String url;
  final double radius;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final BoxFit boxFit;
  final bool isFireBase;
  final BorderRadiusDirectional? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CustomNetworkImage({
    super.key,
    required this.url,
    required this.radius,
    this.width,
    this.height,
    this.margin,
    this.boxFit = BoxFit.cover,
    this.isFireBase = false,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    // log("${ApiUrl.mainUrl}/$url");
    return CachedNetworkImage(
      imageUrl: url,
      memCacheHeight: 720,
      memCacheWidth: 720,
    
      imageBuilder:
          (context, imageProvider) => Container(
            width: width,
            height: height,
            margin: margin,
            decoration: BoxDecoration(
              borderRadius: borderRadius ?? BorderRadius.circular(radius),
              image: DecorationImage(image: imageProvider, fit: boxFit),
            ),
          ),
      placeholder: (context, url) {
        return SizedBox(
          width: width,
          height: height,
          child: Padding(
            padding: const EdgeInsets.all(60),
            child: placeholder ?? AppConstance().customLoading(),
          ),
        );
      },
      errorWidget:
          (context, url, error) =>
              errorWidget ??
              Container(
                width: width,
                height: height,
                margin: margin,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(radius),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Center(
                    child: Image.asset(
                      AppImages.logo,
                      fit: BoxFit.cover,
                      height: double.infinity,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),
    );
  }
}
