import 'package:flutter/material.dart';

class WebFixedSizeWrapper extends StatelessWidget {
  final Widget child;

  const WebFixedSizeWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // مقاس ثابت للعرض والارتفاع (مثال: iPhone X)
    const double fixedWidth = 720;
    const double fixedHeight = 1080;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: fixedWidth,
              maxHeight: fixedHeight,
              minWidth: fixedWidth,
              // minHeight: fixedHeight,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              
              child: child),
          ),
        );
      },
    );
  }
}
