import 'package:domandito/core/constants/app_icons.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:flutter/material.dart';

import 'package:svg_flutter/svg_flutter.dart';

class CustomBackButton extends StatelessWidget {
  final bool backIsWhite;
  final bool isColored;

  const CustomBackButton({
    super.key,
    this.backIsWhite = false,
    this.isColored = false,
  });

  @override
  Widget build(BuildContext context) {
    return !isColored
        ? IconButton(
            onPressed: () => context.back(),
            icon: context.isCurrentLanguageAr()
                ? Transform.flip(
                    flipX: true,
                    child: SvgPicture.asset(
                      AppIcons.back,
                      height: 24,
                      width: 24,
                      color: backIsWhite ? Colors.white : null,
                    ),
                  )
                : SvgPicture.asset(
                    AppIcons.back,
                    height: 24,
                    width: 24,
                    color: backIsWhite ? Colors.white : null,
                  ),
          )
        : IconButton.filled(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(AppColors.primary),
            ),
            onPressed: () => context.back(),
            icon: context.isCurrentLanguageAr()
                ? Transform.flip(
                    flipX: true,
                    child: SvgPicture.asset(
                      AppIcons.back,
                      height: 24,
                      width: 24,
                      color: AppColors.white,
                    ),
                  )
                : SvgPicture.asset(
                    AppIcons.back,
                    height: 24,
                    width: 24,
                    color: AppColors.white,
                  ),
          );
  }
}
