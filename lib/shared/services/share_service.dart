import 'dart:io';
import 'package:domandito/core/constants/app_constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../shared/widgets/user_share_card.dart';

class ShareService {
  static final ScreenshotController _controller = ScreenshotController();

  static Future<void> shareUserCard({
    required String username,
    required String userImage,
  }) async {
    final image = await _controller.captureFromWidget(
      UserShareCard(username: username, userImage: userImage),
      pixelRatio: 2,
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/user_$username.png');

    await file.writeAsBytes(image);

    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'Ask me at ${AppConstance.shareLink}#/$username');
  }
}
