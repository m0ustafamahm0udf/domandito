import 'package:domandito/core/app_router.dart';
import 'package:domandito/modules/landing/views/landing_screen.dart';
import 'package:domandito/modules/signin/signin_screen.dart';
import 'package:domandito/shared/widgets/web.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:gms_check/gms_check.dart';
import 'package:one_context/one_context.dart';
import 'package:domandito/core/services/connectivity/connectivity.dart';
import 'package:domandito/core/services/notifications/notification_initialize_service.dart';
import 'package:domandito/core/utils/bloc_helpers.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:domandito/firebase_options.dart';
// import 'package:domandito/modules/intro/views/intro_screen.dart';
// import 'package:domandito/modules/landing/views/landing_screen.dart';
import 'package:domandito/shared/controllers/connectivity/connectivity_cubit.dart';
import 'package:domandito/shared/functions/deeplink_helper.dart';
import 'package:domandito/shared/style/system_ui.dart';
import 'package:domandito/shared/theme/app_theme.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Map<String, dynamic> notificationsMap = {};
//
@pragma("vm:entry-point")
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    // final data = message.notification;
    // print(
    //     "onBackgroundMessage::\nTitle:: ${data?.title}\nBody:: ${data?.body}\nData:: ${message.data}");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  InitFirebaseNotification().init();
  FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

  SystemUiStyle.overlayStyle();
  await MySharedPreferences.init();
  Bloc.observer = AppBlocObserver();
  await EasyLocalization.ensureInitialized();
  await ConnectivityHandler().checkConnection();
  await GmsCheck().checkGmsAvailability();
  // final Locale deviceLocale = WidgetsBinding.instance.window.locale;
  if (kIsWeb) {
    runApp(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        saveLocale: true,
        fallbackLocale: const Locale('ar'),
        path: "assets/languages",
        useOnlyLangCode: true,
        // startLocale: deviceLocale.toString().split('_').first.toString() == 'ar' ? const Locale('ar') : const Locale('en'),
        startLocale: Locale('en'),
        child: OneNotification(
          builder: (x, _) => WebFixedSizeWrapper(child: const MyApp()),
        ),
      ),
    );
  } else {
    runApp(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        saveLocale: true,
        fallbackLocale: const Locale('ar'),
        path: "assets/languages",
        useOnlyLangCode: true,
        // startLocale: deviceLocale.toString().split('_').first.toString() == 'ar' ? const Locale('ar') : const Locale('en'),
        startLocale: Locale('en'),
        child: OneNotification(builder: (x, _) => const MyApp()),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _toggleScreen() {
    if (MySharedPreferences.isLoggedIn) {
      return LandingScreen();
    } else {
      return SignInScreen();
    }
  }

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      DeepLinkHelper().setupDeepLinkHandler(context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider.value(value: ConnectivityCubit())],
      child: BlocConsumer<ConnectivityCubit, ConnectivityState>(
        listenWhen: (previous, current) => previous != current,
        listener: (context, state) {
          if (state is ConnectivityStatus) {
            if (state.hasConnection) {
              context.print('Connected');
              // context.toHomeScreen();
            } else {
              context.print('Disconnected');
            }
          }
        },
        builder: (context, state) {
          if (!kIsWeb) {
            return GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: GetMaterialApp(
                title: 'Domandito',
                navigatorKey: navigatorKey,
                // builder: OneContext().builder,
                // navigatorKey: OneContext().key,
                // builder: OneContext().builder,
                scrollBehavior: CupertinoScrollBehavior(),
                theme: AppTheme.lightTheme(context: context),
                debugShowCheckedModeBanner: false,
                localizationsDelegates: [...context.localizationDelegates],
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                home:
                    //  InvitationsAndRequestsScreen()
                    AnnotatedRegion<SystemUiOverlayStyle>(
                      value: SystemUiOverlayStyle(
                        statusBarBrightness: Brightness.light,
                        statusBarColor: Colors.transparent,
                        systemNavigationBarColor: Colors.transparent,
                        systemNavigationBarIconBrightness: Brightness.dark,
                        statusBarIconBrightness: Brightness.dark,
                      ),
                      child: _toggleScreen(),
                      // child: ConnectivityBuilder(
                      //   onlineBuilder: (context) => _toggleScreen(),
                      //   offlineBuilder: (context) => OfflineScreen(),
                      // ),
                    ),
              ),
            );
          } else {
            return GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: GetMaterialApp(
                title: 'Domandito',

                initialRoute: AppRoutes.landing, // يبدأ من المسار الرئيسي
                getPages: AppPages.routes, // تحديد قائمة المسارات
                navigatorKey: navigatorKey,
                // builder: OneContext().builder,
                // navigatorKey: OneContext().key,
                // builder: OneContext().builder,
                scrollBehavior: CupertinoScrollBehavior(),
                theme: AppTheme.lightTheme(context: context),
                debugShowCheckedModeBanner: false,
                localizationsDelegates: [...context.localizationDelegates],
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                home:
                    //  InvitationsAndRequestsScreen()
                    AnnotatedRegion<SystemUiOverlayStyle>(
                      value: SystemUiOverlayStyle(
                        statusBarBrightness: Brightness.light,
                        statusBarColor: Colors.transparent,
                        systemNavigationBarColor: Colors.transparent,
                        systemNavigationBarIconBrightness: Brightness.dark,
                        statusBarIconBrightness: Brightness.dark,
                      ),
                      child: _toggleScreen(),
                      // child: ConnectivityBuilder(
                      //   onlineBuilder: (context) => _toggleScreen(),
                      //   offlineBuilder: (context) => OfflineScreen(),
                      // ),
                    ),
              ),
            );
          }
        },
      ),
    );
  }
}
