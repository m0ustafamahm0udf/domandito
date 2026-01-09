import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/custom_bounce_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AskFloatingActionButtons extends StatelessWidget {
  final bool isRandomLoading;
  final VoidCallback onAskPressed;
  final VoidCallback onRandomPressed;

  const AskFloatingActionButtons({
    super.key,
    required this.isRandomLoading,
    required this.onAskPressed,
    required this.onRandomPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: BounceButton(
            radius: 60,
            height: 55,
            gradient: const LinearGradient(
              colors: [AppColors.primary, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onPressed: () {
              if (isRandomLoading) return;
              onAskPressed();
            },
            title: !context.isCurrentLanguageAr() ? 'Domandito!' : 'إسأل',
            padding: 20,
          ),
        ),
        GestureDetector(
          onTap: isRandomLoading ? null : onRandomPressed,
          child: Container(
            height: 55,
            width: 55,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primary, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: isRandomLoading
                ? const Padding(
                    padding: EdgeInsets.all(15.0),
                    child: CupertinoActivityIndicator(color: Colors.white),
                  )
                : const Icon(Icons.casino, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(width: 15),
      ],
    );
  }
}
