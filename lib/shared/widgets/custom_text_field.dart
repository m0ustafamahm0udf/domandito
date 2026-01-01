import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/utils/utils.dart';
import 'package:domandito/shared/style/app_colors.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final String? label;
  final bool isEnabled;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextDirection? textDirection;
  final TextInputType? keyboardType;
  final bool readOnly;
  final int maxLines;
  final int? minLines;
  final int? lenght;
  final double? border;
  final Function()? onTap;
  final Function(String)? onChanged;
  final Function(String)? onSubmit;
  final Widget? suffixIcon;
  final AutovalidateMode? autoValidateMode;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? style;
  final Widget? prefixIcon;
  final TextAlign? textAlign;
  final double? horizontalPadding;
  final double padding;
  final double? minSuffixWidth;
  final double? maxSuffixWidth;
  final bool? filled;
  final Color? fillColor;
  final List<TextInputFormatter>? inputFormatters;
  final bool autoFocus;
  final TextInputAction? textInputAction;

  const CustomTextField({
    super.key,
    this.hintText,
    this.onSubmit,
    this.border = 18,
    this.label,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.textDirection,
    this.keyboardType,
    this.readOnly = false,
    this.maxLines = 1,
    this.onTap,
    this.suffixIcon,
    this.autoValidateMode = AutovalidateMode.onUserInteraction,
    this.labelStyle,
    this.hintStyle,
    this.prefixIcon,
    this.textAlign,
    this.horizontalPadding,
    this.minLines,
    this.inputFormatters,
    this.minSuffixWidth = AppConstance.vPaddingBig * 1.5,
    this.maxSuffixWidth = 100,
    this.filled,
    this.fillColor = AppColors.greyfa,
    this.onChanged,
    this.autoFocus = false,
    this.textInputAction = TextInputAction.done,
    this.lenght,
    this.isEnabled = true,
    this.style,
    this.padding = 0,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_onTextChanged);
      widget.controller?.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool isArabicText = isArabic(widget.controller?.text ?? '');
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.padding),
      child: TextFormField(
        inputFormatters: widget.inputFormatters,
        autovalidateMode: widget.autoValidateMode,
        onTap: widget.onTap,
        onFieldSubmitted: widget.onSubmit,
        enabled: widget.isEnabled,
        maxLength: widget.lenght,
        textInputAction: widget.textInputAction ?? TextInputAction.next,
        textAlign:
            widget.textAlign ??
            (isArabicText ? TextAlign.right : TextAlign.left),
        textDirection:
            widget.textDirection ??
            (isArabicText ? TextDirection.rtl : TextDirection.ltr),
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        readOnly: widget.readOnly,
        style:
            widget.style ??
            const TextStyle(fontSize: 14, color: AppColors.black),
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText,
        validator: widget.validator,
        controller: widget.controller,
        onChanged: widget.onChanged,
        obscuringCharacter: '●',
        autofocus: widget.autoFocus,
        keyboardAppearance: Brightness.light,
        decoration: InputDecoration(
          filled: true,
          fillColor: widget.fillColor,
          label: widget.label == null ? null : Text(widget.label!),
          hintText: widget.hintText,
          hintStyle:
              widget.hintStyle ??
              TextStyle(fontSize: 14, color: AppColors.greya8),
          labelStyle:
              widget.labelStyle ??
              TextStyle(color: AppColors.greya8, fontSize: 14),
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.suffixIcon,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 15,
            vertical: AppConstance.textFieldH,
          ),
          suffixIconConstraints: BoxConstraints(
            maxHeight: 50,
            minWidth: widget.minSuffixWidth == null
                ? 70
                : widget.minSuffixWidth!,
            maxWidth: widget.maxSuffixWidth == null
                ? 70
                : widget.maxSuffixWidth!,
          ),
          prefixIconConstraints: BoxConstraints(
            maxHeight: 50,
            minWidth: AppConstance.hPaddingBig * 1.25,
            maxWidth: AppConstance.hPaddingBig * 2.5,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.border ?? 18),
            borderSide: const BorderSide(color: AppColors.greyfa, width: 1),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.border ?? 18),
            borderSide: BorderSide(color: AppColors.greyfa, width: 0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.border ?? 18),
            borderSide: BorderSide(color: AppColors.greyfa, width: 0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.border ?? 18),
            borderSide: const BorderSide(color: AppColors.error3c),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.border ?? 18),
            borderSide: const BorderSide(color: AppColors.error3c),
          ),
          errorStyle: const TextStyle(fontSize: 12, color: AppColors.error3c),
        ),
      ),
    );
  }
}
