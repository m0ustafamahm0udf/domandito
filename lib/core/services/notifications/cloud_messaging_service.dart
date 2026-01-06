import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/services/launch_urls.dart';

import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:domandito/core/utils/utils.dart';
import 'package:domandito/firebase_options.dart';
import 'package:domandito/main.dart';
import 'package:domandito/modules/answer/views/answer_question_screen.dart';
import 'package:domandito/modules/question/views/question_screen.dart';
import 'package:domandito/modules/profile/view/profile_screen.dart';
import 'package:domandito/shared/widgets/custom_dialog.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:domandito/core/services/badge_service.dart';

class CloudMessagingService {
  void terminated(RemoteMessage? message) {
    BadgeService.updateBadgeCount();
    if (message == null) return;
    if (message.notification != null && message.data.isNotEmpty) {
      // final data = message.notification;
      // print(
      //     "terminatedMessage::\nTitle:: ${data?.title}\nBody:: ${data?.body}\nData:: ${message.data}");
      routeToggle(message.data);
      // LocalNotificationsService().display(message);
    }
  }

  void foreground(RemoteMessage? message) async {
    BadgeService.updateBadgeCount();
    if (message == null) return;

    if (message.notification != null) {
      final data = message.notification;
      notificationsMap = message.data;
      // print("foregroundMessage::\nTitle:: ${data?.title}\nBody:: ${data?.body}\nData:: ${message.data}");

      Future.delayed(Duration(milliseconds: 500), () async {
        // log('${data!.title} DDDDDDDDDDDDDDDDDDDDDDDD');
        await showDialog(
          context: navigatorKey.currentState!.context,
          builder: (context) => CustomDialog(
            onConfirm: () async {
              final type = message.data['type'];
              navigatorKey.currentState!.context.back();

              switch (type) {
                case AppConstance.url:
                  await LaunchUrlsService().launchBrowesr(
                    uri: message.data[AppConstance.url],
                    context: navigatorKey.currentState!.context,
                  );
                  break;
                case AppConstance.question:
                  // log(message.data['id'] + 'id');

                  Future.delayed(Duration(milliseconds: 100), () async {
                    try {
                      final res = await getQuestionData(
                        questionId: message.data['id'],
                      );
                      if (res != null) {
                        final q = res;

                        pushScreen(
                          navigatorKey.currentState!.context,
                          screen: AnswerQuestionScreen(question: q),
                        );
                      } else {
                        // debugPrint("No restaurant found with id: $resId");
                      }
                    } catch (e) {
                      // debugPrint("Error loading restaurant: $e");
                    }
                  });
                case AppConstance.answer || AppConstance.like:
                  Future.delayed(Duration(milliseconds: 100), () async {
                    try {
                      final res = await getQuestionData(
                        questionId: message.data['id'],
                      );
                      if (res != null) {
                        final q = res;

                        pushScreen(
                          navigatorKey.currentState!.context,
                          screen: QuestionScreen(
                            isVerified: false,
                            question: q,
                            receiverImage: q.receiver.image,
                            onBack: (s) {},
                            currentProfileUserId: MySharedPreferences.userId,
                          ),
                        );
                      } else {
                        // debugPrint("No restaurant found with id: $resId");
                      }
                    } catch (e) {
                      // debugPrint("Error loading restaurant: $e");
                    }
                  });
                case AppConstance.follow:
                  AppConstance().showInfoToast(
                    context,
                    msg: context.isCurrentLanguageAr()
                        ? 'لا يمكنك مشاهدة الشخص الذي قام بمتابعتك 😜'
                        : 'You can\'t view the person who followed you 😜',
                  );
                  break;
                case AppConstance.profileVisit:
                  if (message.data['id'] == 'HIDDEN') {
                    AppConstance().showInfoToast(
                      navigatorKey.currentState!.context,
                      msg:
                          navigatorKey.currentState!.context
                              .isCurrentLanguageAr()
                          ? 'لا يمكنك معرفة من هو المستخدم 😜'
                          : 'You cannot identify the user 😜',
                    );
                  } else if (message.data['id'] != null &&
                      message.data['id'].toString().isNotEmpty) {
                    pushScreen(
                      navigatorKey.currentState!.context,
                      screen: ProfileScreen(userId: message.data['id']),
                    );
                  }
                  break;
                case AppConstance.screenshot:
                  // Just close dialog, no navigation
                  break;
                default:
                // افتح الشاشة الافتراضية
                // navigatorKey.currentState!.context.toAndRemoveAll(
                //   LandingScreen(),
                // );
              }
            },
            isConfirm: false,
            // ignore: unnecessary_null_comparison
            title: data!.title == null ? 'Domandito' : data.title.toString(),
            content: getTranslatedContent(
              data.body.toString(),
              navigatorKey.currentState!.context,
            ),
          ),
        );
      });
    } else {
      // log('message');
    }
  }

  // Called when user taps a notification that was delivered in background
  void handleTap(RemoteMessage? message) {
    BadgeService.updateBadgeCount();
    if (message == null) return;
    if (message.notification != null && message.data.isNotEmpty) {
      routeToggle(message.data);
      // LocalNotificationsService().display(message);
    }
  }

  // Called when a notification is received in background (HEADLESS)
  void handleBackgroundReceipt(RemoteMessage? message) {
    BadgeService.updateBadgeCount();
    // DO NOT navigate or show local notification here
  }

  void routeToggle(Map<String, dynamic> data) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await MySharedPreferences.init();

    final type = data['type'];

    if (type == null) return;

    bool isBlocked = await checkIsBlocked();

    if (MySharedPreferences.isLoggedIn && !isBlocked) {
      switch (type) {
        case AppConstance.url:
          await LaunchUrlsService().launchBrowesr(
            uri: data[AppConstance.url],
            context: navigatorKey.currentState!.context,
          );
          break;
        case AppConstance.question:
          // log(data['id'] + 'id');
          Future.delayed(Duration(milliseconds: 100), () async {
            try {
              final res = await getQuestionData(questionId: data['id']);
              if (res != null) {
                final q = res;

                pushScreen(
                  navigatorKey.currentState!.context,
                  screen: AnswerQuestionScreen(question: q),
                );
              } else {
                // debugPrint("No restaurant found with id: $resId");
              }
            } catch (e) {
              // debugPrint("Error loading restaurant: $e");
            }
          });
        case AppConstance.answer || AppConstance.like:
          Future.delayed(Duration(milliseconds: 100), () async {
            try {
              final res = await getQuestionData(questionId: data['id']);
              if (res != null) {
                final q = res;

                pushScreen(
                  navigatorKey.currentState!.context,
                  screen: QuestionScreen(
                    isVerified: false,
                    question: q,
                    receiverImage: q.receiver.image,
                    onBack: (s) {},
                    currentProfileUserId: MySharedPreferences.userId,
                  ),
                );
              } else {
                // debugPrint("No restaurant found with id: $resId");
              }
            } catch (e) {
              // debugPrint("Error loading restaurant: $e");
            }
          });
        // case 'p':
        //   pushScreen(
        //     navigatorKey.currentState!.context,
        //     screen: LostPersonDetailsScreen(lostPersonId: data['id']),
        //   );
        //   break;
        case AppConstance.follow:
          Future.delayed(Duration(milliseconds: 100), () {
            AppConstance().showInfoToast(
              navigatorKey.currentState!.context,
              msg: navigatorKey.currentState!.context.isCurrentLanguageAr()
                  ? 'لا يمكنك مشاهدة الشخص الذي قام بمتابعتك 😜'
                  : 'You can\'t view the person who followed you 😜',
            );
          });
        case AppConstance.profileVisit:
          if (data['id'] == 'HIDDEN') {
            Future.delayed(Duration(milliseconds: 100), () {
              AppConstance().showInfoToast(
                navigatorKey.currentState!.context,
                msg: navigatorKey.currentState!.context.isCurrentLanguageAr()
                    ? 'لا يمكنك معرفة من هو المستخدم 😜'
                    : 'You cannot identify the verified user 😜',
              );
            });
          } else if (data['id'] != null && data['id'].toString().isNotEmpty) {
            pushScreen(
              navigatorKey.currentState!.context,
              screen: ProfileScreen(userId: data['id']),
            );
          }
        case AppConstance.screenshot:
          // Just open app, don't navigate to profile
          break;
        default:
        // افتح الشاشة الافتراضية
        // navigatorKey.currentState!.context.toAndRemoveAll(LandingScreen());
      }
    }
  }
}
