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
  const CustomDialog(
      {super.key,
      required this.title,
      required this.onConfirm,
      required this.content,
      this.isConfirm = true});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text(
          title,
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: Text(
          content,
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: BounceButton(
                  onPressed: () {
                    if (!isConfirm) {
                      onConfirm();
                    }
                    else{
                    Navigator.pop(context, false);

                    }
                  },
                  title: !isConfirm ? 
                  
                  !context.isCurrentLanguageAr()? 'Ok' :'موافق' : !context.isCurrentLanguageAr()? 'Cancel' : 'إلغاء',
                  height: 40,
                  isOutline: isConfirm,
                ),
              ),
              if (isConfirm) SizedBox(width: AppConstance.hPadding),
              if (isConfirm)
                Expanded(
                  child: BounceButton(
                    height: 40,
                    onPressed: () => Navigator.pop(context, true),
                    title:
                    !context.isCurrentLanguageAr()? 'Confirm' : 'تأكيد',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
