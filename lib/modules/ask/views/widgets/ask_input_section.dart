import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/utils.dart';
import 'package:domandito/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

class AskInputSection extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const AskInputSection({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      // autoFocus: true,
      onChanged: onChanged,
      //  hintStyle: TextStyle(fontSize: 18),
      style: const TextStyle(fontSize: 16),
      controller: controller,
      textInputAction: TextInputAction.newline,
      minLines: 2,
      maxLines: 5,
      hintText: !context.isCurrentLanguageAr() ? ' Question here' : 'سؤالك هنا',
      lenght: 350,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '';
        }
        if (value.length > 350) {
          return !context.isCurrentLanguageAr()
              ? 'Question must be less than 350 characters'
              : 'السؤال يجب أن يكون أقل من 350 حرف';
        }
        if (containsBannedWords(value)) {
          return !context.isCurrentLanguageAr()
              ? 'Your question contains prohibited words'
              : 'السؤال يحتوي على كلمات ممنوعة';
        }
        return null;
      },
    );
  }
}
