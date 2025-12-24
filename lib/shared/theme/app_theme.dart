import 'package:domandito/shared/style/app_colors.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme({required BuildContext context}) {
    return ThemeData(
      // useMaterial3: false,
      fontFamily: 'Rubik',
      primaryColor: AppColors.white,
      // secondaryHeaderColor: AppColors.primary,
      // fontFamily: context.isCurrentLanguageAr() ? 'Din' : 'Almarai',
      scaffoldBackgroundColor: AppColors.white,
      // colorScheme: ColorScheme.fromSeed(
      //   seedColor: AppColors.primary,
      //   primary: AppColors.primary,
      //   secondary: AppColors.secondary,
      // ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.white),
          iconColor: WidgetStatePropertyAll(AppColors.primary),
        ),
      ),
      textTheme: const TextTheme(
        bodySmall: TextStyle(color: AppColors.black, fontSize: 14),
        bodyMedium: TextStyle(color: AppColors.black, fontSize: 16),
        bodyLarge: TextStyle(color: AppColors.black, fontSize: 18),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(AppColors.primary),
        thickness: WidgetStatePropertyAll(3),
        radius: Radius.circular(100),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        fillColor: WidgetStatePropertyAll<Color>(AppColors.primary),
        checkColor: WidgetStatePropertyAll<Color>(AppColors.white),
        side: BorderSide(color: AppColors.primary, width: 1),
      ),
      cupertinoOverrideTheme: CupertinoThemeData(
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(fontFamily: 'Rubik'),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        overlayColor: WidgetStatePropertyAll(AppColors.primary),
        labelStyle: TextStyle(
          fontSize: 14,
          fontFamily: 'Rubik',
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14,
          fontFamily: 'Rubik',
          fontWeight: FontWeight.bold,
        ),
        labelColor: AppColors.white,
        unselectedLabelColor: AppColors.greyfa,
        indicatorColor: AppColors.white,
      ),

      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          iconColor: WidgetStatePropertyAll(AppColors.primary),
          backgroundColor: WidgetStatePropertyAll(Colors.transparent),
          overlayColor: WidgetStatePropertyAll(Colors.transparent),
          textStyle: WidgetStatePropertyAll(
            TextStyle(
              fontFamily: 'Rubik',
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(backgroundColor: Colors.white),
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.white,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        // color: AppColors.white,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primary,
        // centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.white),
        shadowColor: AppColors.primary,
        // color: AppColors.primary,
        toolbarHeight: 100,
        titleTextStyle: TextStyle(
          fontSize: 24,
          color: AppColors.white,
          fontWeight: FontWeight.bold,
          fontFamily: 'Rubik',
        ),
      ),
    );
  }
}
