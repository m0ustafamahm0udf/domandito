import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:domandito/core/app_router.dart';
import 'package:domandito/modules/landing/views/landing_screen.dart';
import 'package:domandito/modules/signin/signin_screen.dart';
import 'package:domandito/shared/widgets/web.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
import 'package:domandito/core/services/notifications/cloud_messaging_service.dart';
import 'package:domandito/core/services/badge_service.dart';
import 'package:domandito/core/utils/bloc_helpers.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:domandito/firebase_options.dart';
import 'package:domandito/shared/controllers/connectivity/connectivity_cubit.dart';
import 'package:domandito/shared/functions/deeplink_helper.dart';
import 'package:domandito/shared/style/system_ui.dart';
import 'package:domandito/shared/theme/app_theme.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Map<String, dynamic> notificationsMap = {};

@pragma("vm:entry-point")
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await MySharedPreferences.init();
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  CloudMessagingService().handleBackgroundReceipt(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy(); // Add this line
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  InitFirebaseNotification().init();
  FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

  SystemUiStyle.overlayStyle();
  await MySharedPreferences.init();
  Bloc.observer = AppBlocObserver();
  await EasyLocalization.ensureInitialized();
  await ConnectivityHandler().checkConnection();

  await GmsCheck().checkGmsAvailability();
  try {
    BadgeService.updateBadgeCount();
  } catch (e) {
    //
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      saveLocale: true,
      fallbackLocale: const Locale('ar'),
      path: "assets/languages",
      useOnlyLangCode: true,
      startLocale: const Locale('en'),
      child: OneNotification(
        builder: (context, _) {
          final app = const MyApp();
          return kIsWeb ? WebFixedSizeWrapper(child: app) : app;
        },
      ),
    ),
  );
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
            } else {
              context.print('Disconnected');
            }
          }
        },
        builder: (context, state) {
          return GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: GetMaterialApp(
              title: 'Domandito',
              navigatorKey: navigatorKey,
              scrollBehavior: const CupertinoScrollBehavior(),
              theme: AppTheme.lightTheme(context: context),
              debugShowCheckedModeBanner: false,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              initialRoute: kIsWeb ? AppRoutes.landing : null,
              getPages: kIsWeb ? AppPages.routes : null,
              home: AnnotatedRegion<SystemUiOverlayStyle>(
                value: const SystemUiOverlayStyle(
                  statusBarBrightness: Brightness.light,
                  statusBarColor: Colors.transparent,
                  systemNavigationBarColor: Colors.transparent,
                  systemNavigationBarIconBrightness: Brightness.dark,
                  statusBarIconBrightness: Brightness.dark,
                ),
                child: _toggleScreen(),
              ),
            ),
          );
        },
      ),
    );
  }
}
