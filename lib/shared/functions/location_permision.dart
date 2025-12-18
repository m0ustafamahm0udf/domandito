
// import 'package:domandito/core/utils/extentions.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:location/location.dart';

// Future<bool> handlePermissionLocation({required BuildContext context}) async {
//   bool serviceEnabled;
//   LocationPermission permission;

//   // Test if location services are enabled.
//   serviceEnabled = await Geolocator.isLocationServiceEnabled();
//   if (!serviceEnabled) {
//     await showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//               title: Text('Location Services are disabled'),
//               actions: [
//                 TextButton(
//                     child: Text('Close'),
//                     onPressed: () async {
//                       Navigator.of(context).pop();
//                     }),
//                 TextButton(
//                   child: Text('Enable Location Services'),
//                   onPressed: () async {
//                     await Location().requestService();
//                     await handlePermissionLocation(context: context);
//                     context.back();
//                   },
//                 ),
//               ],
//             ));
//     return Future.error('Location Services are disabled');
//   }

//   permission = await Geolocator.checkPermission();
//   if (permission == LocationPermission.denied) {
//     permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied) {
//       return Future.error('Location Services are disabled');
//     }
//   }

//   if (permission == LocationPermission.deniedForever) {
//     // Permissions are denied forever, handle appropriately.
//     return Future.error('Location permissions are permanently denied, we cannot request permissions.');
//   }

//   return true;
// }
