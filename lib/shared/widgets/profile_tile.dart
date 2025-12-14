import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

class ProfileTile extends StatelessWidget {
  final String title;
  final String icon;
  final Color color;
  final Function() onTap;
  final bool isSettings;
  final Widget trailing;
  final double size;
  const ProfileTile({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.color = AppColors.primary49,
    this.trailing = const SizedBox(),
    this.isSettings = false,
    this.size = 25.0,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      minLeadingWidth: isSettings ? null : 40,
      minTileHeight: isSettings ? null : 40,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstance.radiusSmall),
      ),
      leading: SvgPicture.asset(icon, color: color, height: size, width: size),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      trailing: trailing,
    );
  }
}
