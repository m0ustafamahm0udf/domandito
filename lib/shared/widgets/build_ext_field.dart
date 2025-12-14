import 'package:domandito/shared/style/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


Widget buildTextField({
  required String label,
  required TextEditingController controller,
  bool readOnly = false,
  bool isPhone = false,
  bool obscureText = false,
  bool isEmail = false,
  TextInputAction textInputAction = TextInputAction.done,
  List<TextInputFormatter>? inputFormatters,
  TextInputType? keyboardType,
  Function()? onTap,
  Widget? suffixIcon,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextFormField(
      textDirection: TextDirection.rtl,
      readOnly: readOnly,
      controller: controller,
      textInputAction: textInputAction,
      onTap: onTap,
      minLines: 1,
      scrollPhysics: const NeverScrollableScrollPhysics(),
      style: const TextStyle(fontFamily: 'Rubik', fontSize: 14),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        suffixIcon: suffixIcon,
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14, color: AppColors.black),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      obscureText: obscureText,
      inputFormatters: inputFormatters,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label مطلوب';
        }
        if (isPhone) {
          if (value.length != 11) {
            return '$label يجب أن يتكون من 11 رقماً';
          }
        }
        if (obscureText) {
          if (value.length < 6) {
            return 'لابد أن تكون كلمة المرور أكثر من 6 حروف';
          }
        }
        // Email validation
        if (isEmail) {
          String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
          RegExp regExp = RegExp(pattern);
          if (!regExp.hasMatch(value)) {
            return 'صيغة البريد الإلكتروني غير صحيحة';
          }
        }
        return null;
      },
    ),
  );
}
