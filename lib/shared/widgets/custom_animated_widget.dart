import 'package:flutter/material.dart';

class CustomAnimatedWidget extends StatelessWidget {
  final int duration;
  final Offset begin;
  final Offset end;
  final Widget child;
  const CustomAnimatedWidget({super.key, this.duration = 300, this.begin = const Offset(0.0, 0.9), this.end = const Offset(0.0, 0.0), required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: duration),
      switchInCurve: Curves.easeInOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final offsetAnimation = Tween<Offset>(
          begin: begin,
          end: end,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          // child: child,
          child: SlideTransition(
            position: offsetAnimation,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
