import 'dart:convert';

import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';

//
class SendMessageNotificationWithHTTPv1 {
  final String projectId = 'domandito-281cc';

  final String serviceAccountJson = '''
  {
    "type": "service_account",
  "project_id": "domandito-281cc",
  "private_key_id": "b5b87813252d13cc424c38e8c9ccdd423272d15e",
  "private_key": "-----BEGIN PRIVATE KEY-----\\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDKhfQLyg6/uOE/\\nbnCRfVU9ALMSlwZiie+g9BHIbXblhIJ7lzXPF5dt8XAvnd2noWQ5ijC5ZW2RqF5+\\n5QQWC9jjvazEdFhcLe2U8IDd2gQHAyTLb9zFOnc1h49XDT+7QzD8sKJLT1WeZTjc\\nvks3dSAS1gk4Atc7hXIKfJK/F3tpNDHZ/Y99lTaZoXpUruGNvOT7l0ystW5QIG09\\nN07At77EtGmXrqfakT77Zalh4qWCxKr6YzvTX7WjcfXXYdzW4ZwsTJFynHQB2zVo\\nEoEq1Erii+pslzAh99ZDo/Th+Nr9M2QFTxMRcZUu6onfEqbJ6HCbd/QUEAn9oPL4\\n23M0JoGlAgMBAAECggEAJlWGpTig5A9lq3EHI7LakIpyWuF1Vu+PCSNJvmth5v3X\\nCPfNOp7Xjfr2Zjz2eMVmyDFtGZqmS7zX7iMBS/8AFdOQQTtYglI7N0byzYt32a/x\\npgRNgJOZfuti6XJbjuGgAySYA7NHnIzCX54xdJTZ9lbHNe/rt5uBw5Ri3oLeXEIr\\nPc5jenNXZkO9i02einit9Bjfac4lbiUYOxN/OV1WXMESsz9YsUzhbzg2Kb6x7k83\\n8S+OXhcB9pjTMNwKipQMUiS9ZNzDV47xRPrJG2vMwcYR5ZqZUTtVfLj/Bs6f9WRT\\nWet3GKR+dNbFmm/980MQrR8h3Al49ylSOPGHKI0UvQKBgQD9pUjvSYbqKa16Aoi6\\nY6vyiV/B2Pk0MBZ1L/LPatiri6BykHAT6gnEu0Y86BEbK+HY7cvtGSpLbuc0djp4\\nKkdQiSZATzdj0GbeVxGR2Ru/ZjppQI+j0QKwkCzo7FL0Yb2sURMe2G5bCXteiEOR\\n6EAfoml2AhdTg7IQvW9ld0ZnmwKBgQDMZzDf1H2IxFWTgH76J0vbQUUcXV8Wj9ao\\nc7bm35HGbm+VSR3EPLAd8Jh9/1eANOThBe+KC4KTLXKC8F5nHgK4TpQilvp9iomu\\noVDhUrvnrd76FwgWF14M1R0d1cq+Djcm6TEuZU7GzNCgwiZDo6oCgfxqPBWf/Vz+\\ndTXb9clvvwKBgQCYl843/tEGoMo3o7yj/YCdad3M3f6WUfPAznbSJ+Jv2ZFOOuzi\\nXiNAUrYfwDFCWnUFr5HGcyRJu0+m9RWZ4z2CCvCTMdUN3Ht2eYUdbDLQQ+0SEwAX\\nOo/WrvYFrt79HKwiNag+H1DMvfiVV37nEYU6QtgVYY6s9Ia0oXKZ5VbazwKBgD5v\\nHpyf2SBXaBQ/4YkjS6ZTD3sUgiDwGo8lmS54B5zmyqp8xNzV9K2QeeOyhNWiUm7x\\nUzOFRIMUFLAuH4e7wPTu+4x9NVH3aQqwN3Y7wS2JDFyzgELPLGkbB2O/k8ftq6b0\\n/5K+WwuaL/eKlgl/CkTt013XsHtH9om635KqRrcdAoGBAKWw7upujFGl18bc2TkK\\nJNPui866SxYLfWUpsoPvl3y8rxUYHb++Jz2mU61IZDjscihKyyWqyOFDOT1AEPuU\\nRjmjPZqlWiYPdgtfpACbog38OUOFlwt0SBrEHqH/zdPEkWvVU9CuDctLkcLi9e7l\\npf9ROLgAQlR4cAnVAsIIOAk6\\n-----END PRIVATE KEY-----\\n",
  "client_email": "firebase-adminsdk-fbsvc@domandito-281cc.iam.gserviceaccount.com",
  "client_id": "111656732728784180579",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40domandito-281cc.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
  }
  ''';

  Future<String?> _getAccessToken() async {
    try {
      final serviceAccountMap = json.decode(serviceAccountJson);

      var client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson(serviceAccountMap),
        ['https://www.googleapis.com/auth/firebase.messaging'],
      );

      return client.credentials.accessToken.data;
    } catch (e) {
      // log('Error generating access token: $e');
      return null;
    }
  }

  Future<void> send({
    required String toToken,
    required String message,
    required String title,
    required String id,
  }) async {
    try {
      // log('toToken $toToken');
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        // log('Failed to retrieve access token');
        return;
      }

      final url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
      );
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

      var body = jsonEncode({
        'message': {
          'token': toToken,
          'notification': {'title': title, 'body': message},
          'data': {'click_action': 'FLUTTER_NOTIFICATION_CLICK', 'id': id},
          'android': {
            'priority': 'high',
            'notification': {
              'sound': 'default', // Correct placement for Android
            },
          },
          'apns': {
            'headers': {'apns-priority': '10'},
            'payload': {
              'aps': {
                'alert': {'title': title, 'body': message},
                'sound': 'ring.caf', // new notification sound
                'content-available': 1,
              },
            },
          },
        },
      });

      http.Response response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        // log("Notification sent successfully: ${response.body}");
      } else {
        // log("Failed to send notification: ${response.body}");
      }
    } catch (e) {
      // log("Error sending notification: $e");
    }
  }

  Future<void> send2({
    required String toToken,
    required String message,
    required String title,
    required String id,
    required String urll,
    required String type,
  }) async {
    // if (kIsWeb) return;
    if (MySharedPreferences.deviceToken == toToken) return;
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        // log('Failed to retrieve access token');
        return;
      }

      final url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
      );
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

      var body = jsonEncode({
        'message': {
          'token': toToken,
          'notification': {'title': title, 'body': message},
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': id,
            'url': urll,
            'type': type,
          },
          'android': {
            'priority': 'high',
            'notification': {
              'sound': 'default', // Correct placement for Android
            },
          },
          'apns': {
            'headers': {'apns-priority': '10'},
            'payload': {
              'aps': {
                'alert': {'title': title, 'body': message},
                'sound': 'ring.caf', // new notification sound
                'content-available': 1,
              },
            },
          },
        },
      });

      http.Response response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        // log("Notification sent successfully: ${response.body}");
      } else {
        // log("Failed to send notification: ${response.body}");
      }
    } catch (e) {
      // log("Error sending notification: $e");
    }
  }

  // Send notification to all users
  Future<void> sendToAll({
    required List<String> toTokens,
    required String message,
    required String title,
  }) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        // log('Failed to retrieve access token');
        return;
      }

      final url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
      );
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

      List<Future<http.Response>> futures = toTokens.map((toToken) {
        var body = jsonEncode({
          'message': {
            'token': toToken,
            'notification': {'title': title, 'body': message},
            'data': {'click_action': 'FLUTTER_NOTIFICATION_CLICK'},
            'android': {
              'priority': 'high',
              'notification': {
                'sound': 'default',
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              },
            },
          },
        });

        return http
            .post(url, headers: headers, body: body)
            .timeout(
              const Duration(seconds: 30), // Timeout after 30 seconds
              onTimeout: () {
                // log('Request timed out');
                return http.Response('Timeout', 408);
              },
            );
      }).toList();

      List<http.Response> responses = await Future.wait(futures);

      for (var response in responses) {
        if (response.statusCode == 200) {
          // log("Notification sent successfully: ${response.body}");
        } else {
          // log("Failed to send notification: ${response.body}");
        }
      }
    } catch (e) {
      // log("Error sending notification to all users: $e");
    }
  }
}
