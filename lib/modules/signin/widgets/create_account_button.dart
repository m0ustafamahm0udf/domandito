import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/custom_bounce_button.dart';
import 'package:flutter/material.dart';

class CreateAccountButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CreateAccountButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return BounceButton(
      radius: 60,
      gradient: LinearGradient(
        colors: [AppColors.primary, Colors.purple],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      padding: 0,
      title: !context.isCurrentLanguageAr() ? 'Create Account' : 'إنشاء حساب',
      onPressed: onPressed,
    );
  }
}
