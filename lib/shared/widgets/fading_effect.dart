import 'package:domandito/shared/style/app_colors.dart';
import 'package:flutter/material.dart';

class FadingEffect extends StatelessWidget {
  final bool isFromTop;
  final double height;
  const FadingEffect({super.key, this.isFromTop = false, this.height = 30});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isFromTop ? Alignment.topCenter : Alignment.bottomCenter,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              if (isFromTop && height < 50) ...[
                AppColors.white,
                AppColors.white.withOpacity(0.9),
                AppColors.white.withOpacity(0.8),
                AppColors.white.withOpacity(0.7),
                AppColors.white.withOpacity(0.6),
                AppColors.white.withOpacity(0.5),
                AppColors.white.withOpacity(0.4),
                AppColors.white.withOpacity(0.3),
                AppColors.white.withOpacity(0.2),
                AppColors.white.withOpacity(0.1),
                AppColors.white.withOpacity(0),
                Colors.transparent,
              ] else if (isFromTop && height > 50) ...[
                AppColors.white,
                AppColors.white,
                AppColors.white.withOpacity(0.95),
                AppColors.white.withOpacity(0.9),
                AppColors.white.withOpacity(0.85),
                AppColors.white.withOpacity(0.8),
                AppColors.white.withOpacity(0.75),
                AppColors.white.withOpacity(0.7),
                AppColors.white.withOpacity(0.65),
                AppColors.white.withOpacity(0.6),
                AppColors.white.withOpacity(0.55),
                AppColors.white.withOpacity(0.5),
                AppColors.white.withOpacity(0.45),
                AppColors.white.withOpacity(0.4),
                AppColors.white.withOpacity(0.35),
                AppColors.white.withOpacity(0.3),
                AppColors.white.withOpacity(0.25),
                AppColors.white.withOpacity(0.2),
                AppColors.white.withOpacity(0.15),
                AppColors.white.withOpacity(0.1),
                AppColors.white.withOpacity(0),
                Colors.transparent,
                Colors.transparent,
              ] else ...[
                AppColors.white.withOpacity(0),
                AppColors.white.withOpacity(0.3),
                AppColors.white.withOpacity(0.5),
                AppColors.white.withOpacity(0.8),
                AppColors.white,
              ]
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }
}
