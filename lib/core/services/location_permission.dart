// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';

// Future<LocationPermission> handleLocationPermission({required BuildContext context}) async {
//   bool serviceEnabled;
//   LocationPermission permission;

//   serviceEnabled = await Geolocator.isLocationServiceEnabled();
//   if (!serviceEnabled) {
//     return LocationPermission.denied;
//   }
//   permission = await Geolocator.checkPermission();
//   if (permission == LocationPermission.denied) {
//     permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied) {
//       return LocationPermission.denied;
//     }
//   }
//   if (permission == LocationPermission.deniedForever) {
//     return LocationPermission.deniedForever;
//   }
//   return permission;
// }
