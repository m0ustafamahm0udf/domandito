import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/constants/app_icons.dart';
import 'package:domandito/core/services/share_service.dart';
import 'package:domandito/shared/services/share_service.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:svg_flutter/svg.dart';

class ShareWidget extends StatefulWidget {
  final String userUserName;
  final String questionId;
  final String userImage;

  const ShareWidget({
    super.key,
    required this.userUserName,
    required this.questionId,
    required this.userImage,
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
        if (kIsWeb) {
          if (widget.userUserName.isNotEmpty) {
            await ShareService1.shareContent(
              data: 'Ask me at ${AppConstance.shareLink}${widget.userUserName}',
              context: context,
            );
          }
        } else {
          if (widget.userUserName.isNotEmpty) {
            AppConstance().showLoading(context);
            await ShareService.shareUserCard(
              userImage: widget.userImage,
              username: widget.userUserName,
            ).then((value) => Loader.hide());
          }
        }
      },

      // onPressed: () async {
      //   log(widget.questionId);
      //   log(widget.userUserName);
      //   if (widget.userUserName.isNotEmpty) {
      //     await ShareService.shareContent(
      //       data: '${AppConstance.shareLink}#/${widget.userUserName}',
      //       context: context,
      //     );
      //   } else {
      //     await ShareService.shareContent(
      //       data: '${AppConstance.shareLink}q/${widget.questionId}',
      //       context: context,
      //     );
      //   }
      // },
      icon: SvgPicture.asset(AppIcons.share, color: AppColors.primary),
      // icon: Icon(Icons.switch_access_shortcut_add_outlined, color: AppColors.primary),
    );
  }
}
