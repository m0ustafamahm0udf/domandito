import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/constants/app_icons.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/profile_tile.dart';
import 'package:flutter/material.dart';

class AccountSettingsList extends StatelessWidget {
  final Function(int) onTileTap;

  const AccountSettingsList({super.key, required this.onTileTap});

  static const List<String> _profileTilesAr = [
    'تعديل الحساب',
    'الشروط والاحكام',
    'سياسة الخصوصية',
    'مشاركة التطبيق',
    'إبلاغ عن مشكلة',
    'تسجيل خروج',
    'حذف الحساب',
  ];

  static const List<String> _profileTilesEn = [
    'Edit Profile',
    'Terms and Conditions',
    'Privacy Policy',
    'Share App',
    'Report Problem',
    'Logout',
    'Delete Account',
  ];

  static const List<String> _icons = [
    AppIcons.profile,
    AppIcons.terms,
    AppIcons.privacy,
    AppIcons.share,
    AppIcons.warning,
    AppIcons.logout,
    AppIcons.delete,
  ];

  @override
  Widget build(BuildContext context) {
    final isAr = context.isCurrentLanguageAr();

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(
        top: AppConstance.vPadding,
        left: AppConstance.hPaddingBig,
      ),
      shrinkWrap: true,
      itemCount: _icons.length,
      separatorBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppConstance.hPadding),
        child: const Divider(color: AppColors.greye8, height: 10),
      ),
      itemBuilder: (context, index) {
        final color = (index == 4 || index == 5)
            ? AppColors.error3c
            : AppColors.primary;

        return ProfileTile(
          size: index == 6 ? 24 : 25,
          title: isAr ? _profileTilesAr[index] : _profileTilesEn[index],
          icon: _icons[index],
          onTap: () => onTileTap(index),
          color: color,
        );
      },
    );
  }
}
