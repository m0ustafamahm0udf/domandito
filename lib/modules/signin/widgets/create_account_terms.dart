import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/modules/terms/teerms.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:flutter/material.dart';

class CreateAccountTerms extends StatelessWidget {
  final bool agreeToTerms;
  final String? termsError;
  final ValueChanged<bool?> onChanged;

  const CreateAccountTerms({
    super.key,
    required this.agreeToTerms,
    this.termsError,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              value: agreeToTerms,
              activeColor: AppColors.primary,
              onChanged: onChanged,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  context.to(const TermsScreen());
                },
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                      fontSize: 13,
                    ),
                    children: [
                      TextSpan(
                        text: context.isCurrentLanguageAr()
                            ? 'أوافق على '
                            : 'I agree to the ',
                      ),
                      TextSpan(
                        text: context.isCurrentLanguageAr()
                            ? 'الشروط والأحكام'
                            : 'Terms & Conditions',
                        style: const TextStyle(
                          color: Colors.indigo,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (termsError != null)
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 8),
            child: Text(
              termsError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
