import 'package:animate_do/animate_do.dart';
import 'package:domandito/core/constants/app_icons.dart';
import 'package:domandito/core/services/launch_urls.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/utils.dart';
import 'package:svg_flutter/svg.dart';

class QRScreen extends StatelessWidget {
  const QRScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),

      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: FadeIn(
            duration: const Duration(seconds: 5),
            child: GestureDetector(
              onTap: () => LaunchUrlsService().launchBrowesr(
                uri: 'https://m0ustafamahm0ud.com',
                context: context,
              ),
              child: SvgPicture.asset(
                AppIcons.qr,
                height: context.height / 3.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
