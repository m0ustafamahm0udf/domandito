import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/modules/account/views/account_screen.dart';
import 'package:domandito/modules/signin/models/user_model.dart';
import 'package:domandito/shared/widgets/share_widget.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final UserModel? user;
  final bool isLoading;
  final bool isMe;

  const ProfileAppBar({
    super.key,
    required this.user,
    required this.isLoading,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 80,
      title: !isLoading
          ? Text(
              '@${user?.userName ?? ''}',
              textDirection: TextDirection.ltr,
              style: TextStyle(
                color: Colors.white,
                // fontSize: 18,
                fontFamily: 'Dancing_Script',
              ),
            )
          : null,
      actions: [
        if (!isLoading)
          ShareWidget(
            userUserName: user?.userName ?? '',
            questionId: '',
            userImage: user?.image ?? '',
          ),
        SizedBox(width: 4),
      ],
      leading: isMe
          ? IconButton.filled(
              onPressed: () {
                pushScreen(context, screen: AccountScreen());
              },
              icon: Icon(Icons.more_vert),
            )
          : IconButton.filled(
              onPressed: () => context.back(),
              icon: Icon(Icons.arrow_back),
            ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
