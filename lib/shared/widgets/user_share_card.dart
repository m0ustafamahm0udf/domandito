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
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.all(20),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.primary, Colors.black],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Opacity(
                        opacity: 0.25,
                        child: CustomNetworkImage(
                          url: userImage,
                          radius: 0,
                          boxFit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Opacity(
                              opacity: 0.7,
                              child: SvgPicture.asset(
                                AppIcons.anonymous,
                                height: 155,
                                width: 100,
                                color: Colors.white,
                              ),
                            ),
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
                              offset: const Offset(0, -25),
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
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: const Alignment(-0.7, -0.8),
                  child: Container(
                    height: 60,
                    width: 60,
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
          ),
        ],
      ),
    );
  }
}
