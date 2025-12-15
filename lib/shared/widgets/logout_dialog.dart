import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/custom_bounce_button.dart';
import 'package:flutter/material.dart';


Future<dynamic> showLogOutButtomSheet({
  required BuildContext context,
  required bool isDelete,
}) {
  return showModalBottomSheet(
      isDismissible: false,
      enableDrag: false,
      useRootNavigator: true,
      routeSettings: RouteSettings(name: 'LogOutButtomSheet'),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(AppConstance.vPadding),
          width: context.w,
          // height: 205,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // SizedBox(height: AppConstance.vPadding),
              Center(
                child: Text(
                  isDelete ? !context.isCurrentLanguageAr()? 'Delete Account' : 'حذف الحساب' :!context.isCurrentLanguageAr()? 'Logout' : 'تسجيل الخروج',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
              // Divider(
              //   thickness: 0.5,
              // ),
              SizedBox(height: AppConstance.vPadding),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                Expanded(
                  child: BounceButton(
                    height: 42,
                    isOutline: true,
                    textStyle: TextStyle(
                        color: AppColors.error62,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                    color: AppColors.greyfa,
                    title:!context.isCurrentLanguageAr()? 'Cancel' : 'إلغاء',
                    onPressed: () => context.back(),
                  ),
                ),
                SizedBox(width: AppConstance.hPadding),
                Expanded(
                  child: BounceButton(
                    height: 42,
                    color: AppColors.error3c,
                    textStyle: TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                    title: isDelete ?!context.isCurrentLanguageAr()? 'Delete Account' : 'حذف الحساب' : !context.isCurrentLanguageAr()? 'Logout' : 'تسجيل الخروج',
                    onPressed: () => context.backWithValue(true),
                  ),
                ),
              ]),
              SizedBox(height: AppConstance.hPadding),
            ],
          ),
        );
      },
      context: context);
}
