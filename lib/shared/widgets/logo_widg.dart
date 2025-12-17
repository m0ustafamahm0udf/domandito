

import 'package:domandito/core/constants/app_icons.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:svg_flutter/svg.dart';

class LogoWidg extends StatelessWidget {
  final Color? color;
  const LogoWidg({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      AppIcons.anonymous,
      height: context.h / 6,
      width: context.h / 6,
      color:color ?? AppColors.primary.withOpacity(0.1),
    );
  }
}
