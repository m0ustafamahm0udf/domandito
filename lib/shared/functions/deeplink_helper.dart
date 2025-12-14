// import 'dart:developer';

// ignore_for_file: use_build_context_synchronously

import 'package:app_links/app_links.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:domandito/core/utils/utils.dart';
import 'package:domandito/main.dart';
import 'package:domandito/modules/profile/view/profile_screen.dart';
import 'package:domandito/modules/question/views/question_screen.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class DeepLinkHelper {
  final AppLinks _appLinks = AppLinks();
  bool _handledInitialLink = false;
  Uri? _lastHandledUri;

  void setupDeepLinkHandler({required BuildContext context}) async {
    // Stream listener for real-time deep links
    _appLinks.uriLinkStream.listen((Uri? uri) async {
      if (_shouldHandleUri(uri)) {
        // log('Deep link received (stream): $uri');

        bool isBlocked = await checkIsBlocked();

        if (!isBlocked) {
          _handleDeepLink(uri: uri!, context: context);
        }
      }
    });

    // Handle initial link
    if (!_handledInitialLink) {
      final Uri? initialLink = await _appLinks.getInitialLink();
      if (_shouldHandleUri(initialLink)) {
        // log('Initial deep link: $initialLink');
        _handledInitialLink = true;
        bool isBlocked = await checkIsBlocked();

        if (!isBlocked) {
          _handleDeepLink(uri: initialLink!, context: context);
        }
      }
    }
  }

  bool _shouldHandleUri(Uri? uri) {
    if (uri == null) return false;

    // Block if it's exactly the same as the last one and it happened very recently
    if (uri == _lastHandledUri) return false;

    _lastHandledUri = uri;

    // Reset after a short delay to allow re-handling later
    Future.delayed(Duration(seconds: 2), () {
      _lastHandledUri = null;
    });

    return true;
  }

  void _handleDeepLink({
    required Uri uri,
    required BuildContext context,
  }) async {
    // Handle deep link
    // log('Deep link handled: $uri');

    if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'q') {
      final questionId = uri.pathSegments.last;
      // log('Product ID: $productId');

      // Delay navigation slightly to ensure context is ready

      Future.delayed(Duration(milliseconds: 100), () async {
        try {
          final res = await getQuestionData(questionId: questionId);
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
    }
    if (uri.pathSegments.length == 1 && uri.pathSegments.first != 'q') {
      final userUserName = uri.pathSegments.last;
      // log('Product ID: $productId');

      // Delay navigation slightly to ensure context is ready
      if (userUserName == MySharedPreferences.userUserName) {
        return;
      }
      Future.delayed(Duration(milliseconds: 100), () async {
        pushScreen(
          navigatorKey.currentState!.context,
          screen: ProfileScreen(userId: '', userUserName: userUserName),
        );
      });
    }
  }
}
