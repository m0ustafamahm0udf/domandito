import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:flutter/material.dart';
// ignore: library_prefixes
// import 'package:flutter_bounce/flutter_bounce.dart' as FlutterBounce;
import 'package:bounce/bounce.dart' as flutter_bounce;

// class BounceButton extends StatefulWidget {
//   final Function() onPressed;
//   final Widget? child;
//   final String title;
//   final double height;
//   final double width;
//   final double radius;
//   final Color? color;
//   final double textSize;
//   final FontWeight fontWeight;
//   final bool isOutline;
//   final TextStyle? textStyle;
//   final double padding;
//   final Duration disableDuration;
//   final double textPadding;
//   final Widget? icon;

//   const BounceButton({
//     super.key,
//     required this.onPressed,
//     this.child,
//     this.title = '',
//     this.height = 50,
//     this.width = 167,
//     this.color,
//     this.radius = 16,
//     this.textSize = 14,
//     this.fontWeight = FontWeight.bold,
//     this.isOutline = false,
//     this.textStyle,
//     this.padding = 0,
//     this.disableDuration = const Duration(seconds: 1),
//     this.textPadding = 0,
//     this.icon ,
//   });

//   @override
//   State<BounceButton> createState() => _BounceButtonState();
// }

// class _BounceButtonState extends State<BounceButton> {
//   bool _isButtonDisabled = false;

//   void _handleOnPressed() async {
//     if (!_isButtonDisabled) {
//       setState(() {
//         _isButtonDisabled = true;
//       });

//       FocusManager.instance.primaryFocus?.unfocus();
//       widget.onPressed();

//       await Future.delayed(widget.disableDuration);

//       if (mounted) {
//         setState(() {
//           _isButtonDisabled = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: widget.padding),
//       child: flutter_bounce.Bounce(
//         duration: const Duration(milliseconds: 150),
//         onTap: _handleOnPressed,
//         child:
//             widget.child ??
//             Container(
//               alignment: Alignment.center,
//               height: widget.height,
//               // width: width,
//               padding: EdgeInsets.symmetric(horizontal: AppConstance.hPadding),

//               decoration: BoxDecoration(
//                 color: !widget.isOutline
//                     ? widget.color ?? AppColors.primary
//                     : AppColors.white,
//                 borderRadius: BorderRadius.circular(widget.radius),
//                 border: widget.isOutline
//                     ? Border.all(color: AppColors.primary, width: 0.2)
//                     : Border.all(width: 0, color: Colors.transparent),
//               ),
//               child: Padding(
//                 padding: EdgeInsets.only(bottom: widget.textPadding),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   mainAxisSize: MainAxisSize.max,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Text(
//                       widget.title,
//                       textAlign: TextAlign.center,
//                       style:
//                           widget.textStyle ??
//                           TextStyle(
//                             fontSize: widget.textSize,
//                             color: !widget.isOutline
//                                 ? AppColors.white
//                                 : AppColors.primary,
//                             fontWeight: widget.fontWeight,
//                           ),
//                     ),
//                     widget.icon != null ? const SizedBox(width: 10,) : const SizedBox.shrink(),
//                     widget.icon ?? const SizedBox.shrink(),
//                   ],
//                 ),
//               ),
//             ),
//       ),
//     );
//   }
// }

class BounceButton extends StatefulWidget {
  final Function() onPressed;
  final Widget? child;
  final String title;
  final double height;
  final double width;
  final double radius;
  final Color? color;
  final Gradient? gradient; // هنا أضفنا التدرج
  final double textSize;
  final FontWeight fontWeight;
  final bool isOutline;
  final TextStyle? textStyle;
  final double padding;
  final Duration disableDuration;
  final double textPadding;
  final Widget? icon;

  const BounceButton({
    super.key,
    required this.onPressed,
    this.child,
    this.title = '',
    this.height = 50,
    this.width = 167,
    this.color,
    this.gradient, // هنا أضفنا التدرج
    this.radius = 66,
    this.textSize = 14,
    this.fontWeight = FontWeight.bold,
    this.isOutline = false,
    this.textStyle,
    this.padding = 0,
    this.disableDuration = const Duration(seconds: 1),
    this.textPadding = 0,
    this.icon,
  });

  @override
  State<BounceButton> createState() => _BounceButtonState();
}

class _BounceButtonState extends State<BounceButton> {
  bool _isButtonDisabled = false;

  void _handleOnPressed() async {
    if (!_isButtonDisabled) {
      setState(() {
        _isButtonDisabled = true;
      });

      FocusManager.instance.primaryFocus?.unfocus();
      widget.onPressed();

      await Future.delayed(widget.disableDuration);

      if (mounted) {
        setState(() {
          _isButtonDisabled = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.padding),
      child: flutter_bounce.Bounce(
        duration: const Duration(milliseconds: 150),
        onTap: _handleOnPressed,
        child: widget.child ??
            Container(
              alignment: Alignment.center,
              height: widget.height,
              padding: EdgeInsets.symmetric(horizontal: AppConstance.hPadding),
              decoration: BoxDecoration(
                color: widget.gradient == null
                    ? (!widget.isOutline
                        ? widget.color ?? AppColors.primary
                        : AppColors.white)
                    : null, // إذا فيه gradient، اللون يبقى null
                gradient: widget.gradient, // استخدام التدرج إذا موجود
                borderRadius: BorderRadius.circular(widget.radius),
                border: widget.isOutline
                    ? Border.all(color: AppColors.primary, width: 0.2)
                    : Border.all(width: 0, color: Colors.transparent),
              ),
              child: Padding(
                padding: EdgeInsets.only(bottom: widget.textPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: widget.textStyle ??
                          TextStyle(
                            fontSize: widget.textSize,
                            color: !widget.isOutline
                                ? AppColors.white
                                : AppColors.primary,
                            fontWeight: widget.fontWeight,
                          ),
                    ),
                    if (widget.icon != null) const SizedBox(width: 10),
                    widget.icon ?? const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}
