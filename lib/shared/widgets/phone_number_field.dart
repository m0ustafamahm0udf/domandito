import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/shared/widgets/custom_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class PhoneNumberTextField extends StatefulWidget {
  final TextEditingController phoneCtrl;
  const PhoneNumberTextField({super.key, required this.phoneCtrl});

  @override
  State<PhoneNumberTextField> createState() => _PhoneNumberTextFieldState();
}

class _PhoneNumberTextFieldState extends State<PhoneNumberTextField> {
  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      padding: 0,

      suffixIcon: Transform.translate(
        offset: const Offset(-0, 0),
        child: Text('🇪🇬'),
      ),
      controller: widget.phoneCtrl,
      // label: 'رقم الهاتف',
      hintText: !context.isCurrentLanguageAr()
          ? 'Phone Number (Optional)'
          : 'رقم الهاتف (اختياري)',
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
      ],

      // suffixIcon: Directionality(
      //     textDirection: TextDirection.ltr, child: Text('     +962')),
      // validator: (value) {
      //   if (value == null || value.isEmpty) {
      //     return !context.isCurrentLanguageAr()
      //         ? 'Please enter your phone number'
      //         : 'الرجاء إدخال رقم الهاتف';
      //   }

      //   // لازم يبدأ بـ 01 ويكون 11 رقم
      //   final regex = RegExp(r'^01[0-9]{9}$');

      //   if (!regex.hasMatch(value)) {
      //     return !context.isCurrentLanguageAr()
      //         ? 'Phone number must start with 01 and contain 11 digits'
      //         : 'رقم الهاتف يجب أن يبدأ بـ 01 ويتكون من 11 رقماً';
      //   }

      //   return null;
      // },
      validator: (value) {
        // اختياري: لو فاضي يبقى تمام
        if (value == null || value.isEmpty) {
          return null;
        }

        // لو كتب رقم → لازم يكون صحيح
        final regex = RegExp(r'^01[0-9]{9}$');

        if (!regex.hasMatch(value)) {
          return !context.isCurrentLanguageAr()
              ? 'Phone number must start with 01 and contain 11 digits'
              : 'رقم الهاتف يجب أن يبدأ بـ 01 ويتكون من 11 رقماً';
        }

        return null;
      },
    );
  }
}
