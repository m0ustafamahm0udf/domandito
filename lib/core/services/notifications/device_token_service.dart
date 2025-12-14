// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../../utils/api_url.dart';
// import '../../utils/shared_prefrences.dart';

// class DeviceTokenService {
//   Future<void> updateDeviceToken(String token) async {
//     try {
//       // await FirebaseFirestore.instance
//       //     .collection('users')
//       //     .doc(MySharedPreferences.userId.toString())
//       //     .set({
//       //   'token': token,
//       //   // 'name': MySharedPreferences.name + MySharedPreferences.lastName,
//       //   // 'phone': MySharedPreferences.phone,
//       // });

//       String url = '${ApiUrl.mainUrl}${ApiUrl.updateDeviceToken}';
//       Uri uri = Uri.parse(url);
//       var headers = {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer ${MySharedPreferences.accessToken}',
//       };
//       var body = jsonEncode({
//         'device_token': token,
//       });
//       // log(
//       //     "Response:: updateDeviceTokenResponse\nUrl:: $url\nheaders:: $headers \n$body");
//       await http.post(uri, body: body, headers: headers);
//       // log(
//       //     "updateDeviceTokenStatusCode:: ${response.statusCode} updateTokenBody:: ${response.body}");
//     } catch (e) {
//       // log("deviceTokenError:: $e");
//     }
//   }
// }
