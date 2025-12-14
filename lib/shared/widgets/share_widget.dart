import 'dart:developer';

import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/constants/app_icons.dart';
import 'package:domandito/core/services/share_service.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

class ShareWidget extends StatefulWidget {
  final String userUserName;
  final String questionId;

  const ShareWidget({
    super.key,
    required this.userUserName,
    required this.questionId,
  });

  @override
  State<ShareWidget> createState() => _ShareWidgetState();
}

class _ShareWidgetState extends State<ShareWidget> {
  @override
  Widget build(BuildContext context) {
    // final cartItems = cartBox.values.toList();

    return IconButton.filled(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(AppColors.white),
      ),
      onPressed: () async {
        log(widget.questionId);
        log(widget.userUserName);
        if (widget.userUserName.isNotEmpty) {
          await ShareService.shareContent(
            data: '${AppConstance.shareLink}${widget.userUserName}',
            context: context,
          );
        } else {
          await ShareService.shareContent(
            data: '${AppConstance.shareLink}q/${widget.questionId}',
            context: context,
          );
        }
      },
      icon: SvgPicture.asset(AppIcons.share, color: AppColors.primary),
      // icon: Icon(Icons.switch_access_shortcut_add_outlined, color: AppColors.primary),
    );
  }
}
