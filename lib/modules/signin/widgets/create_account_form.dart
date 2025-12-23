import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/custom_text_field.dart';
import 'package:domandito/shared/widgets/phone_number_field.dart';
import 'package:flutter/material.dart';

class CreateAccountForm extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController userNameCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController? emailCtrl;
  final TextEditingController? bioCtrl;
  final bool isEditMode;

  static const reservedUsernames = {
    "anonymous",
    "hidden",
    "admin",
    "support",
    "root",
    "system",
    "user",
    "profile",
    "owner",
    "manager",
    "test",
    "q",
    "question",
    "null",
  };

  const CreateAccountForm({
    super.key,
    required this.nameCtrl,
    required this.userNameCtrl,
    required this.phoneCtrl,
    this.emailCtrl,
    this.bioCtrl,
    this.isEditMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        // --- Email Field (Only in Edit Mode) ---
        if (isEditMode && emailCtrl != null) ...[
          Text(
            !context.isCurrentLanguageAr() ? 'Email' : 'البريد الإلكتروني',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          CustomTextField(
            controller: emailCtrl!,
            hintText: '',
            readOnly: true,
            fillColor: Colors.grey.shade100,
          ),
          const SizedBox(height: 10),
        ],

        Text(
          context.isCurrentLanguageAr() ? 'الإسم' : 'Name',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        CustomTextField(
          controller: nameCtrl,
          hintText: !context.isCurrentLanguageAr() ? 'eg: Ahmed' : 'مثال: أحمد',
          validator: (value) => value == null || value.isEmpty
              ? !context.isCurrentLanguageAr()
                    ? 'Please enter your name'
                    : 'الرجاء ادخال الإسم'
              : null,
        ),
        const SizedBox(height: 10),

        // --- Bio Field (Only if controller provided) ---
        if (bioCtrl != null) ...[
          Text(
            !context.isCurrentLanguageAr() ? 'Bio' : 'نبذة عني',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          CustomTextField(
            controller: bioCtrl!,
            hintText: !context.isCurrentLanguageAr() ? 'Bio' : 'اكتب نبذة عنك',
            maxLines: 3,
            lenght: 150,
          ),
          const SizedBox(height: 10),
        ],

        Text(
          !context.isCurrentLanguageAr() ? 'User Name' : 'اسم المستخدم',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        CustomTextField(
          suffixIcon: Text('@'),
          controller: userNameCtrl,
          hintText: !context.isCurrentLanguageAr()
              ? 'eg: ahmed'
              : 'مثال: ahmed',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return !context.isCurrentLanguageAr()
                  ? 'Please enter username'
                  : 'الرجاء إدخال اسم المستخدم';
            }

            final username = value.trim().toLowerCase();

            if (reservedUsernames.contains(username)) {
              return !context.isCurrentLanguageAr()
                  ? 'Username is not available, please choose another username'
                  : "اسم المستخدم غير متاح، برجاء اختيار اسم آخر";
            }

            final regex = RegExp(r'^[a-zA-Z][a-zA-Z0-9_.]{5,}$');
            if (!regex.hasMatch(value)) {
              return !context.isCurrentLanguageAr()
                  ? 'Username must start with an English letter\nand contain only English letters, numbers, and _ characters,\nwith a minimum length of 6 characters'
                  : 'اسم المستخدم يجب أن يبدأ بحرف إنجليزي\n'
                        'ويحتوي على حروف إنجليزية وأرقام و _ فقط\n'
                        'وبحد أدنى 6 خانات';
            }

            return null;
          },
        ),
        const SizedBox(height: 10),
        Text(
          !context.isCurrentLanguageAr()
              ? 'Phone Number (Optional)'
              : 'رقم الهاتف (اختياري)',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        PhoneNumberTextField(phoneCtrl: phoneCtrl),
      ],
    );
  }
}
