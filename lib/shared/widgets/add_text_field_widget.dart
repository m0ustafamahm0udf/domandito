import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddPostTextFieldWidget extends StatelessWidget {
  final String title;
  final String lastText;
  final TextEditingController textEditingController;
  final int maxLines;
  final int? maxLength;
  final TextInputType textInputType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?) validator;
  const AddPostTextFieldWidget(
      {super.key,
      required this.title,
      required this.textEditingController,
      this.maxLines = 1,
      this.maxLength,
      this.inputFormatters,
      this.textInputType = TextInputType.text,
      required this.validator,
      required this.lastText});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 12),
        ),
        // Row(
        //   // crossAxisAlignment: CrossAxisAlignment.center,
        //   // mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     Expanded(
        //       child: CustomTextField(
        //         hintText: title,
        //         horizontalPadding: 20.w,
        //         controller: textEditingController,
        //         maxLines: maxLines,
        //         minLines: 1,
        //         lenght: maxLength,
        //         inputFormatters: inputFormatters,
        //         keyboardType: textInputType,
        //         validator: validator,
        //       ),
        //     ),
        //     const SizedBox(width: 20),
        //     if (lastText.isNotEmpty)
        //       SizedBox(height: 15, child: Text(lastText)),
        //   ],
        // ),
        CustomTextField(
          // hintText: title,
          horizontalPadding: 20,
          fillColor: AppColors.white,

          controller: textEditingController,
          maxLines: maxLines,
          minLines: 1,
          lenght: maxLength,
          inputFormatters: inputFormatters,
          keyboardType: textInputType,
          validator: validator,
        )
      ],
    );
  }
}
