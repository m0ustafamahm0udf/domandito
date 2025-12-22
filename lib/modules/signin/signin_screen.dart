import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/utils.dart';
import 'package:domandito/modules/signin/widgets/signin_footer.dart';
import 'package:domandito/modules/signin/widgets/signin_header.dart';
import 'package:domandito/modules/signin/widgets/signin_social_buttons.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool mustlogin = false;
  getMustLogin() async {
    mustlogin = await mustLogin();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getMustLogin();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.primary,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Stack(
          children: [
            Container(
              height: context.h,
              width: context.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple, AppColors.primary, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12, right: 20, left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(height: size.height * 0.01),
                  const SignInHeader(),
                  SizedBox(height: size.height * 0.05),
                  Column(
                    children: [
                      const SignInSocialButtons(),
                      const SizedBox(height: 10),
                      SignInFooter(mustLogin: mustlogin),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
