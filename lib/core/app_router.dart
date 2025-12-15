import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:domandito/modules/profile/view/profile_screen.dart';
import 'package:domandito/modules/landing/views/landing_screen.dart';
import 'package:domandito/modules/signin/signin_screen.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';

final GoRouter appRouter = GoRouter(
  errorBuilder: (context, state) {
    return const Scaffold(body: Center(child: Text('404 - Page not found')));
  },
  routes: [
    /// Home
    GoRoute(
      path: '/',
      builder: (context, state) {
        return MySharedPreferences.isLoggedIn
            ? LandingScreen()
            : SignInScreen();
      },
    ),

    /// User profile
    GoRoute(
      path: '/:username',
      builder: (context, state) {
        final username = state.pathParameters['username']!;
        return ProfileScreen(userId: '', userUserName: username);
      },
    ),
  ],
);
