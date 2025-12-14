// import 'package:domandito/shared/theme/app_theme.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'core/constants/app_images.dart';
// import 'main.dart';
// import 'shared/style/app_colors.dart';
// import 'package:flutter/foundation.dart';
// import 'package:url_launcher/url_launcher.dart';

// // Only import html for Flutter web
// // ignore: deprecated_member_use

// import 'dart:html' as html;

// class WebLandingScreen extends StatefulWidget {
//   const WebLandingScreen({super.key});

//   @override
//   State<WebLandingScreen> createState() => _WebLandingScreenState();
// }

// class _WebLandingScreenState extends State<WebLandingScreen> {
//   final String facebook = 'https://www.facebook.com/m0ustafamahm0ud';
//   final String iosLink =
//       'https://apps.apple.com/eg/app/%D8%B9%D9%88%D8%AF%D8%A9/id6470727128';
//   final String androidLink =
//       'https://play.google.com/store/apps/details?id=com.m0ustafamahm0ud.backapp';

//   String _detectPlatform() {
//     final userAgent = html.window.navigator.userAgent.toLowerCase();
//     if (userAgent.contains('iphone') ||
//         userAgent.contains('ipad') ||
//         userAgent.contains('mac os') ||
//         userAgent.contains('ios')) {
//       return 'ios';
//     } else if (userAgent.contains('android')) {
//       return 'android';
//     }
//     return 'other';
//   }

//   void _launchStore(String url) {
//     html.window.location.assign(url);
//   }

//   @override
//   void initState() {
//     super.initState();

//     // Auto-launch store link if running on web
//     if (kIsWeb) {
      
//       Future.delayed(const Duration(seconds: 3), () {
//         final platform = _detectPlatform();
//         if (platform == 'ios') {
//           _launchStore(iosLink);
//         } else if (platform == 'android') {
//           _launchStore(androidLink);
//         }
//       });
//     }
//   }

//   Future<void> launchBrowser({
//     required String uri,
//     required BuildContext context,
//   }) async {
//     Uri url = Uri.parse(uri);
//     if (await canLaunchUrl(url)) {
//       await launchUrl(url, mode: LaunchMode.externalApplication);
//     } else {
//       throw 'Could not launch $url';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       navigatorKey: navigatorKey,
//       // builder: OneContext().builder,
//       // navigatorKey: OneContext().key,
//       // builder: OneContext().builder,
//       scrollBehavior: CupertinoScrollBehavior(),
//       theme: AppTheme.lightTheme(context: context),
//       debugShowCheckedModeBanner: false,
//       localizationsDelegates: [...context.localizationDelegates],
//       supportedLocales: context.supportedLocales,
//       locale: context.locale,
//       home: Scaffold(
//         body: Center(
//           child: ListView(
           
//             children: [
//               const SizedBox(height: 20),

//               Image.asset(AppImages.logo, width: 400, height: 400),
//               SizedBox(height: 20),
//               Text(
//                 'Domandito',
//                 textAlign: TextAlign.center,

//                 style: TextStyle(
//                   color: AppColors.primary,
//                   fontSize: 30,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 5),
//               // التطبيق يمكّن الأصدقاء من البحث عن الأشخاص المفقودين باستخدام الذكاء الاصطناعي.

//               Text(
//                 'بنقرّب البعيد',
//                 textAlign: TextAlign.center,

//                 style: TextStyle(
//                   color: AppColors.primary,
//                   fontSize: 20,
//                   // fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 5),

//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 40),
//                 child: Text(
//                   'أبلكيشن يمكّن الأصدقاء من البحث عن الأشخاص المفقودين بإستخدام الذكاء الاصطناعي',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: AppColors.primary,
//                     fontSize: 16,
//                     // fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               GestureDetector(
//                 onTap: () async {
//                   await launchBrowser(uri: iosLink, context: context);
//                 },
//                 child: Image.asset('assets/images/ios.png', width: 50,height: 50,),
//               ),
//               GestureDetector(
//                 onTap: () async {
//                   await launchBrowser(uri: androidLink, context: context);
//                 },
//                 child: Image.asset('assets/images/google.png', width: 50,height: 50,),
//               ),
//               const SizedBox(height: 10),
//               TextButton(
//                 onPressed: () async {
//                   await launchBrowser(uri: facebook, context: context);
//                 },
//                 child: const Text(
//                   'إدعمنا',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     decoration: TextDecoration.underline,
//                     fontSize: 16,
//                     fontFamily: 'Vazirmatn',
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),

//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
