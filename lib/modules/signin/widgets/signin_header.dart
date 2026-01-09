import 'package:animate_do/animate_do.dart';
import 'package:domandito/core/constants/app_icons.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

class SignInHeader extends StatelessWidget {
  const SignInHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Column(
          children: [
            FadeInUp(
              from: 50,
              duration: const Duration(milliseconds: 600),
              child: Transform.translate(
                offset: const Offset(0, 40),
                child: SvgPicture.asset(
                  AppIcons.anonymous,
                  color: AppColors.white,
                  width: size.height * 0.18,
                  height: size.height * 0.18,
                ),
              ),
            ),
            FadeInUp(
              from: 10,
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 200),
              child: Text(
                'Domandito',
                style: TextStyle(
                  fontSize: 62,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                  fontFamily: 'Dancing_Script',
                ),
              ),
            ),
          ],
        ),
        FadeInUp(
          from: 10,
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 350),
          child: Text(
            context.isCurrentLanguageAr()
                ? 'قول اللي في نفسك'
                : 'Domandito! anoynmously',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
        ),
      ],
    );
  }
}
