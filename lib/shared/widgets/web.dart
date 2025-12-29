import 'package:domandito/shared/style/app_colors.dart';
import 'package:flutter/material.dart';

class WebFixedSizeWrapper extends StatelessWidget {
  final Widget child;

  const WebFixedSizeWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // مقاس ثابت للعرض والارتفاع (مثال: iPhone X)
    const double fixedWidth = 500;
    const double fixedHeight = 1080;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, AppColors.primary, AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: fixedWidth,
                maxHeight: fixedHeight,
                minWidth: fixedWidth,
                // minHeight: fixedHeight,
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
