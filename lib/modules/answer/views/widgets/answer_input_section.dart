import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

class AnswerInputSection extends StatelessWidget {
  final LayerLink layerLink;
  final TextEditingController controller;
  final Function(String) onTextChanged;

  const AnswerInputSection({
    super.key,
    required this.layerLink,
    required this.controller,
    required this.onTextChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: layerLink,
      child: CustomTextField(
        onChanged: onTextChanged,
        style: const TextStyle(fontSize: 16),
        controller: controller,
        textInputAction: TextInputAction.newline,
        minLines: 2,
        maxLines: 5,
        hintText: !context.isCurrentLanguageAr()
            ? 'Write your answer here'
            : 'إجابتك هنا',
        lenght: 350,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '';
          }
          if (value.length > 350) {
            return !context.isCurrentLanguageAr()
                ? 'Answer must be less than 350 characters'
                : 'الإجابة يجب أن تكون أقل من 350 حرف';
          }
          return null;
        },
      ),
    );
  }
}
