// // import 'dart:convert';
// // // import 'dart:developer';
// // import 'package:http/http.dart' as http;

// // Future<double?> getDistanceFromGoogleAPI({
// //   required double originLat,
// //   required double originLng,
// //   required double destLat,
// //   required double destLng,
// //   required String apiKey,
// // }) async {
// //   final String url = 'https://maps.googleapis.com/maps/api/distancematrix/json?'
// //       'origins=$originLat,$originLng&'
// //       'destinations=$destLat,$destLng&'
// //       'key=AIzaSyCcOWxQgXGToRfKLlt1KjU_ev-ohFmPbRY';

// //   final response = await http.get(Uri.parse(url));

// //   if (response.statusCode == 200) {
// //     final data = jsonDecode(response.body);
// //     final elements = data['rows'][0]['elements'][0];

// //     if (elements['status'] == 'OK') {
// //       final distanceInMeters = elements['distance']['value'];
// //       return distanceInMeters / 1000.0; // return in kilometers
// //     } else {
// //     //   log('Google API error: ${elements['status']}');
// //       return null;
// //     }
// //   } else {
// //     // log('HTTP error: ${response.statusCode}');
// //     return null;
// //   }
// // }

// import 'dart:convert';
// // import 'dart:developer';
// import 'package:http/http.dart' as http;
// import 'package:geolocator/geolocator.dart';

// Future<double?> getDistanceFromGoogleAPI({
//   required double originLat,
//   required double originLng,
//   required double destLat,
//   required double destLng,
// }) async {
//   // ✅ Step 1: Ensure location services are enabled
//   bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//   if (!serviceEnabled) {
//     // print('Location services are disabled.');
//     return null;
//   }

//   // ✅ Step 2: Check and request permission
//   LocationPermission permission = await Geolocator.checkPermission();
//   if (permission == LocationPermission.denied) {
//     permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied) {
//       // log('Location permission denied.');
//       return null;
//     }
//   }

//   if (permission == LocationPermission.deniedForever) {
//     // log('Location permission permanently denied.');
//     return null;
//   }

//   // ✅ Step 3: Call Google Maps Distance Matrix API
//   final String url = 'https://maps.googleapis.com/maps/api/distancematrix/json?'
//       'origins=$originLat,$originLng&'
//       'destinations=$destLat,$destLng&'
//       'key=AIzaSyCcOWxQgXGToRfKLlt1KjU_ev-ohFmPbRY';

//   final response = await http.get(Uri.parse(url));

//   if (response.statusCode == 200) {
//     final data = jsonDecode(response.body);
//     final elements = data['rows'][0]['elements'][0];

//     if (elements['status'] == 'OK') {
//       final distanceInMeters = elements['distance']['value'];
//       return distanceInMeters / 1000.0; // return in kilometers
//     } else {
//       // log('Google API error: ${elements['status']}');
//       return null;
//     }
//   } else {
//     // log('HTTP error: ${response.statusCode}');
//     return null;
//   }
// }
