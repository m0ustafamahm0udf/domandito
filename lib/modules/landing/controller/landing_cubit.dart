// import 'dart:developer';

import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/constants/app_platforms_serv.dart';
import 'package:domandito/core/services/get_device_serv.dart';
import 'package:domandito/core/services/launch_urls.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/custom_bounce_button.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'landing_state.dart';

class LandingCubit extends Cubit<LandingState> {
  LandingCubit() : super(LandingInitial());
  PersistentTabController controller = PersistentTabController(initialIndex: 0);
  String facebookAppLink = '';
  bool isProduction = false;
  getAppInfo({required BuildContext context}) async {
    await FirebaseFirestore.instance
        .collection('appInfo')
        .doc('appDetails')
        .get()
        .then((value) {
          if (value.exists) {
            if (value.data() != null) {
              facebookAppLink = value.data()!['facebook'];
              isProduction = value.data()!['isProduction'];
              if (!isProduction) {
                showDialog(
                  context: context,
                  builder: (context) => PopScope(
                    canPop: false,
                    child: AlertDialog(
                      title: Text(
                        !context.isCurrentLanguageAr()
                            ? 'Wait for us 🔥'
                            : 'انتظرونا 🔥',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      content: Text(
                        !context.isCurrentLanguageAr()
                            ? 'We will make some changes to the app properties and it will be updated soon, thanks'
                            : 'نقوم بتعديل بعض الخصائص الخاصة بالتطبيق وسيتم التحديث قريبا , شكرا لك',
                        style: TextStyle(fontSize: 14),
                      ),
                      actions: [
                        BounceButton(
                          height: 40,
                          onPressed: () {
                            LaunchUrlsService().launchBrowesr(
                              uri: value.data()!['facebook'],
                              context: context,
                            );
                          },
                          title: !context.isCurrentLanguageAr()
                              ? 'Ok'
                              : 'موافق',
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                if (!kIsWeb) {
                  chackUpdate(
                    context: context,
                    appStoreUrl: value.data()!['appStoreUrl'],
                    playStoreUrl: value.data()!['playStoreUrl'],
                    versionIos: value.data()!['appVersionIos'],
                    versionAndroid: value.data()!['appVersionAndroid'],
                  );
                }
              }
            }
            // log(value.data().toString());
          }
        });
    if (MySharedPreferences.isLoggedIn) {
      try {
        await Supabase.instance.client
            .from('users')
            .select('is_blocked')
            .eq('id', MySharedPreferences.userId)
            .single()
            .then((value) {
              if (value['is_blocked'] == true) {
                if (context.mounted) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => PopScope(
                      canPop: false,
                      child: AlertDialog(
                        title: Text(
                          !context.isCurrentLanguageAr()
                              ? 'You have been blocked'
                              : 'تم حظرك من التطبيق',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        content: Text(
                          !context.isCurrentLanguageAr()
                              ? 'Please contact support'
                              : 'يرجى التواصل مع الدعم الفني',
                          style: TextStyle(fontSize: 14),
                        ),
                        actions: [
                          BounceButton(
                            height: 40,
                            onPressed: () async {
                              await LaunchUrlsService().launchBrowesr(
                                uri: facebookAppLink,
                                context: context,
                              );
                            },
                            title: !context.isCurrentLanguageAr()
                                ? 'Ok'
                                : 'موافق',
                          ),
                        ],
                      ),
                    ),
                  );
                }
              }
            });
      } catch (e) {
        debugPrint("Error checking blocked status: $e");
      }
    }
  }

  chackUpdate({
    required BuildContext context,
    required String versionIos,
    required String versionAndroid,
    required String playStoreUrl,
    required String appStoreUrl,
  }) async {
    final platform = PlatformService.platform;

    bool isAndroid = AppPlatform.androidApp == platform;

    // log('$versionAndroid ${AppConstance.appVersion} DDDDDDDDDD');
    if (isAndroid) {
      if (versionAndroid != AppConstance.appVersion) {
        showDialog(
          context: context,
          builder: (context) => PopScope(
            canPop: false,
            child: AlertDialog(
              title: Text(
                !context.isCurrentLanguageAr() ? 'New update' : 'تحديث جديد',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              content: Text(
                !context.isCurrentLanguageAr()
                    ? 'Please update the app'
                    : 'يرجى تحديث التطبيق',
                style: TextStyle(fontSize: 14),
              ),
              actions: [
                BounceButton(
                  height: 40,
                  onPressed: () {
                    LaunchUrlsService().launchBrowesr(
                      uri: isAndroid ? playStoreUrl : appStoreUrl,
                      context: context,
                    );
                  },
                  title: !context.isCurrentLanguageAr() ? 'Ok' : 'موافق',
                ),
              ],
            ),
          ),
        );
      }
    } else {
      if (versionIos != AppConstance.appVersion) {
        showDialog(
          context: context,
          builder: (context) => PopScope(
            canPop: false,
            child: AlertDialog(
              title: Text(
                !context.isCurrentLanguageAr() ? 'New update' : 'تحديث جديد',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              content: Text(
                !context.isCurrentLanguageAr()
                    ? 'Please update the app'
                    : 'يرجى تحديث التطبيق',
                style: TextStyle(fontSize: 14),
              ),
              actions: [
                BounceButton(
                  height: 40,
                  onPressed: () {
                    LaunchUrlsService().launchBrowesr(
                      uri: isAndroid ? playStoreUrl : appStoreUrl,
                      context: context,
                    );
                  },
                  title: !context.isCurrentLanguageAr() ? 'Ok' : 'موافق',
                ),
              ],
            ),
          ),
        );
      }
    }
  }
}
