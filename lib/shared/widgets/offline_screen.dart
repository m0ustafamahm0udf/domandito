import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:flutter/material.dart';

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppConstance.hPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // SvgPicture.asset(AppIcons.offline),
              Center(
                child: Text(
               !context.isCurrentLanguageAr()? "No internet connection" :    "لا يوجد اتصال بالانترنت",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              // Center(
              //   child: Text(
              //     "Failed to connect, please check the network connection of your device."
              //         .tr(),
              //     textAlign: TextAlign.center,
              //     style: TextStyle(color: AppColors.black.withOpacity(0.3)),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
