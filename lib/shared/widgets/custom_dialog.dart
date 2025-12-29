import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/custom_bounce_button.dart';
import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String content;
  final bool isConfirm;
  final dynamic Function() onConfirm;
  const CustomDialog({
    super.key,
    required this.title,
    required this.onConfirm,
    required this.content,
    this.isConfirm = true,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Allow dismissing the dialog
      child: AlertDialog(
        title: Text(
          title,
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: Text(content, style: TextStyle(fontSize: 14)),
        actions: [
          Row(
            children: [
              // Cancel button - always shown
              Expanded(
                child: BounceButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  title: !context.isCurrentLanguageAr() ? 'Cancel' : 'إلغاء',
                  height: 40,
                  isOutline: true,
                ),
              ),
              SizedBox(width: AppConstance.hPadding),
              // Confirm/View button
              Expanded(
                child: BounceButton(
                  height: 40,
                  onPressed: () {
                    if (!isConfirm) {
                      onConfirm();
                    } else {
                      Navigator.pop(context, true);
                    }
                  },
                  title: !isConfirm
                      ? (!context.isCurrentLanguageAr() ? 'View' : 'عرض')
                      : (!context.isCurrentLanguageAr() ? 'Confirm' : 'تأكيد'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
