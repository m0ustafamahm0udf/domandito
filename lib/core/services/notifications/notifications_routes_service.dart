//
// import 'package:ama_property/controllers/agent/agent_properties_ctrl.dart';
// import 'package:ama_property/controllers/agent/orders_ctrl.dart';
// import 'package:ama_property/controllers/base_nav_bar_ctrl.dart';
// import 'package:ama_property/controllers/expert/expert_ctrl.dart';
// import 'package:ama_property/controllers/property_details/property_details_ctrl.dart';
// import 'package:ama_property/services/shared/custom_navigation.dart';
// import 'package:ama_property/ui/screens/expert/expert_screen.dart';
// import 'package:ama_property/ui/screens/property_details/property_details_screen.dart';
// import 'package:ama_property/utils/shared_prefrences.dart';
// import 'package:get/get.dart';

// class RoutesService {
//   void toggle(Map<String, dynamic> notificationsMap) {
//     try {
//       // final int partnerId = int.parse(notificationsMap['partner_id']);
//       // print('notificationsMap');
//       // // print(notificationsMap);
//       // print('notificationsMap');
//       // final String type = notificationsMap['type'];
//       if (MySharedPreferences.userId != 0 &&
//           MySharedPreferences.isLastVersion) {
//         switch (notificationsMap['type']) {
//           case 'partner':
//             Future.delayed(
//               Duration.zero,
//               () => customNavigateToPage(
//                   screen: PropertyDetailsScreen(
//                       partnerId: int.parse(notificationsMap['partner_id'])),
//                   deleteController: () => Get.delete<PropertyDetailsCtrl>()),
//             );

//           case 'order':
//             if (MySharedPreferences.isAgent) {
//               Get.lazyPut(() => OrdersCtrl());
//               BaseNavBarCtrl.find.navBarController.jumpToTab(1);
//               Future.delayed(
//                 Duration.zero,
//                 () => OrdersCtrl.find.pagingController.refresh(),
//               );
//             }
//           case 'my_partner':
//             if (MySharedPreferences.isAgent) {
//               Get.lazyPut(() => AgentPropertiesCtrl());
//               BaseNavBarCtrl.find.navBarController.jumpToTab(0);
//               Future.delayed(
//                 Duration.zero,
//                 () => AgentPropertiesCtrl.find.pagingController.refresh(),
//               );
//             }
//           case 'expert':
//             Future.delayed(
//               Duration.zero,
//               () => customNavigateToPage(
//                   screen: const ExpertScreen(),
//                   deleteController: () => Get.delete<ExpertCtrl>()),
//             );
//         }
//       }
//     } catch (e) {
//       log("RouteError:: $e");
//     }
//   }
// }
