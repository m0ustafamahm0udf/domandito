import 'package:domandito/shared/style/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

class SocialButton extends StatelessWidget {
  //   title: 'Sign in with Google'.tr,
  //   onPressed: () {},
  //   icon: AppIcons.google,
  final String title;
  final String icon;
  final void Function()? onPressed;
  const SocialButton({
    super.key,
    required this.title,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: SvgPicture.asset(icon , color: AppColors.primary,),
      label: Text(
        title,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 14,
          fontFamily: 'Rubik',
          fontWeight: FontWeight.bold,
        ),
      ),
      iconAlignment: IconAlignment.end,
      style: ButtonStyle(
        elevation: WidgetStateProperty.all<double>(0),
        fixedSize: WidgetStateProperty.all(
          Size(MediaQuery.of(context).size.width, 50),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(66)),
        ),
        backgroundColor: WidgetStateProperty.all<Color>(
          AppColors.white,
        ),
      ),
    );
  }
}
