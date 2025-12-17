import 'package:domandito/core/constants/app_icons.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/custom_network_image.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg_flutter.dart';

class UserShareCard extends StatelessWidget {
  final String username;
  final String userImage;
  const UserShareCard({
    super.key,
    required this.username,
    required this.userImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,

      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          Container(
            width: 400,
            height: 400,
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(userImage),
                fit: BoxFit.cover,
                opacity: 0.25,
              ),
              shape: BoxShape.circle,
              // gradient: LinearGradient(
              //       colors: [Colors.purple, AppColors.primary, AppColors.primary],
              //       begin: Alignment.topLeft,
              //       end: Alignment.bottomRight,
              //     ),
              gradient: LinearGradient(
                colors: [AppColors.primary, Colors.black],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              // borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // const Spacer(),
                Opacity(
                  opacity: 0.7,
                  child: SvgPicture.asset(
                    AppIcons.anonymous,
                    height: 155,
                    width: 100,
                    color: Colors.white,
                  ),
                ),
                // LogoWidg(color: Colors.white),
                // const Spacer(),
                Transform.translate(
                  offset: const Offset(0, -30),
                  child: Text(
                    'Domandito',
                    style: const TextStyle(
                      fontFamily: 'Dancing_Script',
                      color: Colors.white70,
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Transform.translate(
                  offset: const Offset(0, -15),
                  child: Text(
                    '@$username',
                    maxLines: 1,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -5),
                  child: const Text(
                    'Ask me anonymously',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                ),

                const SizedBox(height: 30),

                // // const Spacer(),

                // Container(
                //   padding: const EdgeInsets.all(12),
                //   decoration: BoxDecoration(
                //     color: Colors.white,
                //     borderRadius: BorderRadius.circular(16),
                //   ),
                //   child: Text(
                //     'domandito.app/$username',
                //     style: TextStyle(
                //       color: AppColors.primary,
                //       fontWeight: FontWeight.bold,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
          Positioned(
            top:15 ,
            right: 400 - 120,
            child: Container(
              height: 60,
              width: 60,
              margin: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 3),
              ),
              child: ClipOval(
                child: CustomNetworkImage(
                  radius: 999,
                  url: userImage,
                  height: 175,
                  width: 175,
                  boxFit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
