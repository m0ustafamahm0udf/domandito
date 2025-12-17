import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ShareService1 {
  static shareContent({
    required String data,
    required BuildContext context,
  }) async {
    final box = context.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(
      ShareParams(
        text: data,
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }
}
